import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../helpera/constants.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskController extends GetxController {
  late Box<Task> taskBox;
  String? selectedCategoryId;
  bool extendFab = true;

  @override
  void onInit() {
    super.onInit();
    taskBox = Hive.box<Task>(AppConstants.boxTasks);
    cleanupExpiredReminders();
  }

  List<Task> get tasks => taskBox.values.toList();

  List<Task> get filteredTasks {
    List<Task> list;
    if (selectedCategoryId == null) {
      list = tasks;
    } else {
      list = tasks.where((t) => t.categoryId == selectedCategoryId).toList();
    }

    list.sort((a, b) {
      if (a.reminderAt == null && b.reminderAt == null) return 0;
      if (a.reminderAt == null) return 1;
      if (b.reminderAt == null) return -1;
      return a.reminderAt!.compareTo(b.reminderAt!);
    });

    return list;
  }

  List<Task> get completedTasks =>
      filteredTasks.where((t) => t.isCompleted).toList();

  List<Task> get pendingTasks =>
      filteredTasks.where((t) => !t.isCompleted).toList();

  void setExtendFab(bool value) {
    extendFab = value;
    update();
  }

  void addTask(Task task, {DateTime? reminder}) {
    task.reminderAt = reminder;
    taskBox.put(task.id, task);
    if (reminder != null) {
      NotificationService().scheduleNotification(
        id: task.id.hashCode,
        title: 'Task Reminder',
        body: task.title,
        scheduledDate: reminder,
      );
    }
    update();
    Get.snackbar('Success', 'Task added', snackPosition: SnackPosition.BOTTOM);
  }

  void updateTask(Task task, {DateTime? reminder}) {
    task.reminderAt = reminder;
    NotificationService().cancelNotification(task.id.hashCode);
    if (reminder != null) {
      NotificationService().scheduleNotification(
        id: task.id.hashCode,
        title: 'Task Reminder',
        body: task.title,
        scheduledDate: reminder,
      );
    }
    taskBox.put(task.id, task);
    update();
    Get.snackbar(
      'Success',
      'Task updated',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void deleteTask(String id) {
    taskBox.delete(id);
    NotificationService().cancelNotification(id.hashCode);
    update();
    Get.snackbar(
      'Success',
      'Task deleted',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void toggleComplete(String id) {
    final task = taskBox.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      if (task.isCompleted) {
        NotificationService().cancelNotification(id.hashCode);
      } else if (task.reminderAt != null) {
        NotificationService().scheduleNotification(
          id: id.hashCode,
          title: 'Task Reminder',
          body: task.title,
          scheduledDate: task.reminderAt!,
        );
      }
      task.save();
      update();
    }
  }

  void setFilter(String? categoryId) {
    selectedCategoryId = categoryId;
    update();
  }

  void saveTask({
    Task? existingTask,
    required String title,
    required String description,
    required String categoryId,
    DateTime? reminder,
  }) {
    final taskToSave = Task(
      id: existingTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      categoryId: categoryId,
      isCompleted: existingTask?.isCompleted ?? false,
      createdAt: existingTask?.createdAt ?? DateTime.now(),
    );

    if (existingTask != null) {
      updateTask(taskToSave, reminder: reminder);
    } else {
      addTask(taskToSave, reminder: reminder);
    }
  }

  void snoozeTask(String id, Duration duration) {
    final task = taskBox.get(id);
    if (task == null) return;
    final newTime = DateTime.now().add(duration);
    task.reminderAt = newTime;
    task.save();
    NotificationService().scheduleNotification(
      id: id.hashCode,
      title: 'Task Reminder',
      body: task.title,
      scheduledDate: newTime,
    );
    update();
  }

  void cleanupExpiredReminders() {
    for (final task in tasks) {
      if (task.reminderAt != null &&
          task.reminderAt!.isBefore(DateTime.now()) &&
          task.isCompleted) {
        NotificationService().cancelNotification(task.id.hashCode);
        task.reminderAt = null;
        task.save();
      }
    }
  }

  Task? getTask(String id) => taskBox.get(id);
}
