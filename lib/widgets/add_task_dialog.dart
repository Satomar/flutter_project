import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/category_controller.dart';
import '../controllers/task_controller.dart';
import '../helpera/themes.dart';
import '../models/task.dart';
import 'add_category_dialog.dart';

class AddTaskDialog extends StatefulWidget {
  final Task? task;

  const AddTaskDialog({super.key, this.task});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedCategoryId;
  DateTime? _reminderDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _selectedCategoryId = widget.task!.categoryId;
      _reminderDate = widget.task!.reminderAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();
    final taskController = Get.find<TaskController>();
    final isEdit = widget.task != null;

    return AlertDialog(
      title: Text(isEdit ? 'edit_task'.tr : 'add_task'.tr),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              autofocus: !isEdit,
              decoration: InputDecoration(
                labelText: 'title'.tr,
                border: const OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'description'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            GetBuilder<CategoryController>(
              builder: (_) {
                final items = [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('no_category'.tr),
                  ),
                  ...categoryController.categories.map(
                    (cat) => DropdownMenuItem(
                      value: cat.id,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(cat.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(cat.name),
                        ],
                      ),
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'add_new_category_option',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'add_new_category'.tr,
                          style: const TextStyle(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];

                return DropdownButtonFormField<String?>(
                  initialValue: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'category'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  items: items,
                  onChanged: (value) async {
                    if (value == 'add_new_category_option') {
                      setState(() => _selectedCategoryId = null);
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (context.mounted) {
                        Get.dialog(
                          AddCategoryDialog(
                            onCategoryAdded: (newId) {
                              setState(() {
                                _selectedCategoryId = newId;
                              });
                            },
                          ),
                        );
                      }
                    } else {
                      setState(() => _selectedCategoryId = value);
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _reminderDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date == null) return;
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(
                _reminderDate ?? DateTime.now(),
              ),
            );
            if (time == null) return;
            setState(() {
              _reminderDate = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
            });
          },
          child: Text(
            _reminderDate == null ? 'add_reminder'.tr : 'edit_reminder'.tr,
          ),
        ),
        TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              taskController.saveTask(
                existingTask: widget.task,
                title: _titleController.text,
                description: _descController.text,
                categoryId: _selectedCategoryId!,
                reminder: _reminderDate,
              );
              Get.close(1);
            }
          },
          child: Text('save'.tr),
        ),
      ],
    );
  }
}
