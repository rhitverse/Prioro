import 'package:cloud_firestore/cloud_firestore.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection('tasks');

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _tasksCollection
          .orderBy('createdAt', descending: true)
          .get();
    } catch (_) {
      snapshot = await _tasksCollection.get();
    }

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
      };
    }).toList();
  }

  Future<void> createTask(Map<String, dynamic> taskData) async {
    final docRef = _tasksCollection.doc();
    await docRef.set({
      ...taskData,
      'id': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
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
