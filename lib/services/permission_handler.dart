import 'package:permission_handler/permission_handler.dart'; // Package to manage app permissions.

/// Requests notification permission from the user.
/// If permission is not granted, it prompts the user to allow notifications.
Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.status; // Gets current notification permission status.
  if (!status.isGranted) {
    await Permission.notification.request(); // Requests notification permission if not already granted.
  }
}
