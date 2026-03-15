import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/features/projects/model/project_model.dart';
import 'package:preppilot/features/projects/provider/project_provider.dart';
import 'package:preppilot/features/projects/screen/project_detail_screen.dart';
import 'package:preppilot/features/projects/widgets/project_bottom_sheet.dart';
import 'package:preppilot/shared/widgets/empty_state.dart';
import 'package:preppilot/features/tasks/repo/task_repo.dart';
import 'package:preppilot/features/tasks/provider/task_provider.dart';

class ProjectScreen extends ConsumerStatefulWidget {
  const ProjectScreen({super.key});

  @override
  ConsumerState<ProjectScreen> createState() => _ProjectScreenState();
}

class _SettingsScreenState {} // dummy to avoid linter if needed but I'll use real state

class _ProjectScreenState extends ConsumerState<ProjectScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectNotifierProvider);
    final projects = ref.watch(filteredProjectsProvider(_selectedFilter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(projectNotifierProvider.notifier).refresh(),
        child: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: projectsAsync.when(
                data: (_) => _buildProjectList(projects),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => EmptyState(
                  icon: Icons.error_outline,
                  title: 'Something went wrong',
                  subtitle: e.toString(),
                  actionLabel: 'Retry',
                  onAction: () => ref.invalidate(projectNotifierProvider),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'project_fab',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const ProjectBottomSheet(),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Active', 'Completed', 'Paused'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilter = filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProjectList(List<Project> projects) {
    if (projects.isEmpty) {
      return EmptyState(
        icon: Icons.code_outlined,
        title: 'No projects yet',
        subtitle: _selectedFilter == 'All' 
            ? 'Add your first dev project' 
            : 'No $_selectedFilter projects found',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) => _ProjectCard(project: projects[index]),
    );
  }
}

class _ProjectCard extends ConsumerWidget {
  final Project project;
  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // we need to fetch task count
    final tasksAsync = ref.watch(taskNotifierProvider);
    final taskCount = tasksAsync.when(
      data: (tasks) => tasks.where((t) => t.linkedType == 'project' && t.linkedId == project.projectId).length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Dismissible(
      key: Key('project_${project.projectId}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) {
        ref.read(projectNotifierProvider.notifier).deleteProject(project.projectId!);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade100,
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    _buildStatusBadge(project.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppTheme.secondaryText),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (project.repoUrl != null)
                      ActionChip(
                        avatar: const Icon(Icons.link, size: 14),
                        label: const Text('Repo', style: TextStyle(fontSize: 10)),
                        onPressed: () => launchUrl(Uri.parse(project.repoUrl!)),
                      )
                    else
                      const SizedBox(),
                    Text(
                      '$taskCount tasks linked',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active': color = AppTheme.primaryColor; break;
      case 'completed': color = Colors.teal; break;
      case 'paused': color = Colors.grey; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure? This will remove the project from PrepPilot.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
