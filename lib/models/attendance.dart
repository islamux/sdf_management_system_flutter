import 'package:hive/hive.dart';

part 'attendance.g.dart';

@HiveType(typeId: 1)
class Attendance extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String employeeId;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late bool isPresent;

  @HiveField(4)
  String? note;

  @HiveField(5)
  DateTime? checkInTime;

  @HiveField(6)
  DateTime? checkOutTime;

  @HiveField(7)
  String status; // 'حاضر', 'غائب', 'متأخر'

  @HiveField(8)
  int absentDays; // Number of consecutive absent days

  Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.isPresent,
    this.note,
    this.checkInTime,
    this.checkOutTime,
    this.status = 'غائب',
    this.absentDays = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'isPresent': isPresent,
      'note': note,
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'status': status,
      'absentDays': absentDays,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      employeeId: map['employeeId'],
      date: DateTime.parse(map['date']),
      isPresent: map['isPresent'],
      note: map['note'],
      checkInTime: map['checkInTime'] != null ? DateTime.parse(map['checkInTime']) : null,
      checkOutTime: map['checkOutTime'] != null ? DateTime.parse(map['checkOutTime']) : null,
      status: map['status'] ?? 'غائب',
      absentDays: map['absentDays'] ?? 0,
    );
  }

  // Calculate working hours for the day
  Duration? getWorkingHours() {
    if (checkInTime != null && checkOutTime != null) {
      return checkOutTime!.difference(checkInTime!);
    }
    return null;
  }

  // Check if employee is late
  bool isLate() {
    if (checkInTime == null) return false;
    
    // Assuming work starts at 8:00 AM
    final workStartTime = DateTime(
      checkInTime!.year,
      checkInTime!.month,
      checkInTime!.day,
      8, // 8 AM
      0,
    );
    
    return checkInTime!.isAfter(workStartTime);
  }
}
