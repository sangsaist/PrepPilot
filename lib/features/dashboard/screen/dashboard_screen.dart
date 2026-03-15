import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/features/tasks/provider/task_provider.dart';
import 'package:preppilot/features/activities/provider/activity_provider.dart';
import 'package:preppilot/shared/utils/pressure_score.dart';
import 'package:preppilot/features/tasks/model/task_model.dart';
import 'package:preppilot/features/activities/model/activity_model.dart';
import 'package:preppilot/features/tasks/widgets/task_bottom_sheet.dart';
import 'package:preppilot/features/vault/screen/vault_screen.dart';
import 'package:preppilot/shared/utils/csv_exporter.dart';
import 'package:preppilot/shared/utils/pdf_exporter.dart';
import 'package:preppilot/shared/widgets/empty_state.dart';
import 'package:preppilot/shared/provider/user_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final activitiesAsync = ref.watch(activityNotifierProvider);
    final todayTasks = ref.watch(todayTasksProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(ref),
            const SizedBox(height: 24),
            _buildPressureCard(tasksAsync, activitiesAsync),
            const SizedBox(height: 24),
            _buildTodayTasks(context, todayTasks),
            const SizedBox(height: 24),
            _buildActiveActivities(context, activitiesAsync),
            const SizedBox(height: 24),
            _buildVaultCard(context),
            const SizedBox(height: 24),
            _buildExportSection(context, ref, tasksAsync, activitiesAsync),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const TaskBottomSheet(),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        heroTag: 'dashboard_fab',
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
      ),
    );
  }


  Widget _buildHeader(WidgetRef ref) {
    final name = ref.watch(userProvider);
    final hour = DateTime.now().hour;
    String greeting = "Good evening";
    if (hour < 12) greeting = "Good morning";
    else if (hour < 17) greeting = "Good afternoon";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$greeting, $name",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          DateFormat('EEEE, d MMMM').format(DateTime.now()),
          style: TextStyle(color: AppTheme.secondaryText, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildVaultCard(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VaultScreen())),
        leading: const Icon(Icons.folder_shared_outlined, color: AppTheme.primaryColor),
        title: const Text("My Storage Vault", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Access all your resumes, certificates and files"),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildPressureCard(AsyncValue<List<Task>> tasksAsync, AsyncValue<List<Activity>> activitiesAsync) {
    if (tasksAsync.isLoading || activitiesAsync.isLoading) {
      return const Card(child: Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())));
    }

    final score = calcPressureScore(tasksAsync.value ?? <Task>[], activitiesAsync.value ?? <Activity>[]);
    Color scoreColor = Colors.green;
    String label = "All clear";
    
    if (score > 50) {
      scoreColor = Colors.red;
      label = "High pressure";
    } else if (score > 20) {
      scoreColor = Colors.orange;
      label = "Moderate load";
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    color: scoreColor,
                    backgroundColor: scoreColor.withOpacity(0.1),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  "$score",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: scoreColor),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Pressure Score", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(label, style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTasks(BuildContext context, List<Task> todayTasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Today's Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (todayTasks.isEmpty)
          const EmptyState(
            icon: Icons.today,
            title: "Free day!",
            subtitle: "No tasks scheduled for today",
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: todayTasks.map((task) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(task.title),
                    onPressed: () {},
                    avatar: CircleAvatar(
                      radius: 4,
                      backgroundColor: task.status == 'completed' ? Colors.green : (task.status == 'in_progress' ? Colors.blue : Colors.orange),
                    ),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildActiveActivities(BuildContext context, AsyncValue<List<Activity>> activitiesAsync) {
    final activities = (activitiesAsync.value ?? <Activity>[]).where((a) => a.progress < 100).toList();
    activities.sort((a, b) => a.deadline.compareTo(b.deadline));
    final display = activities.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Active Projects", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (activities.length > 3)
              TextButton(
                onPressed: () {},
                child: const Text("See all"),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (display.isEmpty)
          const Text("No active projects. Start tracking something!")
        else
          ...display.map((a) {
            final diff = a.deadline.difference(DateTime.now()).inDays;
            final deadlineText = diff == 0 ? "Due Today" : (diff < 0 ? "Overdue" : "$diff days left");
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(a.type.toUpperCase(), style: const TextStyle(fontSize: 10)),
                trailing: Text(
                  deadlineText,
                  style: TextStyle(
                    color: (diff <= 2) ? Colors.red : AppTheme.secondaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildExportSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Task>> tasksAsync,
    AsyncValue<List<Activity>> activitiesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Exports", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await CsvExporter.exportTasksCSV(tasksAsync.value ?? []);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tasks exported successfully")));
                  }
                },
                icon: const Icon(Icons.file_download_outlined),
                label: const Text("Tasks CSV", style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await CsvExporter.exportActivitiesCSV(activitiesAsync.value ?? []);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Activities exported successfully")));
                  }
                },
                icon: const Icon(Icons.file_download_outlined),
                label: const Text("Activities CSV", style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final name = prefs.getString('user_name') ?? 'User';
              await PdfExporter.exportAchievementPDF(
                userName: name,
                activities: activitiesAsync.value ?? [],
                tasks: tasksAsync.value ?? [],
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Achievement PDF generated successfully")));
              }
            },
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text("Generate Achievement PDF"),
          ),
        ),
      ],
    );
  }
}
