import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/features/activities/model/activity_model.dart';
import 'package:preppilot/features/activities/provider/activity_provider.dart';
import 'package:preppilot/features/vault/provider/vault_provider.dart';
import 'package:preppilot/features/vault/widgets/attach_file_button.dart';
import 'package:open_file/open_file.dart';

class ActivityBottomSheet extends ConsumerStatefulWidget {
  final Activity? activity;

  const ActivityBottomSheet({super.key, this.activity});

  @override
  ConsumerState<ActivityBottomSheet> createState() => _ActivityBottomSheetState();
}

class _ActivityBottomSheetState extends ConsumerState<ActivityBottomSheet> {
  final _nameController = TextEditingController();
  final _platformController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _type = 'hackathon';
  DateTime _deadline = DateTime.now();
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      _nameController.text = widget.activity!.name;
      _platformController.text = widget.activity!.platform;
      _notesController.text = widget.activity!.notes ?? '';
      _type = widget.activity!.type;
      _deadline = widget.activity!.deadline;
      _progress = widget.activity!.progress;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _platformController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  void _saveActivity() {
    if (_nameController.text.isEmpty || _platformController.text.isEmpty) return;

    final activity = Activity(
      activityId: widget.activity?.activityId,
      name: _nameController.text,
      platform: _platformController.text,
      type: _type,
      deadline: _deadline,
      progress: _progress,
      notes: _notesController.text,
    );

    if (widget.activity == null) {
      ref.read(activityNotifierProvider.notifier).addActivity(activity);
    } else {
      ref.read(activityNotifierProvider.notifier).updateActivity(activity);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.activity == null ? 'Add Activity' : 'Edit Activity',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Activity Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _platformController,
              decoration: const InputDecoration(
                hintText: 'Platform (e.g. GitHub, Coursera, Devpost)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _typeChip('Hackathon', 'hackathon'),
                const SizedBox(width: 8),
                _typeChip('Cert', 'cert'),
                const SizedBox(width: 8),
                _typeChip('Course', 'course'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Deadline', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text("${_deadline.day}/${_deadline.month}/${_deadline.year}"),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('$_progress%'),
              ],
            ),
            Slider(
              value: _progress.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: AppTheme.primaryColor,
              onChanged: (val) => setState(() => _progress = val.toInt()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Activity'),
              ),
            ),
            if (widget.activity != null) ...[
              const SizedBox(height: 24),
              const Text('Attached Files', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildAttachedFilesList(),
              const SizedBox(height: 12),
              AttachFileButton(linkedType: 'activity', linkedId: widget.activity!.activityId!),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachedFilesList() {
    final files = ref.watch(filesByLinkedItemProvider(('activity', widget.activity!.activityId!)));
    if (files.isEmpty) return const Text("No files attached", style: TextStyle(fontSize: 12, color: AppTheme.secondaryText));
    
    return Column(
      children: files.map((f) => ListTile(
        leading: const Icon(Icons.attach_file, size: 18),
        title: Text(f.label, style: const TextStyle(fontSize: 14)),
        dense: true,
        onTap: () => OpenFile.open(f.localUri),
      )).toList(),
    );
  }

  Widget _typeChip(String label, String value) {
    final isSelected = _type == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _type = value);
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
