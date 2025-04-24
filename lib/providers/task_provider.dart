import 'package:flutter/foundation.dart';
import 'package:todo_app/models/task.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(String title) {
    _tasks.add(
      Task(
        id: DateTime.now().toString(),
        title: title,
      ),
    );
    notifyListeners();
  }

  void toggleTask(String id) {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}