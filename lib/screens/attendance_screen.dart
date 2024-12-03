import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/employee_cubit.dart';
import '../models/employee.dart';
import '../models/attendance.dart';
import '../services/hive_service.dart';

class AttendanceScreen extends StatefulWidget {
  final Employee employee;

  const AttendanceScreen({super.key, required this.employee});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Future<List<Attendance>> _attendanceFuture;
  final HiveService _hiveService = HiveService();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  void _loadAttendance() {
    _attendanceFuture =
        _hiveService.getAttendanceForEmployee(widget.employee.id);
  }

  Future<void> _recordAttendance(bool isPresent) async {
    final now = DateTime.now();
    final attendance = Attendance(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: widget.employee.id,
      date: DateTime(now.year, now.month, now.day),
      isPresent: isPresent,
      checkInTime: isPresent ? now : null,
      status: isPresent ? 'حاضر' : 'غائب',
      note: _noteController.text,
    );

    await _hiveService.addAttendance(attendance);
    _noteController.clear();
    setState(() {
      _loadAttendance();
    });
  }

  Future<void> _recordCheckOut(Attendance attendance) async {
    final now = DateTime.now();
    final updatedAttendance = Attendance(
      id: attendance.id,
      employeeId: attendance.employeeId,
      date: attendance.date,
      isPresent: attendance.isPresent,
      checkInTime: attendance.checkInTime,
      checkOutTime: now,
      status: attendance.isLate() ? 'متأخر' : 'حاضر',
      note: attendance.note,
    );

    await _hiveService.updateAttendance(updatedAttendance);
    setState(() {
      _loadAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('سجل الحضور: ${widget.employee.name}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _recordAttendance(true),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('تسجيل حضور'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _recordAttendance(false),
                          icon: const Icon(Icons.cancel),
                          label: const Text('تسجيل غياب'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Attendance>>(
              future: _attendanceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('حدث خطأ: ${snapshot.error}'),
                  );
                }

                final attendanceList = snapshot.data ?? [];

                if (attendanceList.isEmpty) {
                  return const Center(
                    child: Text('لا يوجد سجلات حضور'),
                  );
                }

                return ListView.builder(
                  itemCount: attendanceList.length,
                  itemBuilder: (context, index) {
                    final attendance = attendanceList[index];
                    final date =
                        DateFormat('yyyy/MM/dd').format(attendance.date);
                    final checkInTime = attendance.checkInTime != null
                        ? DateFormat('HH:mm').format(attendance.checkInTime!)
                        : '-';
                    final checkOutTime = attendance.checkOutTime != null
                        ? DateFormat('HH:mm').format(attendance.checkOutTime!)
                        : '-';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Icon(
                          attendance.isPresent
                              ? Icons.check_circle
                              : Icons.cancel,
                          color:
                              attendance.isPresent ? Colors.green : Colors.red,
                        ),
                        title: Text('التاريخ: $date'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('وقت الحضور: $checkInTime'),
                            Text('وقت الانصراف: $checkOutTime'),
                            if (attendance.note?.isNotEmpty ?? false)
                              Text('ملاحظات: ${attendance.note}'),
                            Text(
                              'الحالة: ${attendance.status}',
                              style: TextStyle(
                                color: attendance.status == 'متأخر'
                                    ? Colors.orange
                                    : attendance.status == 'حاضر'
                                        ? Colors.green
                                        : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: attendance.isPresent &&
                                attendance.checkOutTime == null
                            ? ElevatedButton(
                                onPressed: () => _recordCheckOut(attendance),
                                child: const Text('تسجيل انصراف'),
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
