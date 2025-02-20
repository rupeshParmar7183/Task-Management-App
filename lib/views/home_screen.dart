// Import necessary packages for UI, state management, models, and unique id generation.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/models/user_preferences.dart';
import 'package:task_management_app/viewmodels/settings_viewmodel.dart';
import 'package:task_management_app/viewmodels/task_viewmdel.dart'; // Provides task state management.
import 'package:task_management_app/widgets/task_item.dart'; // Custom widget for displaying individual tasks.
import '../models/task_model.dart';
import 'package:uuid/uuid.dart'; // For generating unique ids.

/// HomeScreen widget that displays the list of tasks and provides options for searching, sorting, and toggling dark mode.
/// Uses ConsumerWidget from Riverpod for state management.
class HomeScreen extends ConsumerWidget {
  // Create a Uuid instance to generate unique identifiers if needed.
  final uuid = Uuid();

  // Controller for the search text field.
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the taskProvider for the list of tasks.
    final tasks = ref.watch(taskProvider);
    // Determine if the current theme is dark.
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Read user preferences from settingsProvider.
    final userPreferences = ref.read(settingsProvider);
    return Scaffold(
      appBar: AppBar(
        // App title with color adjustment based on theme.
        title: Text('Task Management',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        actions: [
          // Button to toggle between dark and light mode.
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => ref.read(settingsProvider.notifier).toggleSetting(
                // Toggle the dark mode setting while preserving the sort order.
                userPreferences: UserPreferences(
                    isDarkMode: !userPreferences.isDarkMode,
                    sortOrder: userPreferences.sortOrder)),
          ),
          // The following commented-out block is an alternative sorting method using a PopupMenuButton.
          // PopupMenuButton<String>(
          //   color: isDarkMode ? Colors.grey[900] : Colors.white,
          //   onSelected: (value) {
          //     ref.read(taskProvider.notifier).sortTasks(value);
          //   },
          //   itemBuilder: (context) => [
          //     PopupMenuItem(
          //         value: 'date',
          //         child: Text('Sort by Date',
          //             style: TextStyle(
          //                 color: isDarkMode ? Colors.white : Colors.black))),
          //     PopupMenuItem(
          //         value: 'priority',
          //         child: Text('Sort by Priority',
          //             style: TextStyle(
          //                 color: isDarkMode ? Colors.white : Colors.black))),
          //   ],
          // ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Row for sorting options (by date and by priority).
          Row(
            children: [
              // Icon button to sort tasks by date.
              IconButton(
                  // Highlight button if current sort order is 'date'.
                  color: userPreferences.sortOrder == 'date'
                      ? Colors.redAccent
                      : null,
                  onPressed: () {
                    // Toggle the setting to use 'date' as the sort order.
                    ref.read(settingsProvider.notifier).toggleSetting(
                        userPreferences: UserPreferences(
                            isDarkMode: userPreferences.isDarkMode,
                            sortOrder: "date"));
                    // Sort tasks by date.
                    ref.read(taskProvider.notifier).sortTasks('date');
                  },
                  // Display both an icon and label for clarity.
                  icon: Row(
                    children: [
                      Icon(Icons.calendar_month),
                      Text("Date",
                          style: TextStyle(
                              color: userPreferences.sortOrder == 'date'
                                  ? Colors.redAccent
                                  : null))
                    ],
                  )),
              // Icon button to sort tasks by priority.
              IconButton(
                  // Highlight button if current sort order is 'priority'.
                  color: userPreferences.sortOrder == 'priority'
                      ? Colors.redAccent
                      : null,
                  onPressed: () {
                    // Toggle the setting to use 'priority' as the sort order.
                    ref.read(settingsProvider.notifier).toggleSetting(
                        userPreferences: UserPreferences(
                            isDarkMode: userPreferences.isDarkMode,
                            sortOrder: "priority"));
                    // Sort tasks by priority.
                    ref.read(taskProvider.notifier).sortTasks('priority');
                  },
                  // Display both an icon and label for clarity.
                  icon: Row(
                    children: [
                      Icon(Icons.priority_high),
                      Text("Priority",
                          style: TextStyle(
                              color: userPreferences.sortOrder == 'priority'
                                  ? Colors.redAccent
                                  : null))
                    ],
                  )),
            ],
          ),
          // Search field for filtering tasks by title.
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Search Tasks",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                // On text change, update the task search.
                onChanged: (value) {
                  ref
                      .read(taskProvider.notifier)
                      .searchTaskFromTitle(title: value);
                }),
          ),
          // If no tasks exist, display a "No tasks available" message.
          tasks.isEmpty
              ? Center(
                  child: Text("No tasks available",
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black)))
              // Otherwise, display the list of tasks.
              : Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      // Build each task item using TaskCard widget.
                      return TaskCard(
                        isDarkMode: isDarkMode,
                        task: task,
                        // Open edit dialog when editing a task.
                        onEdit: () => _editTask(context, ref, task, task.id),
                        // Delete the task.
                        onDelete: () =>
                            ref.read(taskProvider.notifier).deleteTask(task.id),
                        // Toggle task completion.
                        onToggleCompletion: () => ref
                            .read(taskProvider.notifier)
                            .toggleTaskCompletion(task),
                      );
                    },
                  ),
                ),
        ],
      ),
      // Floating action button to add a new task.
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () => _addTask(context, ref, tasks.length + 1),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Displays a dialog to add a new task.
  void _addTask(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        ref: ref,
      ),
    );
  }

  /// Displays a dialog to edit an existing task.
  void _editTask(
      BuildContext context, WidgetRef ref, TaskModel task, String id) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: task,
        ref: ref,
      ),
    );
  }
}

/// TaskDialog widget is used for both adding a new task and editing an existing one.
class TaskDialog extends StatefulWidget {
  // The task to be edited; null if adding a new task.
  final TaskModel? task;
  // Reference to the Riverpod widget for state management.
  final WidgetRef ref;

  TaskDialog({this.task, required this.ref});

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  // Controllers for title and description input fields.
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  // Variable to hold selected due date.
  DateTime? _dueDate;
  // Flag to denote if task is completed.
  bool _isCompleted = false;
  // Priority level of the task (0: Low, 1: Medium, 2: High).
  int _priority = 1;
  // Instance for generating unique IDs.
  final uuid = Uuid();

  @override
  void initState() {
    super.initState();
    // If editing an existing task, initialize fields with its values.
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _isCompleted = widget.task!.isCompleted;
      _priority = widget.task!.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the dialog is in editing mode.
    final isEditing = widget.task != null;
    // Check if the task is completed; used to disable editing.
    final isTaskCompleted = widget.task?.isCompleted ?? false;

    return AlertDialog(
      // Set dialog title based on whether the task is being added or edited.
      title: Text(isEditing ? "Task Details" : "Add Task"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TextField for task title.
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Title"),
              // Disable editing if task is already completed.
              enabled: !isTaskCompleted,
            ),
            SizedBox(height: 8),
            // TextField for task description.
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: "Description"),
              // Disable editing if task is already completed.
              enabled: !isTaskCompleted,
            ),
            SizedBox(height: 8),
            // ListTile for selecting due date.
            ListTile(
              // Display due date or prompt if not set.
              title: Text(_dueDate == null
                  ? "Select Due Date"
                  : "Due: ${_dueDate!.toLocal().toString().split(' ')[0]}"),
              trailing: Icon(Icons.calendar_today),
              // Disable due date selection if task is completed.
              onTap: isTaskCompleted
                  ? null
                  : () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _dueDate = picked);
                      }
                    },
            ),
            SizedBox(height: 8),
            // Dropdown to select task priority.
            DropdownButtonFormField<int>(
              value: _priority,
              decoration: InputDecoration(labelText: "Priority"),
              // Disable if task is completed.
              onChanged: isTaskCompleted
                  ? null
                  : (int? newValue) {
                      setState(() {
                        _priority = newValue!;
                      });
                    },
              items: [
                DropdownMenuItem(value: 0, child: Text('Low')),
                DropdownMenuItem(value: 1, child: Text('Medium')),
                DropdownMenuItem(value: 2, child: Text('High')),
              ],
            ),
          ],
        ),
      ),
      actions: [
        // Button to close the dialog.
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        ),
        // Only show Add/Update button if task is not completed.
        if (!isTaskCompleted)
          ElevatedButton(
            onPressed: () {
              // Generate new id for a new task or retain the current id for editing.
              String id = isEditing ? widget.task!.id : uuid.v4();
              // Create a new TaskModel with the provided data.
              final task = TaskModel(
                id: id,
                title: _titleController.text,
                description: _descController.text,
                dueDate: _dueDate ?? DateTime.now(),
                priority: _priority,
                isCompleted: isEditing ? widget.task!.isCompleted : false,
              );
              // Retrieve the task provider to add/update task.
              final provider = widget.ref.read(taskProvider.notifier);
              // Add a new task or update an existing task.
              isEditing ? provider.updateTask(task) : provider.addTask(task);
              // Close the dialog.
              Navigator.pop(context);
            },
            // Button label changes based on the mode.
            child: Text(isEditing ? "Update" : "Add"),
          ),
      ],
    );
  }
}
