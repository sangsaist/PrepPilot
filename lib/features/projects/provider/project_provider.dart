import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preppilot/features/projects/model/project_model.dart';
import 'package:preppilot/features/projects/repo/project_repo.dart';

final projectRepositoryProvider = Provider((ref) => ProjectRepository());

class ProjectNotifier extends AsyncNotifier<List<Project>> {
  @override
  FutureOr<List<Project>> build() async {
    return _fetchProjects();
  }

  Future<List<Project>> _fetchProjects() async {
    final repo = ref.read(projectRepositoryProvider);
    return await repo.getAllProjects();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchProjects());
  }

  Future<void> addProject(Project project) async {
    final repo = ref.read(projectRepositoryProvider);
    await repo.insertProject(project);
    await refresh();
  }

  Future<void> updateProject(Project project) async {
    final repo = ref.read(projectRepositoryProvider);
    await repo.updateProject(project);
    await refresh();
  }

  Future<void> deleteProject(int id) async {
    final repo = ref.read(projectRepositoryProvider);
    await repo.deleteProject(id);
    await refresh();
  }
}

final projectNotifierProvider = AsyncNotifierProvider<ProjectNotifier, List<Project>>(() {
  return ProjectNotifier();
});

final filteredProjectsProvider = Provider.family<List<Project>, String>((ref, filter) {
  final projectsAsync = ref.watch(projectNotifierProvider);
  return projectsAsync.when(
    data: (projects) {
      if (filter == 'All') return projects;
      return projects.where((p) => p.status.toLowerCase() == filter.toLowerCase()).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});
