import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/widgets/glass_widgets.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class TasksHistoryScreen extends StatelessWidget {
  final bool showCompleted;

  const TasksHistoryScreen({super.key, required this.showCompleted});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = showCompleted ? taskProvider.completedTasks : taskProvider.incompleteTasks;

    return Scaffold(
      body: Stack(
        children: [
          // Background Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: NovaTheme.timeAmbientGradient,
              ),
            ),
          ),
          
          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: NovaTheme.background.withAlpha(153),
                  border: const Border(
                    bottom: BorderSide(
                      color: Colors.white10,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      showCompleted ? 'Completed Tasks' : 'Incomplete Tasks',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main List
          SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 64),
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        showCompleted ? 'No completed tasks yet.' : 'No overdue incomplete tasks.',
                        style: TextStyle(color: Colors.white.withAlpha(128)),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return _buildTaskCard(context, tasks[index], taskProvider);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task, TaskProvider provider) {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.urgent:
        priorityColor = NovaTheme.primary;
        break;
      case TaskPriority.medium:
        priorityColor = NovaTheme.tertiary;
        break;
      case TaskPriority.low:
        priorityColor = NovaTheme.secondary;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            GlassPanel(
              radius: 12,
              opacity: 0.05,
              border: Border.all(color: Colors.white10, width: 0.5),
              padding: const EdgeInsets.fromLTRB(22, 14, 16, 14),
              child: Row(
                children: [
                  // Complete Checkbox Button
                  GestureDetector(
                    onTap: () => provider.toggleTaskCompletion(task.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isCompleted ? Colors.transparent : priorityColor,
                          width: 2.0,
                        ),
                        color: task.isCompleted ? priorityColor : Colors.transparent,
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.black,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Task Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: task.isCompleted ? Colors.white.withAlpha(76) : Colors.white,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Priority Chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: priorityColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                task.priorityLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: priorityColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Time Info
                            Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: Colors.white.withAlpha(102),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.dueTime,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withAlpha(102),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Delete button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white.withAlpha(76),
                      size: 20,
                    ),
                    onPressed: () => provider.deleteTask(task.id),
                  ),
                ],
              ),
            ),
            // Colored left indicator strip
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(
                color: priorityColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
