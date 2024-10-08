class Email {
  String emailId;
  String emailAddress;
  String employeeId;
  String emailTypeId;
  bool valid;

  Email({
    required this.emailId,
    required this.emailAddress,
    required this.employeeId,
    required this.emailTypeId,
    required this.valid,
  });

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      emailId: json['EmailID'] ?? '',
      emailAddress: json['EmailAddress'] ?? '',
      employeeId: json['EmployeeID'] ?? '',
      emailTypeId: json['EmailTypeID'] ?? '',
      valid: json['Valid'] == 1,
    );
  }
}