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

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final activitiesAsync = ref.watch(activityNotifierProvider);
    final todayTasks = ref.watch(todayTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PrepPilot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildPressureCard(tasksAsync, activitiesAsync),
            const SizedBox(height: 24),
            _buildTodayTasks(context, todayTasks),
            const SizedBox(height: 24),
            _buildActiveActivities(context, activitiesAsync),
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
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        final name = snapshot.data?.getString('user_name') ?? 'User';
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
      },
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
          InkWell(
            onTap: () {
               // Plan tab is index 2
               // We'll need a way to navigate from here, usually via a provider or scaffold key
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
                  SizedBox(width: 12),
                  Text("No tasks today. Add one?", style: TextStyle(color: AppTheme.primaryColor)),
                ],
              ),
            ),
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
}
