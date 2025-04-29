import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_provider.dart';

class ShakingBellIcon extends StatefulWidget {
  final bool shouldShake;
  final Color iconColor;

  const ShakingBellIcon({super.key, required this.shouldShake, this.iconColor = Colors.black,});

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
      child: Icon(Icons.notifications, color: widget.iconColor),
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: child,
        );
      },
    );
  }
}


class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final reminderTasks = taskProvider.tasks
      .where((task) =>
          task.dueDate != null &&
          !task.isCompleted) 
      .toList()
    ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));


    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
      ),
      body: ListView.builder(
        itemCount: reminderTasks.length,
        itemBuilder: (context, index) {
          final task = reminderTasks[index];

          final isToday = task.dueDate != null &&
              task.dueDate!.year == DateTime.now().year &&
              task.dueDate!.month == DateTime.now().month &&
              task.dueDate!.day == DateTime.now().day;

          final isPast = task.dueDate != null &&
              task.dueDate!.isBefore(DateTime.now()) &&
              !isToday;

          final showBell = isToday || isPast && !task.isCompleted;

          Color bellColor;
          if (task.isCompleted) {
            bellColor = Colors.grey;
          } else if (isPast) {
            bellColor = Colors.red;
          } else if (isToday) {
            bellColor = Colors.orange;
          } else {
            bellColor = Colors.grey;
          } 

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(
                  "LEMBRETE",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Vencimento: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}",
                    ),
                  ],
                ),
                trailing: showBell
                  ? ShakingBellIcon(shouldShake: true, iconColor: bellColor,)
                  : const Icon(Icons.notifications_none),
              ),
          );
        },
      ),
    );
  }
}
