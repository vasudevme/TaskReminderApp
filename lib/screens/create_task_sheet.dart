import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/widgets/glass_widgets.dart';
import '../core/widgets/neon_button.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class CreateTaskSheet extends StatefulWidget {
  const CreateTaskSheet({super.key});

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  final _titleController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;
  String _selectedCategory = 'Work';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  DateTime? _selectedDate;
  int? _selectedNotifyBefore; // null = no notification
  bool _isTitleFocused = false;

  // Notification lead-time options (in minutes)
  static const List<int?> _notifyOptions = [null, 5, 10, 15, 30, 60];
  static const List<String> _notifyLabels = [
    'None',
    '5 min',
    '10 min',
    '15 min',
    '30 min',
    '1 hr',
  ];

  @override
  Widget build(BuildContext context) {
    final keyboardOffset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardOffset),
      child: GlassPanel(
        radius: 24,
        blur: 32.0,
        opacity: 0.15,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Create New Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // ── Title Input ──────────────────────────────────────────
              Focus(
                onFocusChange: (focused) => setState(() => _isTitleFocused = focused),
                child: Container(
                  decoration: BoxDecoration(
                    color: NovaTheme.surfaceLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      bottom: BorderSide(
                        color: _isTitleFocused ? NovaTheme.primary : Colors.white10,
                        width: _isTitleFocused ? 2.0 : 1.0,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _titleController,
                    autofocus: true,
                    maxLength: 255,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'What needs to be focused on?',
                      hintStyle: TextStyle(color: Colors.white.withAlpha(76)),
                      counterText: '', // Hide the counter
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Priority ─────────────────────────────────────────────
              _sectionLabel('Priority'),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildPriorityChip(TaskPriority.urgent, 'Urgent', NovaTheme.primary),
                  const SizedBox(width: 12),
                  _buildPriorityChip(TaskPriority.medium, 'Medium', NovaTheme.tertiary),
                  const SizedBox(width: 12),
                  _buildPriorityChip(TaskPriority.low, 'Low', NovaTheme.secondary),
                ],
              ),
              const SizedBox(height: 24),

              // ── Category ─────────────────────────────────────────────
              _sectionLabel('Category'),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildCategoryChip('Work', Icons.work_outline_rounded),
                  const SizedBox(width: 12),
                  _buildCategoryChip('Personal', Icons.person_outline_rounded),
                  const SizedBox(width: 12),
                  _buildCategoryChip('Health', Icons.favorite_border_rounded),
                ],
              ),
              const SizedBox(height: 24),

              // ── Due Date + Time ───────────────────────────────────────
              _sectionLabel('Due Date & Time'),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Date picker button
                  Expanded(
                    child: _pickerButton(
                      icon: Icons.calendar_today_rounded,
                      label: _selectedDate == null
                          ? 'Pick Date'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      accentColor: NovaTheme.secondary,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Time picker button
                  Expanded(
                    child: _pickerButton(
                      icon: Icons.access_time_rounded,
                      label: _selectedTime.format(context),
                      accentColor: NovaTheme.tertiary,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Notify Before ────────────────────────────────────────
              _sectionLabel('Remind Me Before'),
              const SizedBox(height: 4),
              Text(
                'Get a notification before the task is due',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withAlpha(100),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _notifyOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final option = _notifyOptions[i];
                    final isSelected = _selectedNotifyBefore == option;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedNotifyBefore = option),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? NovaTheme.primary.withAlpha(50)
                              : Colors.white.withAlpha(10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? NovaTheme.primary : Colors.white.withAlpha(20),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _notifyLabels[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? NovaTheme.primary : Colors.white60,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // ── Submit button ────────────────────────────────────────
              NeonButton(
                width: double.infinity,
                buttonColor: NovaTheme.primary,
                glowColor: NovaTheme.primary,
                onPressed: _submit,
                child: const Text(
                  'Create Reminder',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => _darkDatePickerTheme(ctx, child),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => _darkTimePickerTheme(ctx, child),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }
    final dueTimeStr = _selectedTime.format(context);
    Provider.of<TaskProvider>(context, listen: false).addTask(
      title,
      _selectedPriority,
      _selectedCategory,
      dueTimeStr,
      dueDate: _selectedDate,
      notifyBeforeMinutes: _selectedNotifyBefore,
    );
    Navigator.of(context).pop();
  }

  // ── UI helpers ────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: NovaTheme.onSurfaceVariant,
      ),
    );
  }

  Widget _pickerButton({
    required IconData icon,
    required String label,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: accentColor.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withAlpha(80), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: accentColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority, String label, Color color) {
    final isSelected = _selectedPriority == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = priority),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(38) : Colors.white.withAlpha(5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.white.withAlpha(13),
              width: 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.white.withAlpha(128),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, IconData icon) {
    final isSelected = _selectedCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? NovaTheme.secondary.withAlpha(38)
                : Colors.white.withAlpha(5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? NovaTheme.secondary : Colors.white.withAlpha(13),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? NovaTheme.secondary
                    : Colors.white.withAlpha(128),
              ),
              const SizedBox(width: 6),
              Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? NovaTheme.secondary
                      : Colors.white.withAlpha(128),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _darkDatePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: NovaTheme.primary,
          onPrimary: Colors.black,
          surface: Color(0xFF1C1C2E),
          onSurface: Colors.white,
        ),
      ),
      child: child!,
    );
  }

  Widget _darkTimePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: NovaTheme.tertiary,
          onPrimary: Colors.black,
          surface: Color(0xFF1C1C2E),
          onSurface: Colors.white,
        ),
      ),
      child: child!,
    );
  }
}
