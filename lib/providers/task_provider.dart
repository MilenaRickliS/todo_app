import 'package:flutter/foundation.dart';
import 'package:todo_app/models/task.dart';

enum FilterType {
    all,
    completed,
    notCompleted,
}
enum SortType {
  byTitle,
  byDueDate,
}

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  FilterType _filter = FilterType.all;
  FilterType get filter => _filter;

  SortType _sortType = SortType.byTitle;
  SortType get sortType => _sortType;

  List<Task> get tasks => _tasks;

  List<Task> get filteredTasks {
    List<Task> filtered = [];

    switch (_filter) {
      case FilterType.completed:
        filtered = _tasks.where((task) => task.isCompleted).toList();
        break;
      case FilterType.notCompleted:
        filtered = _tasks.where((task) => !task.isCompleted).toList();
        break;
      case FilterType.all:
        filtered = List.from(_tasks);
        break;
    }

    switch (_sortType) {
      case SortType.byTitle:
        filtered.sort((a, b) => a.title.compareTo(b.title)); // Ordena por título
        break;
      case SortType.byDueDate:
        filtered.sort((a, b) => (a.dueDate ?? DateTime.now()).compareTo(b.dueDate ?? DateTime.now())); // Ordena por data de vencimento
        break;
    }

    return filtered;
  }

  void setFilter(FilterType filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSortType(SortType sortType) {
    _sortType = sortType;
    notifyListeners();
  }

  void addTask(String title, DateTime? dueDate) {
    _tasks.add(
      Task(
        id: DateTime.now().toString(),
        title: title,
        dueDate: dueDate,
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
