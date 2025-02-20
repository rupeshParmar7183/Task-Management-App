# Task Management App

A Flutter project for managing tasks efficiently.

## Overview

The Task Management App is designed to help users efficiently manage their tasks by allowing them to create, update, delete, and organize tasks. It comes with powerful features such as setting deadlines, reminders, and categorizing tasks by priority. Additionally, the app syncs tasks across devices to ensure you never miss a beat.

## Features

### Task Management:
- Create, edit, delete, and view tasks
- Mark tasks as "Completed" or "Pending"

### Task Organization:
- Set deadlines and reminders
- Categorize tasks by priority
- Search and filter tasks (optional bonus feature)

### Data Storage:
- SQLite: Store and persist task details
- Hive: Manage user preferences (app theme, default sort order, etc.)

### State Management:
- Uses Riverpod for robust and testable state management

### Architecture:
- Follows MVVM architecture for clear separation of concerns:
    - **Model**: Defines data models for tasks and user preferences.
    - **ViewModel**: Handles business logic and state updates.
    - **View**: Implements a clean, responsive UI.

### Responsive Design:
- Optimized for both mobile and tablet devices
    - **Mobile**: Compact task list view
    - **Tablet**: Split view with task list and detailed view

### Additional (Optional):
- Local notifications for task reminders
- Animations and UI enhancements

## Getting Started

Follow these steps to set up the project on your local machine:

1. **Clone the Repository**
        ```sh
        git clone https://github.com/yourusername/task_management_app.git
        cd task_management_app
        ```

2. **Install Dependencies**
        ```sh
        flutter pub get
        ```

3. **Run the App**
        ```sh
        flutter run
        ```

## Resources

To get you started with Flutter development, check out these resources:
- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)
- [Official Flutter Documentation](https://flutter.dev/docs)

## Flutter Developer Assignment

### Objective

This assignment evaluates your skills in Flutter development by requiring you to implement the following:

- **MVVM Architecture**: Implement a clear separation between Model, ViewModel, and View.
- **State Management with Riverpod**: Efficiently manage app state for tasks and user preferences.
- **Local Data Storage**:
    - Use SQLite for persisting task details.
    - Use Hive for storing user preferences (theme, sort order).
- **Responsive UI**: Design a UI that adapts to both mobile and tablet screen sizes.

### Detailed Tasks

1. **Task Management**
     - Enable users to add, edit, delete, and view tasks.
     - Allow tasks to be marked as "Completed" or "Pending."

2. **Data Storage**
     - SQLite: Persist task data to survive app restarts.
     - Hive: Save user preferences like app theme and task sort order.

3. **State Management**
     - Utilize Riverpod for managing the app’s state, ensuring scalability and testability.

4. **MVVM Architecture**
     - **Model**: Define data models for tasks and user settings.
     - **ViewModel**: Implement business logic and manage state.
     - **View**: Build a responsive and clean user interface.

5. **Responsive Design**
     - **Mobile**: Provide a compact view with a task list.
     - **Tablet**: Offer a split view displaying both the task list and detailed information side-by-side.

6. **Additional Features (Optional)**
     - Implement search functionality for tasks.
     - Integrate local notifications to remind users about task deadlines.

### Technical Requirements

- **Language & Framework**: Dart and Flutter (version 3.22)
- **Libraries**:
    - Riverpod for state management
    - SQLite and Hive for data persistence
- **UI**:
    - Support for both light and dark themes
    - Responsive design for various screen sizes

## Contributing

Contributions are welcome! Please review our contributing guidelines before submitting pull requests.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.