import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preppilot/features/activities/model/activity_model.dart';
import 'package:preppilot/features/activities/repo/activity_repo.dart';
import 'package:preppilot/features/notifications/rules/notification_rules.dart';

final activityRepositoryProvider = Provider((ref) => ActivityRepository());

class ActivityNotifier extends AsyncNotifier<List<Activity>> {
  @override
  FutureOr<List<Activity>> build() async {
    return _fetchAllActivities();
  }

  Future<List<Activity>> _fetchAllActivities() async {
    final repo = ref.read(activityRepositoryProvider);
    return await repo.getAllActivities();
  }

  Future<void> refreshActivities() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAllActivities());
  }

  Future<void> addActivity(Activity activity) async {
    final repo = ref.read(activityRepositoryProvider);
    final id = await repo.insertActivity(activity);
    NotificationRules.onActivityCreatedOrUpdated(activity.copyWith(activityId: id));
    await refreshActivities();
  }

  Future<void> updateActivity(Activity activity) async {
    final repo = ref.read(activityRepositoryProvider);
    await repo.updateActivity(activity);
    NotificationRules.onActivityCreatedOrUpdated(activity);
    await refreshActivities();
  }

  Future<void> deleteActivity(int id) async {
    final repo = ref.read(activityRepositoryProvider);
    await repo.deleteActivity(id);
    NotificationRules.onActivityDeleted(id);
    await refreshActivities();
  }
}

final activityNotifierProvider = AsyncNotifierProvider<ActivityNotifier, List<Activity>>(() {
  return ActivityNotifier();
});

final filteredActivitiesProvider = Provider.family<List<Activity>, String>((ref, type) {
  final allActivitiesAsync = ref.watch(activityNotifierProvider);
  return allActivitiesAsync.when(
    data: (activities) {
      if (type == 'All') return activities;
      return activities.where((a) => a.type.toLowerCase() == type.toLowerCase()).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
