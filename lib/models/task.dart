enum TaskPriority { urgent, medium, low }

class Task {
  final String id;
  final String title;
  final TaskPriority priority;
  final String category;
  final String dueTime;
  final DateTime? dueDate;
  final int? notifyBeforeMinutes; // minutes before due datetime to notify
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.category,
    required this.dueTime,
    this.dueDate,
    this.notifyBeforeMinutes,
    this.isCompleted = false,
  });

  /// Returns the full due DateTime combining dueDate + dueTime (parsed).
  /// Returns null if dueDate is not set.
  DateTime? get fullDueDateTime {
    if (dueDate == null) return null;
    try {
      // dueTime is formatted like "8:30 PM"
      final parts = dueTime.split(':');
      if (parts.length < 2) return null;
      int hour = int.parse(parts[0].trim());
      final minAndPeriod = parts[1].trim().split(' ');
      final int minute = int.parse(minAndPeriod[0]);
      final String period = minAndPeriod.length > 1 ? minAndPeriod[1].toUpperCase() : '';
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return DateTime(
        dueDate!.year,
        dueDate!.month,
        dueDate!.day,
        hour,
        minute,
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns the DateTime when a pre-reminder should fire.
  DateTime? get reminderDateTime {
    final due = fullDueDateTime;
    if (due == null || notifyBeforeMinutes == null) return null;
    return due.subtract(Duration(minutes: notifyBeforeMinutes!));
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.urgent:
        return 'Urgent';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  String get formattedDueDate {
    if (dueDate == null) return 'No Date';
    return '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
  }
}

class FocusSession {
  final String id;
  final String taskId;
  final int durationMinutes;
  final bool wasSuccessful;
  final DateTime createdAt;
  final int pointsEarned;
  final DateTime? endTime;

  FocusSession({
    required this.id,
    required this.taskId,
    required this.durationMinutes,
    required this.wasSuccessful,
    required this.createdAt,
    this.pointsEarned = 0,
    this.endTime,
  });

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] ?? '',
      taskId: json['task_id'] ?? '',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 25,
      wasSuccessful: json['was_successful'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : DateTime.now(),
      pointsEarned: (json['points_earned'] as num?)?.toInt() ?? 0,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']).toLocal() : null,
    );
  }
}
