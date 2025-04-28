class Task {
  final String id;
  String title;
  DateTime? dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.dueDate,
    this.isCompleted = false,
  });

}