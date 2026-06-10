import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/widgets/neon_button.dart';
import '../core/widgets/glass_widgets.dart';
import '../providers/task_provider.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showTaskSelector(BuildContext context, TaskProvider provider) {
    if (provider.isTimerActive) return; // Prevent changing while running
    final tasks = provider.activeTasks.where((t) => !t.isCompleted).toList();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => GlassPanel(
        radius: 20,
        padding: const EdgeInsets.all(20),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Task to Focus On', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No active tasks available.', style: TextStyle(color: Colors.white54)),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (ctx, i) {
                      final task = tasks[i];
                      return ListTile(
                        title: Text(task.title, style: const TextStyle(color: Colors.white)),
                        subtitle: Text(task.dueTime, style: const TextStyle(color: Colors.white54)),
                        onTap: () {
                          provider.setFocusTask(task);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimeSelector(BuildContext context, TaskProvider provider) {
    if (provider.isTimerActive) return; // Prevent changing while running
    
    double selectedMinutes = 25.0; // Default starting value
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return GlassPanel(
            radius: 20,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Set Timer Duration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 24),
                Text(
                  '${selectedMinutes.toInt()} Minutes',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: NovaTheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 8,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                  ),
                  child: Slider(
                    value: selectedMinutes,
                    min: 1,
                    max: 120,
                    activeColor: NovaTheme.primary,
                    inactiveColor: Colors.white12,
                    onChanged: (val) {
                      setState(() => selectedMinutes = val);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1m', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Text('120m', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NovaTheme.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      provider.setTimerDuration(selectedMinutes.toInt());
                      Navigator.pop(ctx);
                    },
                    child: const Text('CONFIRM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    
    // Manage pulse animation based on timer activity
    if (provider.isTimerActive) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.animateTo(0.0, duration: const Duration(milliseconds: 300));
      }
    }

    return Scaffold(
      backgroundColor: NovaTheme.background,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background concentric design rings
          Positioned.fill(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: NovaTheme.primary.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                    ),
                  ),
                  Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: NovaTheme.primary.withValues(alpha: 0.03),
                        width: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Central content layout
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Spacer/Header
                  GestureDetector(
                    onTap: () => _showTaskSelector(context, provider),
                    child: GlassPanel(
                      radius: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        children: [
                          Icon(
                            Icons.trip_origin_rounded,
                            color: Colors.white.withValues(alpha: 0.3),
                            size: 20,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.focusTask != null ? 'FOCUSING ON' : 'TAP TO SELECT TASK',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (provider.focusTask != null)
                            Text(
                              provider.focusTask!.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Timer Display
                  GestureDetector(
                    onTap: () => _showTimeSelector(context, provider),
                    child: ScaleTransition(
                      scale: _pulseAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            provider.timerString,
                            style: TextStyle(
                              fontSize: 96,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -2,
                              color: NovaTheme.primary,
                              shadows: [
                                Shadow(
                                  color: NovaTheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.isTimerActive ? 'SESSION IN PROGRESS' : 'TAP TIME TO CHANGE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(alpha: 0.5),
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Lower Controls
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          // Active controls
                          if (!provider.isTimerActive)
                            NeonIconButton(
                              icon: Icons.play_arrow_rounded,
                              iconColor: Colors.black,
                              buttonColor: provider.focusTask != null ? NovaTheme.primary : Colors.grey.withValues(alpha: 0.5),
                              glowColor: provider.focusTask != null ? NovaTheme.primary : Colors.transparent,
                              onPressed: provider.focusTask != null ? () => provider.startTimer() : () {},
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Quit / Incomplete
                                GestureDetector(
                                  onTap: () async {
                                    await provider.quitTimer();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Focus Session Stopped.')),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: NovaTheme.error.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: NovaTheme.error.withValues(alpha: 0.5)),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.close_rounded, color: NovaTheme.error),
                                        SizedBox(width: 8),
                                        Text('Quit', style: TextStyle(color: NovaTheme.error, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Complete
                                GestureDetector(
                                  onTap: () async {
                                    await provider.completeFocusSession(success: true);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Great job! Task Completed.')),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: NovaTheme.primary.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: NovaTheme.primary.withValues(alpha: 0.5)),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.check_circle_outline_rounded, color: NovaTheme.primary),
                                        SizedBox(width: 8),
                                        Text('Complete', style: TextStyle(color: NovaTheme.primary, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 24),

                          // Active Tasks Horizontal List
                          if (!provider.isTimerActive) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'SELECT A TASK',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 70,
                              child: Builder(
                                builder: (context) {
                                  final tasks = provider.activeTasks.where((t) => !t.isCompleted).toList();
                                  if (tasks.isEmpty) {
                                    return Center(
                                      child: Text('No active tasks.', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
                                    );
                                  }
                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: tasks.length,
                                    itemBuilder: (context, index) {
                                      final task = tasks[index];
                                      final isSelected = provider.focusTask?.id == task.id;
                                      return GestureDetector(
                                        onTap: () => provider.setFocusTask(task),
                                        child: Container(
                                          width: 140,
                                          margin: const EdgeInsets.only(right: 12),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isSelected ? NovaTheme.primary.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isSelected ? NovaTheme.primary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                task.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isSelected ? NovaTheme.primary : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                task.dueTime,
                                                style: TextStyle(
                                                  color: isSelected ? NovaTheme.primary.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.4),
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Focus Score Overview
                          _buildFocusOverview(provider),
                          const SizedBox(height: 16),
                          
                          // Focus Trend Chart
                          _buildTrendChart(provider),
                          const SizedBox(height: 16),
                          
                          // Session Analysis Doughnut
                          _buildAnalysisChart(provider),
                          const SizedBox(height: 16),

                          const SizedBox(height: 60), // Space for nav bar
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusOverview(TaskProvider provider) {
    return GlassPanel(
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Focus Score', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text(provider.focusLevel, style: const TextStyle(color: NovaTheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            provider.focusScore.toString(),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMetric('Current Streak', '${provider.currentFocusStreak}', Icons.local_fire_department_rounded, Colors.orange),
              _buildStatMetric('Longest Streak', '${provider.longestFocusStreak}', Icons.emoji_events_rounded, Colors.yellow),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
      ],
    );
  }

  Widget _buildTrendChart(TaskProvider provider) {
    final scores = provider.weeklyFocusScores;
    double maxY = scores.reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 100; // default bounds

    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return GlassPanel(
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Focus Trend (Last 7 Days)', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final heightFactor = scores[index] / maxY;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 24,
                      height: 100 * heightFactor,
                      decoration: BoxDecoration(
                        gradient: NovaTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(days[index], style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisChart(TaskProvider provider) {
    final stats = provider.sessionStatistics;
    final total = (stats['total'] as num?)?.toInt() ?? 0;
    final success = (stats['success'] as num?)?.toInt() ?? 0;
    final quit = (stats['quit'] as num?)?.toInt() ?? 0;
    final failed = (stats['failed'] as num?)?.toInt() ?? 0;
    final avgDuration = (stats['avgDuration'] as num?)?.toInt() ?? 0;

    double successPct = total == 0 ? 0 : success / total;
    double quitPct = total == 0 ? 0 : quit / total;
    double failedPct = total == 0 ? 0 : failed / total;

    return GlassPanel(
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Session Analysis', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMetric('Avg Duration', '${avgDuration}m', Icons.timer_rounded, NovaTheme.primary),
              _buildStatMetric('Total Sessions', '$total', Icons.tag_rounded, Colors.white),
            ],
          ),
          const SizedBox(height: 24),
          if (total == 0)
             const Center(child: Text("No sessions completed yet.", style: TextStyle(color: Colors.white54, fontSize: 12)))
          else
             Column(
               children: [
                 _buildAnalysisBar('Successful', successPct, NovaTheme.primary, success),
                 const SizedBox(height: 16),
                 _buildAnalysisBar('Quit Early', quitPct, Colors.orange, quit),
                 const SizedBox(height: 16),
                 _buildAnalysisBar('Failed', failedPct, NovaTheme.error, failed),
               ]
             )
        ],
      ),
    );
  }

  Widget _buildAnalysisBar(String label, double pct, Color color, int count) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 32, child: Text('$count', textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
      ],
    );
  }
}
