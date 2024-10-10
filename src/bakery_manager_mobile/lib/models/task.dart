class Task {
  final String taskID;
  final String recipeID;
  final int amountToBake;
  final DateTime assignmentDate;
  final DateTime? completionDate;
  final String employeeID;
  String? name;
  final String status;
  final DateTime dueDate;

  Task({
    required this.taskID,
    required this.recipeID,
    required this.amountToBake,
    required this.assignmentDate,
    this.completionDate,
    required this.employeeID,
    this.name,
    required this.status,
    required this.dueDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskID: json['TaskID'],
      recipeID: json['RecipeID'],
      amountToBake: json['AmountToBake'],
      status: json['Status'],
      assignmentDate: DateTime.parse(json['AssignmentDate']),
      dueDate: DateTime.parse(json['DueDate']),
      completionDate: json['CompletionDate'] != null
          ? DateTime.parse(json['CompletionDate'])
          : null, // Handle null value for CompletionDate
      employeeID: json['AssignedEmployeeID'],
    );
  }
}
