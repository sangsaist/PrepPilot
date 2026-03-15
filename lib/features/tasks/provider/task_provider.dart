import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preppilot/features/tasks/model/task_model.dart';
import 'package:preppilot/features/tasks/repo/task_repo.dart';

final taskRepositoryProvider = Provider((ref) => TaskRepository());

class TaskNotifier extends AsyncNotifier<List<Task>> {
  @override
  FutureOr<List<Task>> build() async {
    return _fetchAllTasks();
  }

  Future<List<Task>> _fetchAllTasks() async {
    final repo = ref.read(taskRepositoryProvider);
    return await repo.getAllTasks();
  }

  Future<void> refreshTasks() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAllTasks());
  }

  Future<void> addTask(Task task) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.insertTask(task);
    await refreshTasks();
  }

  Future<void> updateTask(Task task) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.updateTask(task);
    await refreshTasks();
  }

  Future<void> deleteTask(int taskId) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.deleteTask(taskId);
    await refreshTasks();
  }
}

final taskNotifierProvider = AsyncNotifierProvider<TaskNotifier, List<Task>>(() {
  return TaskNotifier();
});

final tasksByDateProvider = Provider.family<List<Task>, DateTime>((ref, date) {
  final allTasksAsync = ref.watch(taskNotifierProvider);
  return allTasksAsync.when(
    data: (tasks) {
      final dateStr = date.toIso8601String().split('T')[0];
      return tasks.where((t) => t.date.toIso8601String().split('T')[0] == dateStr).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final overdueTasksProvider = Provider<List<Task>>((ref) {
  final allTasksAsync = ref.watch(taskNotifierProvider);
  return allTasksAsync.when(
    data: (tasks) {
      final nowStr = DateTime.now().toIso8601String().split('T')[0];
      return tasks.where((t) => 
        t.date.toIso8601String().split('T')[0].compareTo(nowStr) < 0 && 
        t.status != 'completed'
      ).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final todayTasksProvider = Provider<List<Task>>((ref) {
  final allTasksAsync = ref.watch(taskNotifierProvider);
  return allTasksAsync.when(
    data: (tasks) {
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      return tasks.where((t) => t.date.toIso8601String().split('T')[0] == todayStr).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final upcomingTasksProvider = Provider<List<Task>>((ref) {
  final allTasksAsync = ref.watch(taskNotifierProvider);
  return allTasksAsync.when(
    data: (tasks) {
      final nowStr = DateTime.now().toIso8601String().split('T')[0];
      return tasks.where((t) => t.date.toIso8601String().split('T')[0].compareTo(nowStr) > 0).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
