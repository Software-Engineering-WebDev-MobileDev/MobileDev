class Account {
  final String employeeId;
  final String firstName;
  final String lastName;
  final String username;
  final String role;

  Account({
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.role,
  });

  // Factory constructor to create an Account instance from JSON data
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      employeeId: json['EmployeeID'] ?? '',
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      username: json['Username'] ?? '',
      role: json['Role'] ?? '',
    );
  }

  // Method to convert an Account instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'EmployeeID': employeeId,
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Role': role,
    };
  }
}