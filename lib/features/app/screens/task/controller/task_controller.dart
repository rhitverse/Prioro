import 'package:prioro/features/app/screens/task/repository/task_repository.dart';

class TaskController {
  final TaskRepository _repository;

  TaskController({TaskRepository? repository})
    : _repository = repository ?? TaskRepository();

  Future<List<Map<String, dynamic>>> loadTasks() {
    return _repository.fetchTasks();
  }

  Future<void> createTask(Map<String, dynamic> taskData) {
    return _repository.createTask(taskData);
  }

  Future<void> deleteTask(String taskId) {
    return _repository.deleteTask(taskId);
  }
}
