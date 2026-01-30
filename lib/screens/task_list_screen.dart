import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/category_controller.dart';
import '../controllers/task_controller.dart';
import '../helpers/routes.dart';
import '../helpers/themes.dart';
import '../helpers/translations.dart';
import '../models/task.dart';
import '../widgets/add_task_dialog.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;
  Offset? _lastTapPosition;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final taskController = Get.find<TaskController>();
    final position = _scrollController.position;
    final shouldExtend = position.pixels <= position.maxScrollExtent / 2;
    if (taskController.extendFab != shouldExtend) {
      taskController.setExtendFab(shouldExtend);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onSegmentChanged(Set<int> newSelection) {
    setState(() {
      _selectedIndex = newSelection.first;
    });
  }

  List<Task> _applyStatusFilter(List<Task> tasks) {
    if (_selectedIndex == 1) {
      return tasks.where((t) => !t.isCompleted).toList();
    } else if (_selectedIndex == 2) {
      return tasks.where((t) => t.isCompleted).toList();
    }
    return tasks;
  }

  Future<void> _showSnoozeMenu(Offset position, Task task) async {
    final choices = <PopupMenuEntry<int>>[
      PopupMenuItem(value: 5, child: Text('snooze_5m'.tr)),
      PopupMenuItem(value: 10, child: Text('snooze_10m'.tr)),
      PopupMenuItem(value: 30, child: Text('snooze_30m'.tr)),
      PopupMenuItem(value: 60, child: Text('snooze_1h'.tr)),
      PopupMenuItem(value: -1, child: Text('cancel_reminder'.tr)),
    ];

    final selected = await showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: choices,
    );

    if (selected == null) return;

    final taskController = Get.find<TaskController>();

    if (selected == -1) {
      taskController.updateTask(
        Task(
          id: task.id,
          title: task.title,
          description: task.description,
          categoryId: task.categoryId,
          isCompleted: task.isCompleted,
          createdAt: task.createdAt,
          reminderAt: null,
        ),
        reminder: null,
      );
      Get.snackbar(
        'reminder'.tr,
        'reminder_cancelled'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final duration = Duration(minutes: selected);
    taskController.snoozeTask(task.id, duration);
    Get.snackbar(
      'snoozed'.tr,
      AppTranslations.localizedDuration(duration),
      snackPosition: SnackPosition.BOTTOM,
    );

  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final horizontalPadding = mq.size.width * 0.04;
    final segmentWidth = (mq.size.width - (horizontalPadding * 2) - 24) / 3;
    final trailingWidth = mq.size.width * 0.28;

    final taskController = Get.find<TaskController>();
    final categoryController = Get.find<CategoryController>();
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: AppBar(
        title: Text('tasks'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => Get.toNamed(AppRoutes.categories),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 12,
            ),
            child: SegmentedButton<int>(
              segments: <ButtonSegment<int>>[
                ButtonSegment(
                  value: 0,
                  label: SizedBox(
                    width: segmentWidth,
                    child: Center(
                      child: Text(
                        'all'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                ButtonSegment(
                  value: 1,
                  label: SizedBox(
                    width: segmentWidth,
                    child: Center(
                      child: Text(
                        'pending'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                ButtonSegment(
                  value: 2,
                  label: SizedBox(
                    width: segmentWidth,
                    child: Center(
                      child: Text(
                        'completed'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
              selected: <int>{_selectedIndex},
              onSelectionChanged: _onSegmentChanged,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GetBuilder<TaskController>(
              builder: (_) {
                final tasks = _applyStatusFilter(taskController.filteredTasks);
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.task_alt,
                          size: 64,
                          color: AppColors.iconSubtle,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_tasks'.tr,
                          style: const TextStyle(
                            color: AppColors.textSubtleDark,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 12,
                  ),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final category = categoryController.getCategory(
                      task.categoryId ?? '',
                    );
                    final now = DateTime.now();
                    final isMissed = task.reminderAt == null || task.isCompleted
                        ? false
                        : task.reminderAt!.isBefore(
                            now.subtract(const Duration(minutes: 1)),
                          );
                    final showAlarm = task.reminderAt != null;
                    final alarmIcon = task.isCompleted
                        ? Icons.alarm_off
                        : Icons.alarm;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) =>
                              taskController.toggleComplete(task.id),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.description.isNotEmpty)
                              Text(
                                task.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                if (category != null) ...[
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: mq.size.width * 0.4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(
                                        category.colorValue,
                                      ).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      category.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(category.colorValue),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    _buildDateLine(task),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.reminderTextColor(
                                        isMissed: isMissed,
                                        brightness: brightness,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 8,
                        ),
                        trailing: SizedBox(
                          width: trailingWidth,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (showAlarm)
                                GestureDetector(
                                  onTapDown: (details) {
                                    _lastTapPosition = details.globalPosition;
                                  },
                                  onTap: () {
                                    final pos =
                                        _lastTapPosition ??
                                        Offset(
                                          mq.size.width * 0.8,
                                          mq.size.height * 0.5,
                                        );
                                    _showSnoozeMenu(pos, task);
                                  },
                                  child: Icon(
                                    alarmIcon,
                                    size: 20,
                                    color: AppColors.alarmColor(
                                      isMissed: isMissed,
                                      isCompleted: task.isCompleted,
                                      brightness: brightness,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 12),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: Text('edit'.tr),
                                    onTap: () => Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () =>
                                          Get.dialog(AddTaskDialog(task: task)),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: Text(
                                      'delete'.tr,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                      ),
                                    ),
                                    onTap: () => _deleteTask(task.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        onTap: () {},
                        horizontalTitleGap: 12,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: GetBuilder<TaskController>(
        builder: (controller) => FloatingActionButton.extended(
          onPressed: () => Get.dialog(const AddTaskDialog()),
          isExtended: controller.extendFab,
          icon: const Icon(Icons.add),
          label: Text('add'.tr),
        ),
      ),
    );
  }

  String _buildDateLine(Task task) {
    final created = DateFormat.yMMMd().format(task.createdAt);
    if (task.reminderAt != null) {
      return AppTranslations.localizedRelativeTime(task.reminderAt!);
    }
    return created;
  }

  void _deleteTask(String id) {
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.dialog(
        AlertDialog(
          title: Text('delete'.tr),
          content: Text('delete_confirm'.tr),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
            TextButton(
              onPressed: () {
                Get.find<TaskController>().deleteTask(id);
                Get.close(1);
              },
              child: Text(
                'delete'.tr,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      );
    });
  }
}
