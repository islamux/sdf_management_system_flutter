import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/employee.dart';
import '../models/attendance.dart';
import '../services/hive_service.dart';
import 'employee_state.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  final HiveService _hiveService = HiveService();

  EmployeeCubit() : super(EmployeeInitial()) {
    loadEmployees();
  }

  void loadEmployees() async {
    try {
      emit(EmployeeLoading());
      final employees = await _hiveService.getAllEmployees();
      emit(EmployeesLoaded(employees));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  void toggleAttendance(String employeeId) async {
    try {
      final currentState = state;
      if (currentState is EmployeesLoaded) {
        // Find the employee or throw an error if not found
        final employee = currentState.employees.firstWhere(
          (e) => e.id == employeeId,
          orElse: () => throw Exception('الموظف غير موجود'),
        );

        // Create updated employee with toggled presence
        final updatedEmployee = Employee(
          id: employee.id,
          name: employee.name,
          position: employee.position,
          phone: employee.phone,
          email: employee.email,
          joinDate: employee.joinDate,
          isPresent: !employee.isPresent,
        );

        // Update employee in storage
        await _hiveService.updateEmployee(updatedEmployee);

        // Handle check-in
        if (updatedEmployee.isPresent) {
          final attendance = Attendance(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            employeeId: employeeId,
            date: DateTime.now(),
            isPresent: true,
            status: 'حاضر',
            checkInTime: DateTime.now(),
            checkOutTime: null,
          );
          await _hiveService.addAttendance(attendance);
        } 
        // Handle check-out
        else {
          try {
            // Find today's open attendance record
            final attendanceList = await _hiveService.getAttendanceForEmployee(employeeId);
            final todayAttendance = attendanceList.firstWhere(
              (a) => 
                a.date.year == DateTime.now().year &&
                a.date.month == DateTime.now().month &&
                a.date.day == DateTime.now().day &&
                a.checkOutTime == null,
              orElse: () => Attendance(
                id: DateTime.now().millisecondsSinceEpoch.toString(), 
                employeeId: employeeId, 
                date: DateTime.now(), 
                checkInTime: DateTime.now(), 
                checkOutTime: null, 
                isPresent: true, 
                status: 'حاضر'
              ),
            );

            // Update attendance if record exists
            if (todayAttendance != null) {
              todayAttendance.checkOutTime = DateTime.now();
              todayAttendance.isPresent = false;
              todayAttendance.status = 'غائب';
              
              // Calculate consecutive absent days
              int consecutiveAbsentDays = 1;
              for (var i = attendanceList.length - 1; i >= 0; i--) {
                var pastAttendance = attendanceList[i];
                if (pastAttendance.isPresent == false && 
                    pastAttendance.date.difference(todayAttendance.date).inDays.abs() == consecutiveAbsentDays) {
                  consecutiveAbsentDays++;
                } else {
                  break;
                }
              }
              
              todayAttendance.absentDays = consecutiveAbsentDays;
              await _hiveService.updateAttendance(todayAttendance);
            }
          } catch (e) {
            print('خطأ في تسجيل الخروج: ${e.toString()}');
          }
        }

        // Reload employees to reflect the changes
        loadEmployees();
      }
    } catch (e) {
      print('خطأ في تغيير الحضور: ${e.toString()}');
      emit(EmployeeError(e.toString()));
    }
  }

  void markAttendance(Attendance attendance) async {
    try {
      await _hiveService.addAttendance(attendance);
      final attendanceList =
          await _hiveService.getAttendanceForEmployee(attendance.employeeId);
      emit(AttendanceLoaded(attendanceList));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  void addEmployee(Employee employee) async {
    try {
      await _hiveService.addEmployee(employee);
      
      // Reload employees to update the state
      loadEmployees();
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }
}
