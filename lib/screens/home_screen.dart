import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/employee_cubit.dart';
import '../cubit/employee_state.dart';
import '../models/employee.dart';
import 'attendance_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام إدارة الموظفين'),
      ),
      body: BlocBuilder<EmployeeCubit, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EmployeeError) {
            return Center(
              child: Text('حدث خطأ: ${state.message}'),
            );
          }

          final employees = state is EmployeesLoaded 
              ? state.employees 
              : <Employee>[];

          return employees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_off,
                        size: 100,
                        color: Colors.teal.shade200,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا يوجد موظفين حالياً',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16, 
                        vertical: 8
                      ),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: Text(
                            employee.name[0],
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          employee.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(employee.position),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: employee.isPresent 
                                    ? Colors.green 
                                    : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  employee.isPresent 
                                    ? 'حاضر' 
                                    : 'غائب',
                                  style: TextStyle(
                                    color: employee.isPresent 
                                      ? Colors.green 
                                      : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                employee.isPresent 
                                  ? Icons.person_off 
                                  : Icons.person,
                                color: employee.isPresent 
                                  ? Colors.red 
                                  : Colors.green,
                              ),
                              onPressed: () {
                                context.read<EmployeeCubit>().toggleAttendance(employee.id);
                              },
                              tooltip: employee.isPresent 
                                ? 'تسجيل غياب' 
                                : 'تسجيل حضور',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_red_eye,
                                color: Colors.teal,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AttendanceScreen(employee: employee),
                                  ),
                                );
                              },
                              tooltip: 'تفاصيل الحضور',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
