class Task {
  final String taskID;
  final String recipeID;
  final int amountToBake;
  final DateTime assignmentDate;
  final DateTime completionDate;
  final String employeeID;
  final String name;
  late final String status;
  final DateTime dueDate;

  Task({
    required this.taskID,
    required this.recipeID,
    required this.amountToBake,
    required this.assignmentDate,
    required this.completionDate,
    required this.employeeID,
    required this.name,
    required this.status,
    required this.dueDate,
  });
}
