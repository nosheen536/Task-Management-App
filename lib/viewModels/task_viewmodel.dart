import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task_management_app/models/task_model.dart';
import '../services/task_service.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> allTasks = [];
  String searchQuery = '';
  String filterStatus = 'All'; // All, Pending, In Progress, Overdue, Completed
  DateTime selectedDate = DateTime.now();

  StreamSubscription<List<Task>>? _taskSubscription;

  // Start listening with current userId
  void listenToTasks(String userId) {
    _taskSubscription = _taskService.getUserTasksStream(userId).listen((tasks) {
      allTasks = tasks;
      notifyListeners();
    });
  }

  // Set selected date for filtering
  void setSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  // Filtered tasks based on search & status
  List<Task> get filteredTasks {
    var filtered = allTasks;
    if (filterStatus != 'All') {
      filtered = filtered.where((t) => t.status == filterStatus).toList();
    }
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((t) => t.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    return filtered;
  }

  // Tasks for selected date and status
  List<Task> getTasksForDateAndStatus(DateTime date, String status) {
    return allTasks.where((t) =>
        t.dueDate.year == date.year &&
        t.dueDate.month == date.month &&
        t.dueDate.day == date.day &&
        t.status == status).toList();
  }

  // Today's pending or in progress tasks
  List<Task> get todayPendingTasks {
    final today = DateTime.now();
    return allTasks.where((t) =>
        t.dueDate.year == today.year &&
        t.dueDate.month == today.month &&
        t.dueDate.day == today.day &&
        (t.status == 'Pending' || t.status == 'In Progress')).toList();
  }

  // Ongoing tasks (regardless of date)
  List<Task> get ongoingTasks {
    return allTasks.where((t) => t.status == 'In Progress').toList();
  }


  // Pie chart data
  Map<String, double> get pieChartData {
    final completed = allTasks.where((t) => t.isCompleted).length.toDouble();
    final pending = allTasks.where((t) => t.status == 'Pending').length.toDouble();
    final inProgress = allTasks.where((t) => t.status == 'In Progress').length.toDouble();
    

    return {
      "Completed": completed,
      "Pending": pending,
      "In Progress": inProgress,
      
    };
  }

  // Task counts for display
  int get totalTasks => allTasks.length;
  int get completedTasks => allTasks.where((t) => t.isCompleted).length;
  int get pendingTasks => allTasks.where((t) => t.status == 'Pending').length;
  int get inProgressTasks => allTasks.where((t) => t.status == 'In Progress').length;
  int get overdueTasksCount => allTasks.where((t) => t.status == 'Overdue').length;

  // CRUD
  Future<void> addTask(Task task, String userId) async {
    await _taskService.addTask(task, userId);
  }

  Future<void> deleteTask(String id, String userId) async {
    await _taskService.deleteTask(id, userId);
  }

  Future<void> updateTask(Task task, String userId) async {
    await _taskService.updateTask(task, userId);
  }

  Future<void> updateStatus(String id, String status, bool isCompleted, String userId) async {
    await _taskService.updateStatus(id, status, isCompleted, userId);
  }

  // Search & filter setters
  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(String status) {
    filterStatus = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }
}
