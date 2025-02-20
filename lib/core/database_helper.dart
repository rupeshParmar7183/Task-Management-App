// Import necessary packages for database operations, file system access, and path handling.
import 'package:sqflite/sqflite.dart'; // Provides SQLite database functionalities.
import 'package:path_provider/path_provider.dart'; // Helps in finding commonly used locations on the filesystem.
import 'dart:io'; // Provides File operations.
import 'package:path/path.dart'; // Helps in constructing file paths.
import '../models/task_model.dart'; // Imports the TaskModel to map database rows to Dart objects.

/// A helper class to manage database creation, initialization, migrations,
/// and CRUD operations for tasks.
class DatabaseHelper {
  // Holds the reference to the database instance.
  static Database? _database;
  
  // Provides a singleton instance of DatabaseHelper.
  static final DatabaseHelper instance = DatabaseHelper._init();

  // Private constructor to enforce singleton pattern.
  DatabaseHelper._init();

  /// Getter that initializes the database if it's not already initialized,
  /// otherwise returns the existing database instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialize the database with the specified file name.
    _database = await _initDB('tasks.db');
    return _database!;
  }

  /// Initializes the database by creating or opening the database file.
  /// [fileName] specifies the name of the database file.
  Future<Database> _initDB(String fileName) async {
    // Get the directory where the application can store files.
    final dbPath = await getApplicationDocumentsDirectory();
    // Construct the full path for the database file.
    final path = join(dbPath.path, fileName);

    // Open the database, specifying the version and providing callbacks for creation and upgrades.
    return await openDatabase(
      path,
      version: 4, // Database version; incremented for migration handling.
      // Callback executed when the database is created for the first time.
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE tasks (
          id TEXT PRIMARY KEY, -- Changed to TEXT to store String id values.
          title TEXT NOT NULL, -- Task title is required.
          description TEXT, -- Optional description of the task.
          isCompleted INTEGER NOT NULL, -- Integer flag to denote task completion status.
          dueDate TEXT, -- Optional due date stored as text.
          priority INTEGER -- Optional priority level of the task.
        )
      ''');
      },
      // Callback executed when the database needs to be upgraded.
      onUpgrade: (db, oldVersion, newVersion) async {
        // If the old version is less than 2, add a new column for dueDate.
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE tasks ADD COLUMN dueDate TEXT");
        }
        // If the old version is less than 3, add a new column for priority.
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE tasks ADD COLUMN priority INTEGER");
        }
        // If the old version is less than 4, perform migration to support String ids.
        if (oldVersion < 4) {
          // Create a new table with the updated schema.
          await db.execute('''
          CREATE TABLE tasks_new (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            isCompleted INTEGER NOT NULL,
            dueDate TEXT,
            priority INTEGER
          )
        ''');
          // Copy all existing data into the new table.
          await db.execute('INSERT INTO tasks_new SELECT * FROM tasks');
          // Remove the old table.
          await db.execute('DROP TABLE tasks');
          // Rename the new table to replace the old table.
          await db.execute('ALTER TABLE tasks_new RENAME TO tasks');
        }
      },
    );
  }

  /// Inserts a new task into the 'tasks' table.
  /// Returns the id of the inserted task as an integer.
  Future<int> insertTask(TaskModel task) async {
    // Get the database instance.
    final db = await instance.database;
    // Insert the task into the database and return the result.
    return await db.insert('tasks', task.toMap());
  }

  /// Retrieves all tasks from the 'tasks' table.
  /// Returns a list of TaskModel objects.
  Future<List<TaskModel>> fetchTasks() async {
    // Get the database instance.
    final db = await instance.database;
    // Query all rows from the 'tasks' table.
    final tasks = await db.query('tasks');
    // Convert each map to a TaskModel and return the list.
    return tasks.map((e) => TaskModel.fromMap(e)).toList();
  }

  /// Updates an existing task in the 'tasks' table.
  /// Returns the number of rows affected.
  Future<int> updateTask(TaskModel task) async {
    // Get the database instance.
    final db = await instance.database;
    // Update the task matching the specified id.
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?', // Specify which task to update.
      whereArgs: [task.id], // Provide the id value for the task.
    );
  }

  /// Deletes a task from the 'tasks' table by its id.
  /// Returns the number of rows affected.
  Future<int> deleteTask(String id) async {
    // Get the database instance.
    final db = await instance.database;
    // Delete the task matching the specified id.
    return await db.delete(
      'tasks',
      where: 'id = ?', // Specify which task to delete.
      whereArgs: [id], // Provide the id value for the task.
    );
  }

  /// Deletes the entire database file.
  Future<void> deleteDatabaseFile() async {
    // Get the directory for database storage.
    final dbPath = await getApplicationDocumentsDirectory();
    // Construct the full path for the database file.
    final path = join(dbPath.path, 'tasks.db');
    // Delete the database file from the device.
    await deleteDatabase(path);
  }

  /// Searches for tasks in the 'tasks' table where the title contains the given string.
  /// Returns a list of TaskModel objects that match the search criteria.
  Future<List<TaskModel>> searchTaskFromTitle(String title) async {
    // Get the database instance.
    final db = await instance.database;
    // Query the 'tasks' table with a WHERE clause to filter titles using a LIKE operator.
    final tasks = await db.query(
      'tasks',
      where: 'title LIKE ?', // Use pattern matching for partial titles.
      whereArgs: ['%$title%'], // Wrap the search term with wildcards.
    );
    // Convert each map to a TaskModel and return the list.
    return tasks.map((e) => TaskModel.fromMap(e)).toList();
  }
}
