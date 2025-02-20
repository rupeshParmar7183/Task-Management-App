import 'package:hive/hive.dart'; // Importing Hive for local storage.
import '../models/user_preferences.dart'; // Importing user preferences model.

/// Helper class to manage Hive operations for user preferences.
class HiveHelper {
  static const String _boxName = "preferences"; // Name of the Hive box for storing preferences.

  /// Initializes Hive by registering the adapter and opening the preferences box.
  static Future<void> init() async {
    Hive.registerAdapter(UserPreferencesAdapter()); // Registers adapter for UserPreferences model.
    await Hive.openBox<UserPreferences>(_boxName); // Opens the Hive box for user preferences.
  }

  /// Provides access to the opened Hive box.
  static Box<UserPreferences> get box => Hive.box<UserPreferences>(_boxName);

  /// Saves user preferences to the Hive box.
  static void savePreferences(UserPreferences preferences) {
    box.put("userPrefs", preferences); // Stores user preferences with key "userPrefs".
  }

  /// Retrieves user preferences from the Hive box.
  static UserPreferences? getPreferences() {
    return box.get("userPrefs"); // Fetches stored preferences if available.
  }
}
