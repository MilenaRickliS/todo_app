import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/models/task.dart'; 
import 'package:todo_app/reminder.dart';


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
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const TaskListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ShakingBellIcon extends StatefulWidget {
  final bool shouldShake;

  const ShakingBellIcon({super.key, required this.shouldShake});

  @override
  ShakingBellIconState createState() => ShakingBellIconState();
}

class ShakingBellIconState extends State<ShakingBellIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );

    if (widget.shouldShake) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ShakingBellIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldShake && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.shouldShake && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: const Icon(Icons.notifications),
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: child,
        );
      },
    );
  }
}


class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  TaskListPageState createState() => TaskListPageState();
}

class TaskListPageState extends State<TaskListPage> {
   DateTime? selectedDate;
   late TextEditingController taskController;

   @override
  void initState() {
    super.initState();
    taskController = TextEditingController();
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

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

  int getPendingReminders(TaskProvider provider) {
  final now = DateTime.now();
  return provider.tasks.where((task) {
    if (task.dueDate == null || task.isCompleted) return false;

    final isToday = task.dueDate!.year == now.year &&
        task.dueDate!.month == now.month &&
        task.dueDate!.day == now.day;

    final isPast = task.dueDate!.isBefore(DateTime(now.year, now.month, now.day));

    return isToday || isPast;
  }).length;
}


  void _showEditDialog(BuildContext context, Task task, TaskProvider taskProvider) {
  final TextEditingController editController = TextEditingController(text: task.title);
  DateTime? newSelectedDate = task.dueDate;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar Tarefa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        newSelectedDate != null
                            ? "Vencimento: ${newSelectedDate?.day}/${newSelectedDate?.month}/${newSelectedDate?.year}"
                            : "Sem vencimento",
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: newSelectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            newSelectedDate = picked;
                          });
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (editController.text.isNotEmpty) {
                    taskProvider.editTask(
                      task.id,
                      editController.text,
                      newSelectedDate ?? DateTime.now(),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReminderPage()),
                  );
                },
              ),
              if (getPendingReminders(taskProvider) > 0)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${getPendingReminders(taskProvider)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
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
                final now = DateTime.now();
                bool isDueToday = task.dueDate != null &&
                    task.dueDate!.year == now.year &&
                    task.dueDate!.month == now.month &&
                    task.dueDate!.day == now.day;

                bool isPast = task.dueDate != null &&
                    task.dueDate!.isBefore(DateTime(now.year, now.month, now.day));

                bool showBell = isDueToday || isPast;


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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShakingBellIcon(shouldShake: showBell),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditDialog(context, task, taskProvider);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          taskProvider.deleteTask(task.id);
                        },
                      ),
                    ],
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

