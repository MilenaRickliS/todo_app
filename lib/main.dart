import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TaskListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
   DateTime? selectedDate;

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final TextEditingController taskController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
      ),
      body: Column(
        children: [
          Padding(
          padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: 
                    TextField(
                      controller: taskController,
                      decoration: const InputDecoration(
                        labelText: 'Nova tarefa',
                        border: OutlineInputBorder(),
                      ),
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () => _pickDate(context),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (taskController.text.isNotEmpty) {
                      taskProvider.addTask(taskController.text, selectedDate);
                      taskController.clear();
                      setState(() {
                        selectedDate = null;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          if (selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Data de vencimento: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Filtro de Tarefas
                DropdownButton<FilterType>(
                  value: taskProvider.filter,
                  onChanged: (filter) {
                    if (filter != null) {
                      taskProvider.setFilter(filter);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: FilterType.all,
                      child: Text('Todas'),
                    ),
                    DropdownMenuItem(
                      value: FilterType.completed,
                      child: Text('Concluídas'),
                    ),
                    DropdownMenuItem(
                      value: FilterType.notCompleted,
                      child: Text('Não concluídas'),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Ordenação das Tarefas
                DropdownButton<SortType>(
                  value: taskProvider.sortType,
                  onChanged: (sortType) {
                    if (sortType != null) {
                      taskProvider.setSortType(sortType);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: SortType.byTitle,
                      child: Text('Por título'),
                    ),
                    DropdownMenuItem(
                      value: SortType.byDueDate,
                      child: Text('Por data de vencimento'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: taskProvider.filteredTasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.filteredTasks[index];
                return ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                      onChanged: (value) {
                        taskProvider.toggleTask(task.id);
                      },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                    ),
                  ),
                  subtitle: task.dueDate != null
                      ? Text(
                          "Vence em: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}")
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      taskProvider.deleteTask(task.id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}