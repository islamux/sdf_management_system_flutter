import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'employee.g.dart';

@HiveType(typeId: 0)
class Employee extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String position;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final String email;

  @HiveField(5)
  final DateTime joinDate;

  @HiveField(6)
  final bool isPresent;

  const Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.phone,
    required this.email,
    required this.joinDate,
    this.isPresent = false,
  });

  Employee copyWith({
    String? id,
    String? name,
    String? position,
    String? phone,
    String? email,
    DateTime? joinDate,
    bool? isPresent,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      joinDate: joinDate ?? this.joinDate,
      isPresent: isPresent ?? this.isPresent,
    );
  }

  @override
  List<Object?> get props => [
    id, 
    name, 
    position, 
    phone, 
    email, 
    joinDate,
    isPresent
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'phone': phone,
      'email': email,
      'joinDate': joinDate.toIso8601String(),
      'isPresent': isPresent,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      position: map['position'],
      phone: map['phone'],
      email: map['email'],
      joinDate: DateTime.parse(map['joinDate']),
      isPresent: map['isPresent'],
    );
  }
}
