import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/features/vault/model/file_index_model.dart';
import 'package:preppilot/features/vault/provider/vault_provider.dart';

class AttachFileButton extends ConsumerWidget {
  final String linkedType;
  final int linkedId;

  const AttachFileButton({
    super.key,
    required this.linkedType,
    required this.linkedId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => _pickAndAttach(ref),
      icon: const Icon(Icons.attach_file),
      label: const Text('Attach File'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
        side: const BorderSide(color: AppTheme.primaryColor),
      ),
    );
  }

  Future<void> _pickAndAttach(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final extension = file.extension?.toLowerCase();
      
      String type = 'other';
      if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) type = 'image';
      else if (extension == 'pdf') type = 'pdf';
      else if (['doc', 'docx', 'txt'].contains(extension)) type = 'doc';

      final fileIndex = FileIndex(
        linkedType: linkedType,
        linkedId: linkedId,
        label: file.name,
        localUri: file.path!,
        fileType: type,
        createdAt: DateTime.now().toIso8601String(),
      );

      ref.read(vaultNotifierProvider.notifier).addFile(fileIndex);
    }
  }
}
