import 'package:hive_flutter/hive_flutter.dart';
import '../models/employee.dart';
import '../models/attendance.dart';

class HiveService {
  static const String _employeesBox = 'employees';
  static const String _attendanceBox = 'attendance';
  Box<Employee>? _employeesBoxInstance;
  Box<Attendance>? _attendanceBoxInstance;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Hive type adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(EmployeeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AttendanceAdapter());
    }

    try {
      // Open necessary boxes
      final employeesBox = await Hive.openBox<Employee>(_employeesBox);
      await Hive.openBox<Attendance>(_attendanceBox);

      // Initialize default employees if box is empty
      if (employeesBox.isEmpty) {
        await _initializeDefaultEmployees(employeesBox);
      }
    } catch (e) {
      // If there's an error, delete the boxes and try again
      await Hive.deleteBoxFromDisk(_employeesBox);
      await Hive.deleteBoxFromDisk(_attendanceBox);
      
      // Try opening the boxes again
      final employeesBox = await Hive.openBox<Employee>(_employeesBox);
      await Hive.openBox<Attendance>(_attendanceBox);
      
      // Initialize default employees
      await _initializeDefaultEmployees(employeesBox);
    }
  }

  static Future<void> _initializeDefaultEmployees(Box<Employee> box) async {
    final defaultEmployees = [
      Employee(
        id: '1',
        name: 'محمد أحمد',
        position: 'مدير',
        phone: '0599123456',
        email: 'mohammed@example.com',
        joinDate: DateTime(2023, 1, 1),
        isPresent: false,
      ),
      Employee(
        id: '2',
        name: 'أحمد محمد',
        position: 'محاسب',
        phone: '0599789012',
        email: 'ahmed@example.com',
        joinDate: DateTime(2023, 1, 1),
        isPresent: false,
      ),
      Employee(
        id: '3',
        name: 'سارة خالد',
        position: 'سكرتيرة',
        phone: '0599345678',
        email: 'sara@example.com',
        joinDate: DateTime(2023, 1, 1),
        isPresent: false,
      ),
      // Add more default employees as needed
    ];

    for (final employee in defaultEmployees) {
      await box.put(employee.id, employee);
    }
  }

  Future<void> _openBoxes() async {
    _employeesBoxInstance ??= await Hive.openBox<Employee>(_employeesBox);
    _attendanceBoxInstance ??= await Hive.openBox<Attendance>(_attendanceBox);
  }

  Future<List<Employee>> getAllEmployees() async {
    await _openBoxes();
    return _employeesBoxInstance!.values.toList();
  }

  Future<void> addEmployee(Employee employee) async {
    await _openBoxes();
    await _employeesBoxInstance!.put(employee.id, employee);
  }

  Future<void> updateEmployee(Employee employee) async {
    await _openBoxes();
    // Only update isPresent status, keep other fields unchanged
    final existingEmployee = _employeesBoxInstance!.get(employee.id);
    if (existingEmployee != null) {
      final updatedEmployee = Employee(
        id: existingEmployee.id,
        name: existingEmployee.name,
        position: existingEmployee.position,
        phone: existingEmployee.phone,
        email: existingEmployee.email,
        joinDate: existingEmployee.joinDate,
        isPresent: employee.isPresent,
      );
      await _employeesBoxInstance!.put(employee.id, updatedEmployee);
    }
  }

  Future<void> addAttendance(Attendance attendance) async {
    await _openBoxes();
    await _attendanceBoxInstance!.add(attendance);
  }

  Future<void> updateAttendance(Attendance attendance) async {
    await _openBoxes();
    final box = _attendanceBoxInstance!;
    final index = box.values.toList().indexWhere((a) => a.id == attendance.id);
    if (index != -1) {
      await box.putAt(index, attendance);
    }
  }

  Future<List<Attendance>> getAttendanceForEmployee(String employeeId) async {
    await _openBoxes();
    return _attendanceBoxInstance!.values
        .where((attendance) => attendance.employeeId == employeeId)
        .toList()
        .reversed
        .toList();
  }

  Future<List<Attendance>> getAttendanceForDate(DateTime date) async {
    await _openBoxes();
    return _attendanceBoxInstance!.values
        .where((attendance) =>
            attendance.date.year == date.year &&
            attendance.date.month == date.month &&
            attendance.date.day == date.day)
        .toList();
  }

  Future<List<Attendance>> getAttendanceReport(
      String employeeId, DateTime startDate, DateTime endDate) async {
    await _openBoxes();
    return _attendanceBoxInstance!.values
        .where((attendance) =>
            attendance.employeeId == employeeId &&
            attendance.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            attendance.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }
}
