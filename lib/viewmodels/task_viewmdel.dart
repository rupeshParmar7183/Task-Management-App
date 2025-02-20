/// ViewModel for managing tasks in the task management app.
/// 
/// This class extends `StateNotifier` to manage the state of a list of `TaskModel` objects.
/// It provides methods to load, search, add, update, delete, and toggle the completion status of tasks.
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

  /// Adds a new task to the current state and inserts it into the database.
  ///
  /// This method updates the current state by adding the provided [task] to the list
  /// of tasks and then attempts to insert the task into the database using the
  /// [databaseHelper]. If an error occurs during the insertion, it logs the error
  /// message.
  ///
  /// [task]: The task to be added.
  ///
  /// Throws:
  /// - Logs an error message if the task insertion fails.
  void addTask(TaskModel task) async {
    try {
      state = [...state, task];
      await databaseHelper.insertTask(task);
    } catch (e) {
      _logger.severe('Error adding task: $e');
    }
  }

  /// Updates an existing task in the state and the database.
  ///
  /// This method takes an updated [TaskModel] object and updates the task
  /// in the state if the task ID matches. It also updates the task in the
  /// database using the [databaseHelper].
  ///
  /// If an error occurs during the update process, it logs the error using
  /// the [_logger].
  ///
  /// [updatedTask] - The task object with updated information.
  void updateTask(TaskModel updatedTask) async {
    // ...
  }

  /// Deletes a task from the state and the database.
  ///
  /// This method takes a task ID and removes the task from the state if the
  /// task ID matches. It also deletes the task from the database using the
  /// [databaseHelper].
  ///
  /// If an error occurs during the deletion process, it logs the error using
  /// the [_logger].
  ///

  void deleteTask(String taskId) async {
    try {
      state = state.where((task) => task.id != taskId).toList();
      await databaseHelper.deleteTask(taskId);
    } catch (e) {
      _logger.severe('Error deleting task: $e');
    }
  }

  /// Toggles the completion status of a given task.
  ///
  /// This method updates the task's completion status, updates the state,
  /// and interacts with the database and notification service accordingly.
  ///
  /// If the task is marked as completed, it cancels any existing notifications
  /// for the task and schedules a new notification indicating the task's completion.
  /// If the task is marked as uncompleted and has a due date in the future,
  /// it re-schedules a notification for the task's due date.
  ///
  /// Throws an error if there is an issue updating the task.
  ///
  /// Parameters:
  /// - `task`: The [TaskModel] instance representing the task to be toggled.
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
          currentNotification: true
        );
      } else if (updatedTask.dueDate.isAfter(DateTime.now())) {
        // Re-schedule if task becomes uncompleted.
        NotificationService.scheduleNotification(
          id: updatedTask.id.hashCode,
          title: 'Task Due',
          body: 'Your task "${updatedTask.title}" is due today.',
          scheduledTime: updatedTask.dueDate,
          currentNotification: false
        );
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
