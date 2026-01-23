import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/category_controller.dart';
import '../controllers/task_controller.dart';
import '../helpera/routes.dart';
import '../widgets/add_task_dialog.dart';

class TaskListScreen extends StatelessWidget {
  TaskListScreen({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();
    final categoryController = Get.find<CategoryController>();

    _scrollController.addListener(() {
      final shouldExtend =
          _scrollController.position.pixels <=
          _scrollController.position.maxScrollExtent / 2;
      if (taskController.extendFab != shouldExtend) {
        taskController.setExtendFab(shouldExtend);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('tasks'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => Get.toNamed(AppRoutes.CATEGORIES),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GetBuilder<TaskController>(
              builder: (controller) => GetBuilder<CategoryController>(
                builder: (_) => DropdownButtonFormField<String?>(
                  initialValue: controller.selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'category'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text('all'.tr)),
                    ...categoryController.categories.map(
                      (cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => controller.setFilter(value),
                ),
              ),
            ),
          ),
          Expanded(
            child: GetBuilder<TaskController>(
              builder: (_) {
                final tasks = taskController.filteredTasks;
                if (tasks.isEmpty) {
                  return Center(child: Text('no_tasks'.tr));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) =>
                              taskController.toggleComplete(task.id),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  decoration:
                                  task.isCompleted ? TextDecoration.lineThrough : null,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (task.reminderAt != null && !task.isCompleted)
                              const Icon(Icons.alarm, size: 18),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              child: Text('edit'.tr),
                              onTap: () => Future.delayed(
                                const Duration(milliseconds: 100),
                                () => Get.dialog(AddTaskDialog(task: task)),
                              ),
                            ),
                            PopupMenuItem(
                              child: Text('delete'.tr),
                              onTap: () => taskController.deleteTask(task.id),
                            ),
                          ],
                        ),
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
          onPressed: () => Get.dialog(
            const AddTaskDialog(),
          ),
          isExtended: controller.extendFab,
          icon: const Icon(Icons.add),
          label: Text('add'.tr),
        ),
      ),
    );
  }
}
