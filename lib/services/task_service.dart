import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_management_app/models/task_model.dart';

class TaskService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Task>> getUserTasksStream(String userId) {
    return _db
        .collection('users').doc(userId).collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) => doc.data().isNotEmpty)
            .map((doc) => Task.fromDocument(doc))
            .toList());
  }

  Future<void> addTask(Task task, String userId) {
    return _db.collection('users').doc(userId).collection('tasks').add(task.toMap());
  }

  Future<void> deleteTask(String id, String userId) {
    return _db.collection('users').doc(userId).collection('tasks').doc(id).delete();
  }

  Future<void> updateTask(Task task, String userId) {
    return _db.collection('users').doc(userId).collection('tasks').doc(task.id).update(task.toMap());
  }

  Future<void> updateStatus(String id, String status, bool isCompleted, String userId) {
    return _db.collection('users').doc(userId).collection('tasks').doc(id).update({
      'status': status,
      'isCompleted': isCompleted,
    });
  }
}
