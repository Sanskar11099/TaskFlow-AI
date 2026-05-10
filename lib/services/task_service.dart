import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/task_model.dart';

class TaskService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _db.collection('users').doc(userId).collection('tasks');

  Stream<List<TaskModel>> streamTasks(String userId) => _col(userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(TaskModel.fromFirestore).toList());

  Future<void> addTask(String userId, TaskModel task) =>
      _col(userId).doc(task.id).set(task.toMap());

  Future<void> updateTask(String userId, TaskModel task) =>
      _col(userId).doc(task.id).update(task.toMap());

  Future<void> deleteTask(String userId, String taskId) =>
      _col(userId).doc(taskId).delete();
}
