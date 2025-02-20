import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/models/task_model.dart';
import 'package:confetti/confetti.dart';

/// A widget representing an individual task card with animations,
/// confetti effect, and task actions (edit, delete, toggle completion).
class TaskCard extends StatefulWidget {
  // Task model containing task details.
  final TaskModel task;
  // Flag to indicate if dark mode is enabled.
  final bool isDarkMode;
  // Callback triggered when the task needs to be edited.
  final VoidCallback onEdit;
  // Callback triggered when the task is deleted.
  final VoidCallback onDelete;
  // Callback triggered when the task's completion status is toggled.
  final VoidCallback onToggleCompletion;

  const TaskCard({
    Key? key,
    required this.task,
    required this.isDarkMode,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleCompletion,
  }) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with TickerProviderStateMixin {
  // Animation controller for the insertion animation.
  late final AnimationController _insertController;
  // Slide animation to move the card from a slight offset to its final position.
  late final Animation<Offset> _slideAnimation;
  // Fade animation to gradually display the card.
  late final Animation<double> _fadeAnimation;

  // Controller for the confetti effect when marking a task as complete.
  late final ConfettiController _confettiController;

  // Mapping of integer priorities to their textual representations.
  static const Map<int, String> _priorityText = {
    0: 'Low',
    1: 'Medium',
    2: 'High',
  };

  // Mapping of integer priorities to corresponding colors.
  static const Map<int, Color> _priorityColor = {
    0: Colors.green,
    1: Colors.yellow,
    2: Colors.red,
  };

  @override
  void initState() {
    super.initState();

    // Set up the insertion animation (slide up and fade in).
    _insertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // Start slightly below the final position.
      end: Offset.zero, // End at the final position.
    ).animate(
        CurvedAnimation(parent: _insertController, curve: Curves.easeOut));
    _fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(_insertController); // Fade effect.
    _insertController.forward(); // Start the insertion animation.

    // Initialize the confetti controller (plays for 1 second).
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    // Dispose animation and confetti controllers to free up resources.
    _insertController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// Displays a confirmation dialog before deleting the task.
  Future<void> _confirmDelete() async {
    // Show an alert dialog asking the user to confirm deletion.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          // Confirm deletion.
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
          // Cancel deletion.
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
        ],
      ),
    );
    // If confirmed, immediately trigger the onDelete callback.
    if (confirmed == true) {
      widget.onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the card content with insertion animations (slide & fade).
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Card(
              // Use dark or light color based on the theme.
              color: widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1), // Card border.
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Toggle completion, task title, and priority label.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // GestureDetector for toggling completion and triggering confetti.
                            GestureDetector(
                              onTap: () {
                                // Only play confetti if the task is not already completed.
                                if (!widget.task.isCompleted) {
                                  _confettiController.play();
                                }
                                widget.onToggleCompletion();
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  // Change background color if completed.
                                  color: widget.task.isCompleted
                                      ? Colors.green
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.green, width: 2),
                                ),
                                // Display a check icon if the task is completed.
                                child: widget.task.isCompleted
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 16)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Task title.
                            Text(
                              widget.task.title,
                              style: TextStyle(
                                color: widget.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Display task priority with mapped color and text.
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            // Choose color based on the task's priority.
                            color: widget.task.priority == 0
                                ? Colors.green.shade300
                                : widget.task.priority == 1
                                    ? Colors.yellow.shade700
                                    : widget.task.priority == 2
                                        ? Colors.red.shade400
                                        : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            // Retrieve the textual representation from the map.
                            _priorityText[widget.task.priority] ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Task description.
                    Text(
                      widget.task.description,
                      style: TextStyle(
                        color: widget.isDarkMode
                            ? Colors.white70
                            : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Bottom row: Due date and action buttons (edit, delete).
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Display the due date with an accompanying calendar icon.
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: widget.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Due: ${widget.task.dueDate.toLocal().toString().split(' ')[0]}",
                              style: TextStyle(
                                color: widget.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        // Action buttons: Edit and Delete.
                        Row(
                          children: [
                            // Edit button with tooltip for accessibility.
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: widget.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                              onPressed: widget.onEdit,
                              tooltip: 'Edit Task',
                            ),
                            // Delete button with tooltip; triggers delete confirmation.
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: _confirmDelete,
                              tooltip: 'Delete Task',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Overlay the confetti effect.
            Positioned.fill(
              child: IgnorePointer(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  maxBlastForce: 20,
                  minBlastForce: 5,
                  gravity: 0.3,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.red,
                    Colors.orange,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
