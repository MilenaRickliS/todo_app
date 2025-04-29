import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_provider.dart';


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

          final showBell = isToday || isPast;

          return ListTile(
            title: Text(
              "LEMBRETE: ${task.title}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Vencimento: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}",
            ),
            trailing: showBell
                ? const ShakingBellIcon(shouldShake: true)
                : const Icon(Icons.notifications_none),
          );
        },
      ),
    );
  }
}
