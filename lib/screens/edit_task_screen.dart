import "package:flutter/material.dart";
import "../models/task_model.dart";
import "task_creation_sheet.dart";

class EditTaskScreen extends StatelessWidget {
  final TaskModel task;
  const EditTaskScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return TaskCreationSheet(editTask: task);
  }
}
