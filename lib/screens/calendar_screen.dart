import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/widgets/glass_widgets.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  int get _daysInMonth {
    return DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
  }

  int get _firstDayOffset {
    return _currentMonth.weekday % 7;
  }

  String get _monthName {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }
  
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Ambient Glow Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x0Dddb7ff), Colors.transparent],
                  center: Alignment(0.0, -0.6),
                  radius: 1.0,
                ),
              ),
            ),
          ),
          SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month Selector Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _monthName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Select a day to view agenda',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _previousMonth,
                            child: _buildChevronButton(Icons.chevron_left_rounded),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _nextMonth,
                            child: _buildChevronButton(Icons.chevron_right_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Days of the Week labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _DayLabel('S'),
                      _DayLabel('M'),
                      _DayLabel('T'),
                      _DayLabel('W'),
                      _DayLabel('T'),
                      _DayLabel('F'),
                      _DayLabel('S'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Calendar Grid (Glassmorphic Container)
                  GlassPanel(
                    radius: 16,
                    opacity: 0.04,
                    padding: const EdgeInsets.all(4),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: _firstDayOffset + _daysInMonth,
                      itemBuilder: (context, index) {
                        if (index < _firstDayOffset) {
                          // Offset days
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.01),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }
                        
                        final dayNumber = index - _firstDayOffset + 1;
                        final cellDate = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
                        final isSelected = _isSameDay(cellDate, _selectedDate);

                        // Check for event dots based on actual tasks
                        final dayTasks = provider.tasks.where((t) {
                          if (t.fullDueDateTime == null) return false;
                          return _isSameDay(t.fullDueDateTime!, cellDate);
                        }).toList();

                        final hasPrimaryDot = dayTasks.any((t) => t.priority == TaskPriority.urgent);
                        final hasSecondaryDot = dayTasks.any((t) => t.priority != TaskPriority.urgent);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = cellDate;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? NovaTheme.primary.withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? NovaTheme.primary.withValues(alpha: 0.4)
                                    : Colors.white.withValues(alpha: 0.05),
                                width: 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: NovaTheme.primary.withValues(alpha: 0.15),
                                        blurRadius: 12,
                                        spreadRadius: -1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? NovaTheme.primary
                                        : Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                // Event indicator dots
                                if (hasPrimaryDot || hasSecondaryDot)
                                  Positioned(
                                    bottom: 6,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (hasPrimaryDot)
                                          Container(
                                            width: 4,
                                            height: 4,
                                            margin: const EdgeInsets.symmetric(horizontal: 1),
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: NovaTheme.primary,
                                            ),
                                          ),
                                        if (hasSecondaryDot)
                                          Container(
                                            width: 4,
                                            height: 4,
                                            margin: const EdgeInsets.symmetric(horizontal: 1),
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: NovaTheme.secondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Agenda Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Agenda for ${_selectedDate.day} ${_monthName.split(' ')[0]}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final selectedTasks = provider.tasks.where((t) {
                            if (t.fullDueDateTime == null) return false;
                            return _isSameDay(t.fullDueDateTime!, _selectedDate);
                          }).toList();
                          return Text(
                            '${selectedTasks.length} Events',
                            style: const TextStyle(
                              fontSize: 12,
                              color: NovaTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Agenda Events List
                  Builder(
                    builder: (context) {
                      final selectedTasks = provider.tasks.where((t) {
                        if (t.fullDueDateTime == null) return false;
                        return _isSameDay(t.fullDueDateTime!, _selectedDate);
                      }).toList();
                      
                      return selectedTasks.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: selectedTasks.length,
                              itemBuilder: (context, index) {
                                final task = selectedTasks[index];
                                return _buildAgendaCard(context, task);
                              },
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 100),
                                child: Text(
                                  'No events scheduled for this day.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                            );
                    }
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildChevronButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white12),
        color: Colors.white.withValues(alpha: 0.02),
      ),
      child: Icon(
        icon,
        size: 16,
        color: Colors.white54,
      ),
    );
  }

  Widget _buildAgendaCard(BuildContext context, Task task) {
    Color accentColor;
    switch (task.priority) {
      case TaskPriority.urgent:
        accentColor = NovaTheme.error;
        break;
      case TaskPriority.medium:
        accentColor = NovaTheme.tertiary;
        break;
      case TaskPriority.low:
        accentColor = NovaTheme.secondary;
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
              padding: const EdgeInsets.fromLTRB(22, 16, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (task.priority == TaskPriority.urgent)
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: NovaTheme.error,
                                  boxShadow: [
                                    BoxShadow(
                                      color: NovaTheme.error.withValues(alpha: 0.8),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
                              child: Text(
                                task.title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: task.isCompleted ? Colors.white54 : Colors.white,
                                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          task.dueTime,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                task.category,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (task.priority == TaskPriority.urgent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: const Text(
                                  'High Priority',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: task.isCompleted ? NovaTheme.primary : Colors.white.withValues(alpha: 0.3),
                    ),
                    onPressed: () {
                      Provider.of<TaskProvider>(context, listen: false).toggleTaskCompletion(task.id);
                    },
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
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String label;

  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
