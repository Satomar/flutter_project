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
  }

  List<Task> get tasks => taskBox.values.toList();

  List<Task> get filteredTasks {
    if (selectedCategoryId == null) {
      return tasks;
    }
    return tasks.where((t) => t.categoryId == selectedCategoryId).toList();
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
      task.save();
      update();
    }
  }

  void setFilter(String? categoryId) {
    selectedCategoryId = categoryId;
    update();
  }

  Task? getTask(String id) => taskBox.get(id);
}
