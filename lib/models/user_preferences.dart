import 'package:hive/hive.dart';
part 'user_preferences.g.dart';
@HiveType(typeId: 0)
class UserPreferences extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  String sortOrder;

  UserPreferences({required this.isDarkMode, required this.sortOrder});
}