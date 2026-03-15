import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/features/tasks/model/task_model.dart';
import 'package:preppilot/features/tasks/provider/task_provider.dart';
import 'package:preppilot/features/tasks/widgets/task_card.dart';
import 'package:preppilot/features/tasks/widgets/task_bottom_sheet.dart';
import 'package:preppilot/features/activities/model/activity_model.dart';
import 'package:preppilot/features/activities/provider/activity_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final allTasksAsync = ref.watch(taskNotifierProvider);
    final allActivitiesAsync = ref.watch(activityNotifierProvider);
    
    final selectedDayTasks = _selectedDay != null 
        ? ref.watch(tasksByDateProvider(_selectedDay!)) 
        : <Task>[];
        
    final selectedDayActivities = _selectedDay != null
        ? _getActivitiesForDay(allActivitiesAsync.value ?? [], _selectedDay!)
        : <Activity>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning'),
      ),
      body: Column(
        children: [
          _buildCalendar(allTasksAsync, allActivitiesAsync),
          const Divider(height: 1),
          Expanded(
            child: _buildCombinedList(selectedDayTasks, selectedDayActivities),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => TaskBottomSheet(initialDate: _selectedDay),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<Activity> _getActivitiesForDay(List<Activity> activities, DateTime day) {
    final dateStr = day.toIso8601String().split('T')[0];
    return activities.where((a) => a.deadline.toIso8601String().split('T')[0] == dateStr).toList();
  }

  Widget _buildCalendar(AsyncValue<List<Task>> tasksAsync, AsyncValue<List<Activity>> activitiesAsync) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarFormat: CalendarFormat.month,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: const CalendarStyle(
        selectedDecoration: BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
        todayDecoration: BoxDecoration(color: Color(0x4D5C6BC0), shape: BoxShape.circle),
      ),
      eventLoader: (day) {
        final dateStr = day.toIso8601String().split('T')[0];
        final dayTasks = tasksAsync.value?.where((t) => t.date.toIso8601String().split('T')[0] == dateStr).toList() ?? [];
        final dayActivities = activitiesAsync.value?.where((a) => a.deadline.toIso8601String().split('T')[0] == dateStr).toList() ?? [];
        return [...dayTasks, ...dayActivities];
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return const SizedBox();
          
          final hasTask = events.any((e) => e is Task);
          final hasActivity = events.any((e) => e is Activity);
          
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasTask)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                ),
              if (hasActivity)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCombinedList(List<Task> tasks, List<Activity> activities) {
    if (tasks.isEmpty && activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: AppTheme.secondaryText.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No events for this day', style: TextStyle(color: AppTheme.secondaryText)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...tasks.map((task) => TaskCard(task: task)),
        ...activities.map((activity) => _ActivityDeadlineCard(activity: activity)),
      ],
    );
  }
}

class _ActivityDeadlineCard extends StatelessWidget {
  final Activity activity;
  const _ActivityDeadlineCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(activity.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${activity.type} • ${activity.platform}", style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
          child: const Text("Deadline", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
        ),
      ),
    );
  }
}
