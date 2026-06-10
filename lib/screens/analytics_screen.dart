import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/widgets/glass_widgets.dart';
import '../providers/task_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    // Calculate category distribution dynamically from provider.tasks
    final totalTasks = provider.tasks.length;
    final Map<String, int> categoryCounts = {};
    for (var task in provider.tasks) {
      categoryCounts[task.category] = (categoryCounts[task.category] ?? 0) + 1;
    }

    final List<Map<String, dynamic>> distribution = [];
    if (totalTasks > 0) {
      for (var cat in provider.categories) {
        final count = categoryCounts[cat.name] ?? 0;
        if (count > 0) {
          distribution.add({
            'name': cat.name,
            'count': count,
            'ratio': count / totalTasks,
            'color': cat.color,
          });
        }
      }
      // Sort by count descending to display most popular categories first
      distribution.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    }

    final donutValues = totalTasks > 0
        ? distribution.map((item) => item['ratio'] as double).toList()
        : [1.0];
    final donutColors = totalTasks > 0
        ? distribution.map((item) => item['color'] as Color).toList()
        : [Colors.white.withValues(alpha: 0.05)];

    final completedRatio = provider.completionPercentage;
    final pendingRatio = totalTasks > 0 ? 1.0 - completedRatio : 0.0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: NovaTheme.timeAmbientGradient,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Productivity Insights',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your performance over the last 7 days.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        children: [
                          // Summary Cards Grid (3 Columns)
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  context,
                                  'Total Done',
                                  '${provider.totalCompletedTasks}',
                                  Icons.task_alt_rounded,
                                  NovaTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  context,
                                  'Task Debt',
                                  '${provider.taskDebt}',
                                  Icons.warning_amber_rounded,
                                  provider.taskDebt > 0 ? NovaTheme.error : NovaTheme.secondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  context,
                                  'On-Time',
                                  '${(provider.onTimeCompletionRate * 100).toInt()}%',
                                  Icons.timer_rounded,
                                  NovaTheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Activity Graph (Faux Line Chart)
                          GlassPanel(
                            radius: 16,
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Success vs Missed',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8, height: 8,
                                          decoration: BoxDecoration(color: NovaTheme.primary, shape: BoxShape.circle),
                                        ),
                                        const SizedBox(width: 4),
                                        Text('Done', style: TextStyle(fontSize: 10, color: Colors.white54)),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 8, height: 8,
                                          decoration: BoxDecoration(color: NovaTheme.error, shape: BoxShape.circle),
                                        ),
                                        const SizedBox(width: 4),
                                        Text('Missed', style: TextStyle(fontSize: 10, color: Colors.white54)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 160,
                                  width: double.infinity,
                                  child: CustomPaint(
                                    painter: DoubleBarChartPainter(
                                      successPoints: provider.weeklyActivityPoints,
                                      missedPoints: provider.weeklyMissedPoints,
                                      successColor: NovaTheme.primary,
                                      missedColor: NovaTheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Distribution and Completion Ratio bento grids
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Donut Chart Card
                              Expanded(
                                child: GlassPanel(
                                  radius: 16,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Distribution',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Center(
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              width: 90,
                                              height: 90,
                                              child: CustomPaint(
                                                painter: DonutChartPainter(
                                                  values: donutValues,
                                                  colors: donutColors,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              totalTasks > 0 ? '100%' : '0%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white.withValues(alpha: 0.9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      if (totalTasks == 0) ...[
                                        Center(
                                          child: Text(
                                            'No tasks yet',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withValues(alpha: 0.4),
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        ...distribution.take(3).map((item) {
                                          final name = item['name'] as String;
                                          final ratio = item['ratio'] as double;
                                          final color = item['color'] as Color;
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: _buildLegendItem(
                                              name,
                                              '${(ratio * 100).toInt()}%',
                                              color,
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Completion Ratio Card
                              Expanded(
                                child: GlassPanel(
                                  radius: 16,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Completion Ratio',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      _buildCompletionBar('Completed', completedRatio, NovaTheme.primary),
                                      const SizedBox(height: 24),
                                      _buildCompletionBar('Pending', pendingRatio, Colors.white24),
                                    ],
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return GlassPanel(
      radius: 12,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: accentColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: accentColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color == Colors.white24 ? Colors.white70 : color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 6,
            color: Colors.white.withValues(alpha: 0.03),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  boxShadow: color == Colors.white24
                      ? null
                      : [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Painter for Double Bar Chart
class DoubleBarChartPainter extends CustomPainter {
  final List<double> successPoints;
  final List<double> missedPoints;
  final Color successColor;
  final Color missedColor;

  DoubleBarChartPainter({
    required this.successPoints,
    required this.missedPoints,
    required this.successColor,
    required this.missedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (successPoints.isEmpty || missedPoints.isEmpty) return;

    final double widthBetweenPoints = size.width / (successPoints.length - 1);
    final double barWidth = (widthBetweenPoints * 0.35).clamp(4.0, 10.0);

    double maxVal = 10.0;
    for (var v in successPoints) if (v > maxVal) maxVal = v;
    for (var v in missedPoints) if (v > maxVal) maxVal = v;

    // 1. Draw Grid Lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;
    final int gridLines = 4;
    final double gridSpacing = size.height / gridLines;
    for (int i = 0; i <= gridLines; i++) {
      canvas.drawLine(Offset(0, i * gridSpacing), Offset(size.width, i * gridSpacing), gridPaint);
    }

    final sPaint = Paint()..color = successColor..style = PaintingStyle.fill;
    final mPaint = Paint()..color = missedColor..style = PaintingStyle.fill;

    for (int i = 0; i < successPoints.length; i++) {
      final x = i * widthBetweenPoints;

      // Add a slight baseline offset so bars don't sink into the axis line
      final baseline = size.height - 2;

      final sHeight = (successPoints[i] / maxVal) * (size.height - 20);
      final mHeight = (missedPoints[i] / maxVal) * (size.height - 20);

      if (sHeight > 0) {
        final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(x - barWidth - 1, baseline - sHeight, barWidth, sHeight),
          const Radius.circular(2),
        );
        canvas.drawRRect(r, sPaint);
      }

      if (mHeight > 0) {
        final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 1, baseline - mHeight, barWidth, mHeight),
          const Radius.circular(2),
        );
        canvas.drawRRect(r, mPaint);
      }
    }

    // X-axis day labels
    final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < days.length; i++) {
      textPainter.text = TextSpan(
        text: days[i],
        style: TextStyle(
          fontSize: 10,
          color: Colors.white.withValues(alpha: 0.3),
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(i * widthBetweenPoints - (textPainter.width / 2), size.height + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant DoubleBarChartPainter oldDelegate) {
    return oldDelegate.successPoints != successPoints || 
           oldDelegate.missedPoints != missedPoints;
  }
}

// Custom Painter for Donut Chart
class DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  const DonutChartPainter({
    required this.values,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - (strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw background track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    double startAngle = -pi / 2; // Start at top
    for (int i = 0; i < values.length; i++) {
      final sweepAngle = 2 * pi * values[i];
      
      final segmentPaint = Paint()
        ..color = colors[i]
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Draw segment with subtle drop shadow glow effect
      final glowPaint = Paint()
        ..color = colors[i].withValues(alpha: 0.3)
        ..strokeWidth = strokeWidth + 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      
      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
      canvas.drawArc(rect, startAngle, sweepAngle, false, segmentPaint);
      
      // Update start angle for next segment, leaving a tiny gap if needed (we offset it)
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}
