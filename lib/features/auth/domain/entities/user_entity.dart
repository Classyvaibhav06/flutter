import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String? phone;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    this.phone,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        firstName,
        lastName,
        gender,
        image,
        phone,
      ];
}
