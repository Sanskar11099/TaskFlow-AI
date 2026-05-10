import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../../services/task_service.dart';

class TasksNotifier extends StateNotifier<List<TaskModel>> {
  final TaskService _service;
  final String _userId;
  StreamSubscription<List<TaskModel>>? _sub;

  TasksNotifier(this._service, this._userId) : super([]) {
    if (_userId.isNotEmpty) {
      _sub = _service.streamTasks(_userId).listen((tasks) => state = tasks);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> addTask(TaskModel task) => _service.addTask(_userId, task);

  Future<void> updateTask(TaskModel updated) =>
      _service.updateTask(_userId, updated);

  Future<void> deleteTask(String id) => _service.deleteTask(_userId, id);

  Future<void> toggleComplete(String id) {
    final task = state.firstWhere((t) => t.id == id);
    final next = task.isCompleted ? TaskStatus.pending : TaskStatus.completed;
    return updateTask(task.copyWith(status: next));
  }

  List<TaskModel> get pending =>
      state.where((t) => t.status == TaskStatus.pending).toList();

  List<TaskModel> get completed =>
      state.where((t) => t.status == TaskStatus.completed).toList();

  List<TaskModel> byPriority(TaskPriority p) =>
      state.where((t) => t.priority == p).toList();

  List<TaskModel> search(String query) {
    final q = query.toLowerCase();
    return state
        .where((t) =>
            t.title.toLowerCase().contains(q) ||
            (t.description?.toLowerCase().contains(q) ?? false) ||
            t.tags.any((tag) => tag.toLowerCase().contains(q)))
        .toList();
  }

  List<TaskModel> forDate(DateTime date) => state.where((t) {
        if (t.dueDate == null) return false;
        final d = t.dueDate!;
        return d.year == date.year &&
            d.month == date.month &&
            d.day == date.day;
      }).toList();
}

final _taskServiceProvider = Provider<TaskService>((ref) => TaskService());

final tasksProvider =
    StateNotifierProvider<TasksNotifier, List<TaskModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  return TasksNotifier(ref.watch(_taskServiceProvider), uid);
});
