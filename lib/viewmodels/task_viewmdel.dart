import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/core/database_helper.dart';
import 'package:logging/logging.dart';
import 'package:task_management_app/services/notification_services.dart';
import '../models/task_model.dart';

class TaskViewModel extends StateNotifier<List<TaskModel>> {
  TaskViewModel() : super([]) {
    _loadTasks();
  }

  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  final Logger _logger = Logger('TaskViewModel');

  Future<void> _loadTasks() async {
    try {
      final tasks = await databaseHelper.fetchTasks();
      state = tasks;
    } catch (e) {
      _logger.severe('Error loading tasks: $e');
    }
  }

  Future<void> searchTaskFromTitle({required String? title}) async {
    try {
      if (title == null || title == "") {
        final tasks = await databaseHelper.fetchTasks();
        state = tasks;
      } else {
        final tasks = await databaseHelper.searchTaskFromTitle(title!);
        state = tasks;
      }
    } catch (e) {
      _logger.severe('Error loading tasks: $e');
    }
  }

  void addTask(TaskModel task) async {
    try {
      state = [...state, task];
      await databaseHelper.insertTask(task);
    } catch (e) {
      _logger.severe('Error adding task: $e');
    }
  }

  void updateTask(TaskModel updatedTask) async {
    try {
      state = state
          .map((task) => task.id == updatedTask.id ? updatedTask : task)
          .toList();
      await databaseHelper.updateTask(updatedTask);
    } catch (e) {
      _logger.severe('Error updating task: $e');
    }
  }

  void deleteTask(String taskId) async {
    try {
      state = state.where((task) => task.id != taskId).toList();
      await databaseHelper.deleteTask(taskId);
    } catch (e) {
      _logger.severe('Error deleting task: $e');
    }
  }

  void toggleTaskCompletion(TaskModel task) async {
    try {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      state = state.map((t) => t.id == task.id ? updatedTask : t).toList();
      await databaseHelper.updateTask(updatedTask);

      if (updatedTask.isCompleted) {
        // Cancel the notification if task is marked as completed.
        NotificationService.cancelNotification(updatedTask.id.hashCode);
        NotificationService.scheduleNotification(
            id: updatedTask.id.hashCode,
            title: 'Task Completed',
            body: 'Your task "${updatedTask.title}" is completed.',
            scheduledTime: DateTime.now(),
            currentNotification: true);
      } else if (updatedTask.dueDate.isAfter(DateTime.now())) {
        // Re-schedule if task becomes uncompleted.
        NotificationService.scheduleNotification(
            id: updatedTask.id.hashCode,
            title: 'Task Due',
            body: 'Your task "${updatedTask.title}" is due today.',
            scheduledTime: updatedTask.dueDate,
            currentNotification: false);
      }
    } catch (e) {
      _logger.severe('Error toggling task completion: $e');
    }
  }

  void sortTasks(String criteria) {
    if (criteria == 'date') {
      state = [...state]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (criteria == 'priority') {
      state = [...state]..sort((a, b) => a.priority.compareTo(b.priority));
    }
  }
}

final taskProvider =
    StateNotifierProvider<TaskViewModel, List<TaskModel>>((ref) {
  return TaskViewModel();
});
