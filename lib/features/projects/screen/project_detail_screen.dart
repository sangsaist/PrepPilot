import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/features/projects/model/project_model.dart';
import 'package:preppilot/features/projects/provider/project_provider.dart';
import 'package:preppilot/features/projects/widgets/project_bottom_sheet.dart';
import 'package:preppilot/features/tasks/model/task_model.dart';
import 'package:preppilot/features/tasks/provider/task_provider.dart';
import 'package:preppilot/features/tasks/widgets/task_card.dart';
import 'package:preppilot/features/tasks/widgets/task_bottom_sheet.dart';
import 'package:preppilot/features/vault/provider/vault_provider.dart';
import 'package:preppilot/features/vault/widgets/attach_file_button.dart';
import 'package:open_file/open_file.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final linkedTasks = tasksAsync.value?.where((t) => t.linkedType == 'project' && t.linkedId == project.projectId).toList() ?? [];
    
    final files = ref.watch(filesByLinkedItemProvider(('project', project.projectId!)));

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => ProjectBottomSheet(project: project),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(project),
                  const SizedBox(height: 24),
                  const Text('Project Tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  if (linkedTasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text("No tasks linked to this project")),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => TaskCard(task: linkedTasks[index]),
                childCount: linkedTasks.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Attached Files', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  _buildFilesList(files),
                  const SizedBox(height: 16),
                  AttachFileButton(linkedType: 'project', linkedId: project.projectId!),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'project_detail_fab',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => TaskBottomSheet(
              linkedType: 'project',
              linkedId: project.projectId,
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_task, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             _buildStatusBadge(project.status),
             if (project.repoUrl != null)
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () => launchUrl(Uri.parse(project.repoUrl!)),
                ),
          ],
        ),
        const SizedBox(height: 12),
        Text(project.description, style: const TextStyle(fontSize: 16)),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFilesList(List<dynamic> files) {
    if (files.isEmpty) return const Text("No files attached", style: TextStyle(fontSize: 14, color: AppTheme.secondaryText));
    return Column(
      children: files.map((f) => ListTile(
        leading: const Icon(Icons.attach_file),
        title: Text(f.label),
        onTap: () => OpenFile.open(f.localUri),
      )).toList(),
    );
  }
}
