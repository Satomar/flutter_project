import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../helpers/constants.dart';
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
      final now = DateTime.now();
      final aMissed =
          a.reminderAt != null && a.reminderAt!.isBefore(now) && !a.isCompleted;
      final bMissed =
          b.reminderAt != null && b.reminderAt!.isBefore(now) && !b.isCompleted;

      if (aMissed && !bMissed) return -1;
      if (!aMissed && bMissed) return 1;

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

  Future<void> addTask(Task task, {DateTime? reminder}) async {
    task.reminderAt = reminder;
    taskBox.put(task.id, task);
    if (reminder != null) {
      await NotificationService().scheduleNotification(
        id: task.id.hashCode,
        title: 'Task Reminder',
        body: task.title,
        scheduledDate: reminder,
        payload: task.id,
      );
    }
    update();
    Get.snackbar('Success', 'Task added', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> updateTask(Task task, {DateTime? reminder}) async {
    task.reminderAt = reminder;
    await NotificationService().cancelNotification(task.id.hashCode);
    if (reminder != null) {
      await NotificationService().scheduleNotification(
        id: task.id.hashCode,
        title: 'Task Reminder',
        body: task.title,
        scheduledDate: reminder,
        payload: task.id,
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
    if (task == null) return;
    final now = DateTime.now();
    final wasCompleted = task.isCompleted;
    task.isCompleted = !task.isCompleted;

    final reminder = task.reminderAt;
    if (reminder != null) {
      final notificationService = NotificationService();

      if (task.isCompleted) {
        notificationService.cancelNotification(id.hashCode);
        task.reminderAt = null;
      } else {
        DateTime scheduledDate = reminder;
        if (reminder.isBefore(now) || reminder.isAtSameMomentAs(now)) {
          final newScheduledDate = now.add(const Duration(seconds: 1));
          task.reminderAt = newScheduledDate;
          scheduledDate = newScheduledDate;
        }

        notificationService.scheduleNotification(
          id: id.hashCode,
          title: 'Task Reminder',
          body: task.title,
          scheduledDate: scheduledDate,
          payload: task.id,
        );
      }
    }

    task.save();
    update();

    if (!wasCompleted && task.isCompleted) {
      Get.snackbar(
        'Task',
        'Marked completed',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void markComplete(String id) {
    final task = taskBox.get(id);
    if (task == null || task.isCompleted) {
      return;
    }

    task.isCompleted = true;
    if (task.reminderAt != null) {
      NotificationService().cancelNotification(id.hashCode);
      task.reminderAt = null;
    }
    task.save();
    update();
    Get.snackbar(
      'Task',
      'Marked completed',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void setFilter(String? categoryId) {
    selectedCategoryId = categoryId;
    update();
  }

  Task? getTask(String id) => taskBox.get(id);

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
      payload: task.id,
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

  Future<void> saveTask({
    Task? existingTask,
    required String title,
    required String description,
    required String categoryId,
    DateTime? reminder,
  }) async {
    final taskToSave = Task(
      id: existingTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      categoryId: categoryId,
      isCompleted: existingTask?.isCompleted ?? false,
      createdAt: existingTask?.createdAt ?? DateTime.now(),
      reminderAt: reminder,
    );

    if (existingTask != null) {
      await updateTask(taskToSave, reminder: reminder);
    } else {
      await addTask(taskToSave, reminder: reminder);
    }
  }
}
