import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TaskRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection('tasks');

  // Current user की ID लाओ
  String? _getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    try {
      final userId = _getCurrentUserId();

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _tasksCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': data['id']?.toString().isNotEmpty == true
              ? data['id'].toString()
              : doc.id,
          'title': data['title']?.toString() ?? '',
          'description': data['description']?.toString() ?? '',
          'priority': data['priority']?.toString() ?? 'medium',
          'status': data['status']?.toString() ?? 'todo',
          'progress': _toInt(data['progress']),
          'isCompleted': data['isCompleted'] == true,
          'tags': _toStringList(data['tags']),
          'dueDate': _toDateString(data['dueDate']),
          'startDate': _toDateString(data['startDate']),
          'endDate': _toDateString(data['endDate']),
          'createdAt': _toIsoString(data['createdAt']),
          'updatedAt': _toIsoString(data['updatedAt']),
          'assigneeId': data['assigneeId']?.toString() ?? '',
          'position': _toInt(data['position']),
          'userId': data['userId']?.toString() ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error fetching tasks: $e');
      rethrow;
    }
  }

  Future<void> createTask(Map<String, dynamic> taskData) async {
    try {
      final userId = _getCurrentUserId();

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final docRef = _tasksCollection.doc();
      await docRef.set({
        ...taskData,
        'id': docRef.id,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final userId = _getCurrentUserId();

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _tasksCollection.doc(taskId).get();
      if (doc.data()?['userId'] != userId) {
        throw Exception('Unauthorized: Cannot delete other user\'s task');
      }

      await _tasksCollection.doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      final userId = _getCurrentUserId();

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _tasksCollection.doc(taskId).get();
      if (doc.data()?['userId'] != userId) {
        throw Exception('Unauthorized: Cannot update other user\'s task');
      }

      await _tasksCollection.doc(taskId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<String> _toStringList(dynamic value) {
    if (value is Iterable) {
      return value.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  String _toDateString(dynamic value) {
    if (value == null) return '';
    if (value is Timestamp) {
      final date = value.toDate();
      return _formatDate(date);
    }
    if (value is DateTime) {
      return _formatDate(value);
    }
    return value.toString();
  }

  String _toIsoString(dynamic value) {
    if (value == null) return '';
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is DateTime) return value.toIso8601String();
    return value.toString();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
