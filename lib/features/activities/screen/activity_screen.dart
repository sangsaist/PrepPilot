import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/features/activities/model/activity_model.dart';
import 'package:preppilot/features/activities/provider/activity_provider.dart';
import 'package:preppilot/features/activities/widgets/activity_bottom_sheet.dart';
import 'package:preppilot/features/projects/provider/project_provider.dart';
import 'package:preppilot/features/projects/screen/project_screen.dart';
import 'package:preppilot/features/projects/screen/project_detail_screen.dart';
import 'package:preppilot/features/projects/widgets/project_bottom_sheet.dart';
import 'package:preppilot/shared/widgets/empty_state.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:preppilot/features/projects/model/project_model.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final activities = ref.watch(filteredActivitiesProvider(_selectedFilter));
    final projects = ref.watch(projectNotifierProvider).value ?? [];
    final isLoading = ref.watch(activityNotifierProvider).isLoading;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activityNotifierProvider);
          ref.read(projectNotifierProvider.notifier).refresh();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildFilterBar()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Tracked Activities', style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            if (isLoading && activities.isEmpty)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (activities.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.emoji_events_outlined,
                  title: 'No activities yet',
                  subtitle: 'Track a hackathon or certification',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ActivityCard(activity: activities[index]),
                    childCount: activities.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Projects', style: Theme.of(context).textTheme.titleLarge),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectScreen())),
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),
            if (projects.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.code_outlined,
                  title: 'No projects yet',
                  subtitle: 'Add your first dev project',
                ),
              )
            else
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: projects.length,
                    itemBuilder: (context, index) => _CompactProjectCard(project: projects[index]),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        heroTag: 'activity_fab',
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.assignment_outlined),
            label: 'Add Activity',
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const ActivityBottomSheet(),
            ),
          ),
          SpeedDialChild(
            child: const Icon(Icons.code_outlined),
            label: 'Add Project',
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const ProjectBottomSheet(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Hackathon', 'Cert', 'Course'];
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
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: AppTheme.primaryColor.withOpacity(0.1),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : const Color(0xFFE0E0E0),
              ),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CompactProjectCard extends StatelessWidget {
  final Project project;
  const _CompactProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
        ),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   _buildStatusIndicator(project.status),
                   const Icon(Icons.arrow_forward_ios, size: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active': color = AppTheme.primaryColor; break;
      case 'completed': color = Colors.teal; break;
      case 'paused': color = Colors.grey; break;
      default: color = Colors.grey;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ActivityCard extends ConsumerWidget {
  final Activity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final difference = activity.deadline.difference(now).inDays;
    
    Color deadlineColor = Colors.green;
    if (activity.isOverdue) {
      deadlineColor = Colors.red;
    } else if (difference <= 7) {
      deadlineColor = Colors.orange;
    }

    return Dismissible(
      key: Key('activity_${activity.activityId}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Activity'),
            content: const Text('Remove this activity from your tracker?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        if (activity.activityId != null) {
          ref.read(activityNotifierProvider.notifier).deleteActivity(activity.activityId!);
        }
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
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => ActivityBottomSheet(activity: activity),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            activity.platform,
                            style: TextStyle(color: AppTheme.secondaryText, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    _buildTypeBadge(activity.type),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Deadline: ${_formatDate(activity.deadline)}",
                      style: TextStyle(color: deadlineColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${activity.progress}%",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: activity.progress / 100,
                  backgroundColor: Colors.grey.shade200,
                  color: AppTheme.primaryColor,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    switch (type.toLowerCase()) {
      case 'hackathon':
        color = const Color(0xFF5C6BC0);
        break;
      case 'cert':
        color = const Color(0xFF26A69A);
        break;
      case 'course':
        color = const Color(0xFFFFA726);
        break;
      default:
        color = AppTheme.secondaryText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
