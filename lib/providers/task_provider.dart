import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskCategory {
  final String name;
  final int taskCount;
  final Color color;
  final IconData icon;

  const TaskCategory({
    required this.name,
    required this.taskCount,
    required this.color,
    required this.icon,
  });
}

class CalendarEvent {
  final String id;
  final String title;
  final String timeRange;
  final String category;
  final bool isCritical;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.timeRange,
    required this.category,
    this.isCritical = false,
  });
}

class TaskProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  User? _currentUser;
  bool _isLoading = false;

  // Master categories definitions
  final List<TaskCategory> _categories = [
    const TaskCategory(name: 'Work', taskCount: 0, color: Colors.blue, icon: Icons.work_rounded),
    const TaskCategory(name: 'Study', taskCount: 0, color: Colors.purple, icon: Icons.school_rounded),
    const TaskCategory(name: 'Health', taskCount: 0, color: Color(0xFF10B981), icon: Icons.favorite_rounded),
    const TaskCategory(name: 'Personal', taskCount: 0, color: Colors.yellow, icon: Icons.person_rounded),
    const TaskCategory(name: 'Shopping', taskCount: 0, color: Colors.orange, icon: Icons.shopping_bag_rounded),
    const TaskCategory(name: 'Finance', taskCount: 0, color: Colors.cyan, icon: Icons.account_balance_wallet_rounded),
    const TaskCategory(name: 'Fitness', taskCount: 0, color: Colors.red, icon: Icons.fitness_center_rounded),
    const TaskCategory(name: 'Travel', taskCount: 0, color: Colors.teal, icon: Icons.flight_rounded),
  ];

  // In-memory lists (synced with local cache and Supabase)
  final List<Task> _tasks = [];
  final List<CalendarEvent> _agendaEvents = [];
  final List<FocusSession> _focusSessions = [];

  // User Stats (synced with Supabase user_stats)
  int _totalCompletedTasks = 0;
  int _streakDays = 0;
  int _efficiency = 0;
  Map<String, int> _dailyCompletions = {};

  // Focus Analytics
  int _focusScore = 0;
  int _currentFocusStreak = 0;
  int _longestFocusStreak = 0;

  // Timer state (Focus Mode)
  Timer? _timer;
  Timer? _uiRefreshTimer;
  int _timerSecondsRemaining = 25 * 60; // default, but will be set by user
  int _initialTimerDurationMinutes = 25;
  bool _isTimerActive = false;
  Task? _focusTask;
  String _focusSessionType = 'Focus Session';

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  User? get currentUser => _currentUser;

  // Expose username dynamically from metadata
  String get displayName {
    final metadataName = _currentUser?.userMetadata?['display_name'];
    if (metadataName != null && metadataName.toString().trim().isNotEmpty) {
      return metadataName.toString();
    }
    return _currentUser?.email?.split('@')[0] ?? 'User';
  }

  // Calculate task counts per category dynamically based on active (incomplete) tasks
  List<TaskCategory> get categories {
    final Map<String, int> counts = {};
    for (var task in _tasks) {
      if (!task.isCompleted) {
        counts[task.category] = (counts[task.category] ?? 0) + 1;
      }
    }
    return _categories.map((cat) {
      return TaskCategory(
        name: cat.name,
        taskCount: counts[cat.name] ?? 0,
        color: cat.color,
        icon: cat.icon,
      );
    }).toList();
  }

  List<Task> get tasks => _tasks;
  List<FocusSession> get focusSessions => _focusSessions;

  int _compareTasks(Task a, Task b) {
    if (a.fullDueDateTime != null && b.fullDueDateTime != null) {
      final dateCompare = a.fullDueDateTime!.compareTo(b.fullDueDateTime!);
      if (dateCompare != 0) {
        return dateCompare;
      }
    } else if (a.fullDueDateTime != null && b.fullDueDateTime == null) {
      return -1; // tasks with due date come first
    } else if (a.fullDueDateTime == null && b.fullDueDateTime != null) {
      return 1;
    }
    // If due dates are the same or both null, sort by priority
    return a.priority.index.compareTo(b.priority.index);
  }

  List<Task> get activeTasks {
    final now = DateTime.now();
    final list = _tasks.where((t) {
      if (t.isCompleted) return false;
      if (t.fullDueDateTime != null && t.fullDueDateTime!.isBefore(now)) return false;
      return true;
    }).toList();
    list.sort(_compareTasks);
    return list;
  }

  List<Task> get completedTasks {
    return _tasks.where((t) => t.isCompleted).toList();
  }

  List<Task> get incompleteTasks {
    final now = DateTime.now();
    final list = _tasks.where((t) {
      if (t.isCompleted) return false;
      if (t.fullDueDateTime != null && t.fullDueDateTime!.isBefore(now)) return true;
      return false;
    }).toList();
    list.sort(_compareTasks);
    return list;
  }
  List<CalendarEvent> get agendaEvents => _agendaEvents;
  int get totalCompletedTasks => _totalCompletedTasks;
  int get streakDays => _streakDays;
  int get efficiency => _efficiency;

  // Focus Analytics Getters
  int get focusScore => _focusScore;
  int get currentFocusStreak => _currentFocusStreak;
  int get longestFocusStreak => _longestFocusStreak;

  String get focusLevel {
    if (_focusScore >= 3000) return 'Focus Master';
    if (_focusScore >= 1001) return 'Expert';
    if (_focusScore >= 501) return 'Productive';
    if (_focusScore >= 101) return 'Consistent';
    return 'Beginner';
  }

  List<double> get weeklyFocusScores {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final Map<int, int> pointsPerDayOffset = {};
    for (var session in _focusSessions) {
      final sessionDay = DateTime(session.createdAt.year, session.createdAt.month, session.createdAt.day);
      final difference = today.difference(sessionDay).inDays;
      if (difference >= 0 && difference < 7) {
        pointsPerDayOffset[difference] = (pointsPerDayOffset[difference] ?? 0) + session.pointsEarned;
      }
    }

    final List<double> scores = List.filled(7, 0.0);
    int runningScore = _focusScore;
    
    for (int i = 0; i < 7; i++) {
      scores[6 - i] = runningScore.toDouble();
      runningScore -= (pointsPerDayOffset[i] ?? 0);
      if (runningScore < 0) runningScore = 0;
    }
    
    return scores;
  }

  Map<String, dynamic> get sessionStatistics {
    int total = _focusSessions.length;
    int success = 0;
    int failed = 0;
    int quit = 0;
    int totalMinutes = 0;

    for (var s in _focusSessions) {
      if (s.wasSuccessful) {
        success++;
      } else if (s.pointsEarned <= -10) {
        failed++;
      } else if (s.pointsEarned == -5) {
        quit++;
      } else {
        failed++;
      }
      totalMinutes += s.durationMinutes;
    }

    double successRate = total == 0 ? 0 : (success / total) * 100;
    double avgDuration = total == 0 ? 0 : (totalMinutes / total);

    return {
      'total': total,
      'success': success,
      'failed': failed,
      'quit': quit,
      'successRate': successRate,
      'avgDuration': avgDuration,
      'totalHours': totalMinutes / 60.0,
    };
  }

  // Real data metrics replacing streak/efficiency
  int get taskDebt => incompleteTasks.length;

  double get onTimeCompletionRate {
    final completed = completedTasks.length;
    final missed = incompleteTasks.length;
    if (completed + missed == 0) return 1.0; // 100% default
    return completed / (completed + missed);
  }

  List<double> get weeklyMissedPoints {
    final now = DateTime.now();
    final currentDayOfWeek = now.weekday;
    final monday = now.subtract(Duration(days: currentDayOfWeek - 1));
    
    final List<double> points = [];
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      
      // Count incomplete tasks due on this day
      final count = incompleteTasks.where((t) {
        if (t.fullDueDateTime == null) return false;
        return t.fullDueDateTime!.year == day.year && 
               t.fullDueDateTime!.month == day.month && 
               t.fullDueDateTime!.day == day.day;
      }).length;
      
      points.add((count * 5.0).clamp(0.0, 40.0));
    }
    return points;
  }

  // Weekly Activity Graph data points (calculated dynamically based on completions)
  List<double> get weeklyActivityPoints {
    final now = DateTime.now();
    // Find the Monday of the current week
    final currentDayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday
    final monday = now.subtract(Duration(days: currentDayOfWeek - 1));
    
    final List<double> points = [];
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final dateKey = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final count = _dailyCompletions[dateKey] ?? 0;
      
      // Scale count for graph (e.g., 1 task = 5 units, max 40)
      points.add((count * 5.0).clamp(0.0, 40.0));
    }
    
    return points;
  }

  double get completionPercentage {
    if (_tasks.isEmpty) return 0.0;
    final completedCount = _tasks.where((task) => task.isCompleted).length;
    return completedCount / _tasks.length;
  }

  int get currentCompletedCount => _tasks.where((task) => task.isCompleted).length;

  // Timer Getters
  int get timerSecondsRemaining => _timerSecondsRemaining;
  bool get isTimerActive => _isTimerActive;
  Task? get focusTask => _focusTask;
  String get focusSessionType => _focusSessionType;

  String get timerString {
    final minutes = (_timerSecondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timerSecondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  TaskProvider() {
    _initSupabaseAuth();
    // Periodically refresh the UI so overdue tasks automatically move to incomplete list
    _uiRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      notifyListeners();
    });
  }

  void _initSupabaseAuth() {
    // Load local cache immediately for instant startup
    _loadFromCache();

    _currentUser = _client.auth.currentUser;
    if (_currentUser != null) {
      _fetchUserData();
    }

    _client.auth.onAuthStateChange.listen((data) {
      final oldUser = _currentUser;
      _currentUser = data.session?.user;
      
      if (_currentUser != null && oldUser?.id != _currentUser?.id) {
        _fetchUserData();
      } else if (_currentUser == null) {
        _clearUserData();
        _clearCache();
        notifyListeners();
      }
    });
  }

  // ==========================================
  // Local Caching (SharedPreferences)
  // ==========================================

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load user stats
      final statsJson = prefs.getString('cached_user_stats');
      if (statsJson != null) {
        final Map<String, dynamic> stats = jsonDecode(statsJson);
        _streakDays = stats['streak_days'] ?? 0;
        _totalCompletedTasks = stats['total_completed_tasks'] ?? 0;
        _efficiency = stats['efficiency'] ?? 0;
        if (stats['daily_completions'] != null) {
          _dailyCompletions = Map<String, int>.from(stats['daily_completions']);
        }
      }

      // Load tasks
      final tasksJson = prefs.getString('cached_tasks');
      if (tasksJson != null) {
        final List<dynamic> decoded = jsonDecode(tasksJson);
        _tasks.clear();
        for (var item in decoded) {
          _tasks.add(Task(
            id: item['id'],
            title: item['title'],
            priority: _parsePriority(item['priority']),
            category: item['category'],
            dueTime: item['due_time'],
            dueDate: item['due_date'] != null
                ? DateTime.tryParse(item['due_date'])
                : null,
            notifyBeforeMinutes: item['notify_before_minutes'] as int?,
            isCompleted: item['is_completed'],
          ));
        }
      }

      // Load calendar events
      final eventsJson = prefs.getString('cached_events');
      if (eventsJson != null) {
        final List<dynamic> decoded = jsonDecode(eventsJson);
        _agendaEvents.clear();
        for (var item in decoded) {
          _agendaEvents.add(CalendarEvent(
            id: item['id'],
            title: item['title'],
            timeRange: item['time_range'],
            category: item['category'],
            isCritical: item['is_critical'],
          ));
        }
      }

      _updateFocusTask();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading from SharedPreferences cache: $e');
    }
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save stats
      final statsJson = jsonEncode({
        'streak_days': _streakDays,
        'total_completed_tasks': _totalCompletedTasks,
        'efficiency': _efficiency,
        'daily_completions': _dailyCompletions,
      });
      await prefs.setString('cached_user_stats', statsJson);

      // Save tasks
      final List<Map<String, dynamic>> serializedTasks = _tasks.map((task) => {
        'id': task.id,
        'title': task.title,
        'priority': _serializePriority(task.priority),
        'category': task.category,
        'due_time': task.dueTime,
        'due_date': task.dueDate?.toIso8601String(),
        'notify_before_minutes': task.notifyBeforeMinutes,
        'is_completed': task.isCompleted,
      }).toList();
      await prefs.setString('cached_tasks', jsonEncode(serializedTasks));

      // Save events
      final List<Map<String, dynamic>> serializedEvents = _agendaEvents.map((event) => {
        'id': event.id,
        'title': event.title,
        'time_range': event.timeRange,
        'category': event.category,
        'is_critical': event.isCritical,
      }).toList();
      await prefs.setString('cached_events', jsonEncode(serializedEvents));
    } catch (e) {
      debugPrint('Error saving to SharedPreferences cache: $e');
    }
  }

  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_user_stats');
      await prefs.remove('cached_tasks');
      await prefs.remove('cached_events');
    } catch (e) {
      debugPrint('Error clearing SharedPreferences cache: $e');
    }
  }

  // ==========================================
  // Cloud Database Sync (Supabase)
  // ==========================================

  Future<void> _fetchUserData() async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Tasks
      final tasksResponse = await _client
          .from('tasks')
          .select()
          .eq('user_id', _currentUser!.id)
          .order('created_at', ascending: true);

      _tasks.clear();
      for (var taskData in tasksResponse) {
        _tasks.add(Task(
          id: taskData['id'].toString(),
          title: taskData['title'].toString(),
          priority: _parsePriority(taskData['priority'].toString()),
          category: taskData['category'].toString(),
          dueTime: taskData['due_time'].toString(),
          dueDate: taskData['due_date'] != null
              ? DateTime.tryParse(taskData['due_date'].toString())
              : null,
          notifyBeforeMinutes: taskData['notify_before_minutes'] as int?,
          isCompleted: taskData['is_completed'] as bool,
        ));
      }
      // Re-schedule notifications for all incomplete tasks with future due dates
      for (final task in _tasks) {
        if (!task.isCompleted && task.fullDueDateTime != null &&
            task.fullDueDateTime!.isAfter(DateTime.now())) {
          NotificationService().scheduleTaskReminder(task);
        }
      }

      // 2. Fetch Calendar Events
      final eventsResponse = await _client
          .from('calendar_events')
          .select()
          .eq('user_id', _currentUser!.id)
          .order('created_at', ascending: true);

      _agendaEvents.clear();
      for (var eventData in eventsResponse) {
        _agendaEvents.add(CalendarEvent(
          id: eventData['id'].toString(),
          title: eventData['title'].toString(),
          timeRange: eventData['time_range'].toString(),
          category: eventData['category'].toString(),
          isCritical: eventData['is_critical'] as bool,
        ));
      }

      // 3. Fetch Focus Sessions
      final sessionsResponse = await _client
          .from('focus_sessions')
          .select()
          .eq('user_id', _currentUser!.id)
          .order('created_at', ascending: true);

      _focusSessions.clear();
      for (var sessionData in sessionsResponse) {
        _focusSessions.add(FocusSession.fromJson(sessionData));
      }

      // 4. Fetch User Stats
      final statsResponse = await _client
          .from('user_stats')
          .select()
          .eq('user_id', _currentUser!.id)
          .maybeSingle();

      if (statsResponse != null) {
        _streakDays = (statsResponse['streak_days'] as num?)?.toInt() ?? 0;
        _totalCompletedTasks = (statsResponse['total_completed_tasks'] as num?)?.toInt() ?? 0;
        _efficiency = (statsResponse['efficiency'] as num?)?.toInt() ?? 0;
        _focusScore = (statsResponse['focus_score'] as num?)?.toInt() ?? 0;
        _currentFocusStreak = (statsResponse['current_focus_streak'] as num?)?.toInt() ?? 0;
        _longestFocusStreak = (statsResponse['longest_focus_streak'] as num?)?.toInt() ?? 0;
      }

      _updateFocusTask();
      await _saveToCache();
    } catch (e) {
      debugPrint('Error fetching user data from Supabase: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearUserData() {
    _tasks.clear();
    _agendaEvents.clear();
    _focusSessions.clear();
    _streakDays = 0;
    _totalCompletedTasks = 0;
    _efficiency = 0;
    _focusScore = 0;
    _currentFocusStreak = 0;
    _longestFocusStreak = 0;
    _dailyCompletions.clear();
    _focusTask = null;
  }

  TaskPriority _parsePriority(String priorityStr) {
    switch (priorityStr.toLowerCase()) {
      case 'urgent':
        return TaskPriority.urgent;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
      default:
        return TaskPriority.low;
    }
  }

  String _serializePriority(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return 'urgent';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.low:
        return 'low';
    }
  }

  void _updateFocusTask() {
    if (_tasks.isNotEmpty) {
      final incomplete = _tasks.where((t) => !t.isCompleted).toList();
      _focusTask = incomplete.isNotEmpty ? incomplete.first : _tasks.first;
    } else {
      _focusTask = null;
    }
  }

  // ==========================================
  // Actions
  // ==========================================

  Future<void> updateDisplayName(String name) async {
    if (_currentUser == null) return;
    try {
      await _client.auth.updateUser(UserAttributes(data: {'display_name': name}));
      _currentUser = _client.auth.currentUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating display name: $e');
    }
  }

  Future<void> addTask(
    String title,
    TaskPriority priority,
    String category,
    String dueTime, {
    DateTime? dueDate,
    int? notifyBeforeMinutes,
  }) async {
    final dueText = dueTime.isEmpty ? 'Anytime' : dueTime;
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    // Optimistically update memory list & local cache
    final newTask = Task(
      id: tempId,
      title: title,
      priority: priority,
      category: category,
      dueTime: dueText,
      dueDate: dueDate,
      notifyBeforeMinutes: notifyBeforeMinutes,
    );
    _tasks.add(newTask);
    if (_focusTask == null) _focusTask = newTask;
    await _saveToCache();
    notifyListeners();

    // Schedule notification for the temp task (will be re-scheduled with real ID)
    if (newTask.fullDueDateTime != null) {
      await NotificationService().scheduleTaskReminder(newTask);
    }

    // Sync in background if authenticated
    if (_currentUser != null) {
      try {
        final taskMap = {
          'user_id': _currentUser!.id,
          'title': title,
          'priority': _serializePriority(priority),
          'category': category,
          'due_time': dueText,
          'is_completed': false,
          if (dueDate != null)
            'due_date':
                '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
          if (notifyBeforeMinutes != null)
            'notify_before_minutes': notifyBeforeMinutes,
        };

        final response = await _client
            .from('tasks')
            .insert(taskMap)
            .select()
            .single();

        // Cancel temp notification and re-schedule with real DB id
        await NotificationService().cancelTaskNotifications(tempId);

        final realTask = Task(
          id: response['id'].toString(),
          title: title,
          priority: priority,
          category: category,
          dueTime: dueText,
          dueDate: dueDate,
          notifyBeforeMinutes: notifyBeforeMinutes,
        );

        if (realTask.fullDueDateTime != null) {
          await NotificationService().scheduleTaskReminder(realTask);
        }

        // Swap temporary local ID with actual database ID
        final idx = _tasks.indexWhere((t) => t.id == tempId);
        if (idx != -1) {
          _tasks[idx] = realTask;
          _updateFocusTask();
          await _saveToCache();
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error inserting task to Supabase: $e');
      }
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final targetCompletion = !task.isCompleted;

      // Optimistically update memory lists & local cache
      task.isCompleted = targetCompletion;
      
      final now = DateTime.now();
      final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      if (task.isCompleted) {
        _totalCompletedTasks++;
        _dailyCompletions[dateKey] = (_dailyCompletions[dateKey] ?? 0) + 1;
        // Cancel pending notifications when task is marked complete
        await NotificationService().cancelTaskNotifications(id);
      } else {
        _totalCompletedTasks--;
        if (_dailyCompletions.containsKey(dateKey) && _dailyCompletions[dateKey]! > 0) {
          _dailyCompletions[dateKey] = _dailyCompletions[dateKey]! - 1;
        }
        // Re-schedule if un-completed and has a future due date
        if (task.fullDueDateTime != null &&
            task.fullDueDateTime!.isAfter(DateTime.now())) {
          await NotificationService().scheduleTaskReminder(task);
        }
      }

      if (_focusTask?.id == id && task.isCompleted) {
        _moveToNextFocusTask();
      }
      await _saveToCache();
      notifyListeners();

      // Sync in background if authenticated
      if (_currentUser != null) {
        try {
          await _client
              .from('tasks')
              .update({'is_completed': targetCompletion})
              .eq('id', id);

          await _syncStats();
        } catch (e) {
          debugPrint('Error updating task completion in Supabase: $e');
        }
      }
    }
  }

  Future<void> deleteTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];

      // Cancel any scheduled notifications for this task
      await NotificationService().cancelTaskNotifications(id);

      // Optimistically update memory lists & local cache
      if (task.isCompleted) {
        _totalCompletedTasks--;
      }
      _tasks.removeAt(index);
      if (_focusTask?.id == id) {
        _moveToNextFocusTask();
      }
      await _saveToCache();
      notifyListeners();

      // Sync in background if authenticated
      if (_currentUser != null) {
        try {
          await _client
              .from('tasks')
              .delete()
              .eq('id', id);

          await _syncStats();
        } catch (e) {
          debugPrint('Error deleting task from Supabase: $e');
        }
      }
    }
  }

  Future<void> _syncStats() async {
    if (_currentUser == null) return;
    try {
      await _client
          .from('user_stats')
          .update({
            'streak_days': _streakDays,
            'total_completed_tasks': _totalCompletedTasks,
            'efficiency': _efficiency,
            'focus_score': _focusScore,
            'current_focus_streak': _currentFocusStreak,
            'longest_focus_streak': _longestFocusStreak,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('user_id', _currentUser!.id);
    } catch (e) {
      debugPrint('Error syncing stats to Supabase: $e');
    }
  }

  void setFocusTask(Task task) {
    _focusTask = task;
    notifyListeners();
  }

  void _moveToNextFocusTask() {
    final nextTasks = _tasks.where((task) => !task.isCompleted && task.id != _focusTask?.id).toList();
    if (nextTasks.isNotEmpty) {
      _focusTask = nextTasks.first;
    } else {
      _focusTask = null;
    }
  }

  void setTimerDuration(int minutes) {
    _initialTimerDurationMinutes = minutes;
    _timerSecondsRemaining = minutes * 60;
    notifyListeners();
  }

  void startTimer() {
    if (_isTimerActive || _focusTask == null) return;
    _isTimerActive = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSecondsRemaining > 0) {
        _timerSecondsRemaining--;
        notifyListeners();
      } else {
        // Auto-complete if timer hits 0 naturally (failed to finish in time)
        completeFocusSession(success: false, isTimerExpired: true);
      }
    });
  }

  void pauseTimer() {
    _isTimerActive = false;
    _timer?.cancel();
    notifyListeners();
  }

  Future<void> quitTimer() async {
    pauseTimer();
    await completeFocusSession(success: false, isQuit: true);
  }

  Future<void> completeFocusSession({required bool success, bool isTimerExpired = false, bool isQuit = false}) async {
    pauseTimer();
    final task = _focusTask;
    final duration = _initialTimerDurationMinutes;
    _focusTask = null;
    _timerSecondsRemaining = 25 * 60; // reset default
    
    int points = 0;
    if (success) {
      points += 10;
      if (task?.priority == TaskPriority.urgent) points += 20;
      _currentFocusStreak++;
      if (_currentFocusStreak > 1) points += 5; // Streak bonus
      if (_currentFocusStreak > _longestFocusStreak) _longestFocusStreak = _currentFocusStreak;
    } else {
      _currentFocusStreak = 0;
      if (isTimerExpired) points -= 10;
      if (isQuit) points -= 5;
    }
    
    _focusScore += points;
    if (_focusScore < 0) _focusScore = 0;
    
    notifyListeners();

    if (task != null) {
      // 1. Record the session
      final session = FocusSession(
        id: '', // Supabase will generate UUID
        taskId: task.id,
        durationMinutes: duration,
        wasSuccessful: success,
        createdAt: DateTime.now(),
        pointsEarned: points,
        endTime: DateTime.now(),
      );
      
      _focusSessions.add(session); // Optimistic

      try {
        if (_currentUser != null) {
          final res = await _client.from('focus_sessions').insert({
            'user_id': _currentUser!.id,
            'task_id': task.id,
            'duration_minutes': duration,
            'was_successful': success,
            'points_earned': points,
            'end_time': DateTime.now().toUtc().toIso8601String(),
          }).select().single();
          
          // Replace optimistic entry with DB entry
          _focusSessions.remove(session);
          _focusSessions.add(FocusSession.fromJson(res));
          
          await _syncStats();
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error saving focus session: $e');
      }

      // 2. If successful, mark task completed
      if (success && !task.isCompleted) {
        await toggleTaskCompletion(task.id);
      }
    }
  }

  void skipFocusTask() {
    _moveToNextFocusTask();
    _timerSecondsRemaining = _initialTimerDurationMinutes * 60;
    notifyListeners();
  }
  void resetTimer() {
    pauseTimer();
    _timerSecondsRemaining = 25 * 60;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _uiRefreshTimer?.cancel();
    super.dispose();
  }
}
