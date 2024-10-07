class Account {
  String employeeId;
  String firstName;
  String lastName;
  String username;
  String role;

  Account({
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.role,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      employeeId: json['EmployeeID'] ?? '',
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      username: json['Username'] ?? '',
      role: json['Role'] ?? 'Employee',
    );
  }
}