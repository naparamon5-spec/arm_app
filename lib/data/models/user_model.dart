class UserModel {
  final String id;
  final String fullName;
  final String role;
  final String email;
  final String employeeId;
  final String classification;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.email,
    this.employeeId = '',
    this.classification = '',
  });
}
