import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/widgets/glass_widgets.dart';
import '../core/widgets/neon_button.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'create_task_sheet.dart';
import 'tasks_history_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final completionPct = taskProvider.completionPercentage;

    return Scaffold(
      body: Stack(
        children: [
          // Time-based Ambient Background Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: NovaTheme.timeAmbientGradient,
              ),
            ),
          ),
          // Top Header App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: NovaTheme.background.withValues(alpha: 0.6),
                  border: const Border(
                    bottom: BorderSide(
                      color: Colors.white10,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Profile Avatar (Left aligned)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white24,
                            width: 1.0,
                          ),
                        ),
                        child: ClipOval(
                          child: Container(
                            color: NovaTheme.primary.withValues(alpha: 0.2),
                            child: Center(
                              child: Text(
                                taskProvider.displayName.isNotEmpty ? taskProvider.displayName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: NovaTheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Logo Title (Perfectly Centered)
                    Text(
                      'NOVA',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 8.0,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                    // Right side icons (Right aligned)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: NovaTheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                            },
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, color: NovaTheme.onSurfaceVariant),
                            color: NovaTheme.surfaceHigh,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (value) {
                              if (value == 'completed') {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const TasksHistoryScreen(showCompleted: true)));
                              } else if (value == 'incomplete') {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const TasksHistoryScreen(showCompleted: false)));
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'completed',
                                child: Text('Completed Tasks History', style: TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuItem(
                                value: 'incomplete',
                                child: Text('Incomplete Tasks History', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Main Body Content
          SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 64),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // extra bottom padding for transparent nav
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting text
                    Text(
                      'Good Evening, ${taskProvider.displayName}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Here is your focus for tonight.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Circular Progress Ring Section
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(180, 180),
                            painter: ProgressRingPainter(
                              progress: completionPct,
                              gradient: NovaTheme.primaryGradient,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(completionPct * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Stats Bento Grid
                    Row(
                      children: [
                        Expanded(
                          child: GlassPanel(
                            radius: 12,
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: NovaTheme.primary.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: NovaTheme.primary.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.local_fire_department_rounded,
                                    color: NovaTheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Streak',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    Text(
                                      '${taskProvider.streakDays} Days',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassPanel(
                            radius: 12,
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: NovaTheme.secondary.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: NovaTheme.secondary.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.bolt,
                                    color: NovaTheme.secondary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Efficiency',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    Text(
                                      '${taskProvider.efficiency}%',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Today's Reminders
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Tonight',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${taskProvider.activeTasks.length} Left',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: NovaTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Task Cards List
                    taskProvider.activeTasks.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text(
                                'You\'re all caught up for now.',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(128),
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: taskProvider.activeTasks.length,
                            itemBuilder: (context, index) {
                              final task = taskProvider.activeTasks[index];
                              return _buildTaskCard(context, task, taskProvider);
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
          // Floating Action Button
          Positioned(
            bottom: 96,
            right: 20,
            child: NeonIconButton(
              icon: Icons.add,
              iconColor: Colors.black,
              buttonColor: NovaTheme.primary,
              glowColor: NovaTheme.primary,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const CreateTaskSheet(),
                );
              },
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
              padding: const EdgeInsets.fromLTRB(22, 14, 16, 14), // Left padding adjusted for strip
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
                            color: task.isCompleted ? Colors.white.withValues(alpha: 0.3) : Colors.white,
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
                                color: priorityColor.withValues(alpha: 0.1),
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
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.dueTime,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Delete button on swipe/drag (or simple trailing delete icon)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white.withValues(alpha: 0.3),
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

// Custom Painter for Glassmorphic Progress Ring
class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Gradient gradient;

  ProgressRingPainter({
    required this.progress,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 6;

    // 1. Draw track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;

    // Angle starts at -90 degrees (top)
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
