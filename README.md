# Todo App (Flutter)

A feature-rich Todo application built with Flutter as a course project. The app focuses on clean architecture, practical state management, and real-world task handling features such as reminders, notifications, and categorization.

---

## Overview

This application allows users to create, manage, and organize tasks efficiently. It supports categories, task completion tracking, reminders with notifications, and intelligent handling of missed or expired reminders. The project is designed to demonstrate proper separation of concerns, reactive UI updates, and persistence using local storage.

---

## Core Features

### Task Management

* Create, edit, and delete tasks
* Tasks include title, description, category, creation date, and completion state
* Unified save logic for adding and editing tasks
* Automatic task ID generation
* Mark tasks as completed or pending
* Completed tasks are visually distinguished

---

### Categories

* Create and manage custom categories
* Assign tasks to categories
* Category-based task filtering
* Category color indicators
* Per-category reminder badge showing active reminders

---

### Task Filtering & Statistics

* View all tasks or filter by category
* Separate counts for:

    * All tasks
    * Completed tasks
    * Pending tasks
* Real-time UI updates when filters change

---

### Reminders & Notifications

* Set reminders when creating or editing a task
* Edit reminders after task creation
* Cancel reminders automatically when:

    * A task is marked as completed
    * A task is deleted
* Cancel and reschedule reminders on task updates
* Snooze reminders for a later time

---

### Missed Reminder Handling

* Detect missed reminders (when reminder time has passed and task is still pending)
* Display a clear "Missed" indicator on affected tasks
* Color-shift alarm icon for missed reminders
* Sort missed reminders above normal tasks for visibility
* Handle app launch with previously missed reminders

---

### Reminder Indicators

* Alarm icon shown on tasks with active reminders
* Visual badge for tasks with reminders
* Category-level reminder badges
* Different visual states for:

    * Upcoming reminders
    * Missed reminders

---

### Snooze Functionality

* Snooze reminders directly from notification actions or UI
* Reschedules reminder to a later time
* Updates task state and notification accordingly

---

### Notification Behavior

* Local notifications scheduled using reminder time
* Correct handling when reminder time equals current time
* Notification tap navigates the user to the relevant task
* Automatic cleanup of expired notifications
* Prevent duplicate or stale notifications

---

### Data Persistence

* Local storage using Hive
* Tasks and categories persist across app restarts
* Safe box initialization and access

---

### UI & UX Enhancements

* Dialog-based task creation and editing
* Reliable dialog dismissal handling
* Floating Action Button for quick task creation
* Scroll-aware FAB behavior
* Clear empty-state UI when no tasks exist
* Responsive layouts and form validation

---

### Architecture & State Management

* Uses GetX for:

    * State management
    * Dependency injection
    * Navigation
* Clear separation between:

    * UI (screens & widgets)
    * Controllers (business logic)
    * Models (data structures)
* Reactive updates using GetBuilder and GetX patterns

---

## Project Goals

* Demonstrate practical Flutter app architecture
* Apply state management patterns effectively
* Implement real-world reminder and notification logic
* Build a maintainable and extensible codebase

---

## Technologies Used

* Flutter
* Dart
* GetX
* Hive (local storage)
* Local Notifications

---

## Conclusion

This project goes beyond a basic Todo app by addressing real usability concerns such as missed reminders, notification reliability, and task organization. It demonstrates thoughtful design decisions, robust state handling, and attention to user experience, making it suitable as an academic project and a foundation for further expansion.
