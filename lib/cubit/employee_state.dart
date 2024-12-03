import 'package:equatable/equatable.dart';
import '../models/employee.dart';
import '../models/attendance.dart';

abstract class EmployeeState extends Equatable {
  const EmployeeState();

  @override
  List<Object> get props => [];
}

class EmployeeInitial extends EmployeeState {
  @override
  List<Object> get props => [];
}

class EmployeeLoading extends EmployeeState {
  @override
  List<Object> get props => [];
}

class EmployeesLoaded extends EmployeeState {
  final List<Employee> employees;

  const EmployeesLoaded(this.employees);

  @override
  List<Object> get props => [employees];
}

class AttendanceLoaded extends EmployeeState {
  final List<Attendance> attendance;

  const AttendanceLoaded(this.attendance);

  @override
  List<Object> get props => [attendance];
}

class EmployeeError extends EmployeeState {
  final String message;

  const EmployeeError(this.message);

  @override
  List<Object> get props => [message];
}
