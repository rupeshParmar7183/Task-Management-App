import 'package:flutter/material.dart'; // Provides UI framework for Flutter apps.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // State management using Riverpod.
import 'package:hive_flutter/hive_flutter.dart'; // Provides local database functionality using Hive.
import 'package:task_management_app/core/hive_helper.dart'; // Helper class for managing Hive operations.
import 'package:task_management_app/models/user_preferences.dart'; // Model class for storing user preferences.
import 'package:task_management_app/services/app_theme.dart'; // Provides theme configurations.
import 'package:task_management_app/services/notification_services.dart'; // Manages app notifications.
import 'package:task_management_app/services/permission_handler.dart'; // Handles app permissions.
import 'package:task_management_app/viewmodels/settings_viewmodel.dart'; // ViewModel for managing settings state.
import 'package:task_management_app/views/home_screen.dart'; // Main screen of the application.

/// Entry point of the Flutter application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures proper initialization of widgets before running the app.
  
  await Hive.initFlutter(); // Initializes Hive for local storage.
  await HiveHelper.init(); // Calls helper method to initialize Hive adapters and boxes.
  
  // Ensure the preferences box is opened before using it.
  if (!Hive.isBoxOpen('preferences')) {
    await Hive.openBox<UserPreferences>('preferences');
  }
  
  await requestNotificationPermission(); // Requests notification permission from the user.
  await NotificationService.initialize(); // Initializes notification service.
  
  runApp(ProviderScope(child: MyApp())); // Runs the app with ProviderScope for Riverpod state management.
}

/// Root widget of the application that listens to theme changes using Riverpod.
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider); // Watches theme mode state.

    return MaterialApp(
      title: 'Task Management', // Sets the app title.
      theme: AppTheme.lightTheme, // Defines the light theme.
      darkTheme: AppTheme.darkTheme, // Defines the dark theme.
      themeMode: themeMode.isDarkMode == true
          ? ThemeMode.dark
          : ThemeMode.light, // Dynamically applies theme mode based on user preferences.
      home: HomeScreen(), // Sets the main screen of the app.
    );
  }
}