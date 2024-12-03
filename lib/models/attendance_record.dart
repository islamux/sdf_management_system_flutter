import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'attendance_record.g.dart';

@HiveType(typeId: 1)
class AttendanceRecord extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String employeeId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final DateTime checkIn;

  @HiveField(4)
  final DateTime? checkOut;

  @HiveField(5)
  final String status; // 'present', 'absent', 'late'

  @HiveField(6)
  final String? notes;

  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.status,
    this.notes,
  });

  AttendanceRecord copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    DateTime? checkIn,
    DateTime? checkOut,
    String? status,
    String? notes,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props =>
      [id, employeeId, date, checkIn, checkOut, status, notes];
}
