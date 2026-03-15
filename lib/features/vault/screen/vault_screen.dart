import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/features/vault/model/file_index_model.dart';
import 'package:preppilot/features/vault/provider/vault_provider.dart';
import 'package:preppilot/shared/widgets/empty_state.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(vaultNotifierProvider);
    final files = ref.watch(filesByTypeProvider(_selectedFilter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Vault'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(vaultNotifierProvider.notifier).refreshFiles(),
        child: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: filesAsync.when(
                data: (_) => _buildFileContent(files),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => EmptyState(
                  icon: Icons.error_outline,
                  title: 'Something went wrong',
                  subtitle: e.toString(),
                  actionLabel: 'Retry',
                  onAction: () => ref.invalidate(vaultNotifierProvider),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndAddFile,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_link, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'image', 'pdf', 'doc', 'other'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          String label = filter[0].toUpperCase() + filter.substring(1);
          if (filter == 'doc') label = 'Docs';
          if (filter == 'pdf') label = 'PDFs';
          if (filter == 'image') label = 'Images';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
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

  Widget _buildFileContent(List<FileIndex> files) {
    if (files.isEmpty) {
      return EmptyState(
        icon: Icons.folder_open_outlined,
        title: 'No files yet',
        subtitle: _selectedFilter == 'All' 
            ? 'Attach files to any activity or project'
            : 'No $_selectedFilter files found',
      );
    }

    if (_selectedFilter == 'All' || _selectedFilter == 'image') {
      final imageFiles = files.where((f) => f.fileType == 'image').toList();
      final otherFiles = files.where((f) => f.fileType != 'image').toList();

      if (imageFiles.isNotEmpty && _selectedFilter == 'All') {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
             const Text("Images", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
             const SizedBox(height: 12),
             _buildImageGrid(imageFiles),
             const SizedBox(height: 24),
             if (otherFiles.isNotEmpty) ...[
                const Text("Files", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                ...otherFiles.map((f) => _buildFileListTile(f)),
             ],
          ],
        );
      }
      
      if (_selectedFilter == 'image') {
        return _buildImageGrid(imageFiles, padding: const EdgeInsets.all(16));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (context, index) => _buildFileListTile(files[index]),
    );
  }

  Widget _buildImageGrid(List<FileIndex> files, {EdgeInsets? padding}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) => _buildFileCard(files[index]),
    );
  }

  Widget _buildFileCard(FileIndex file) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => OpenFile.open(file.localUri),
        onLongPress: () => _confirmDelete(file),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey.shade100,
                child: const Icon(Icons.image, size: 40, color: Colors.teal),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                file.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileListTile(FileIndex file) {
    IconData icon;
    Color color;
    switch (file.fileType) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'doc':
        icon = Icons.description;
        color = Colors.indigo;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(file.label, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text("${file.fileType.toUpperCase()} • ${file.createdAt.split('T')[0]}"),
        onTap: () => OpenFile.open(file.localUri),
        onLongPress: () => _confirmDelete(file),
      ),
    );
  }

  Future<void> _pickAndAddFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final extension = file.extension?.toLowerCase();
      
      String type = 'other';
      if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) type = 'image';
      else if (extension == 'pdf') type = 'pdf';
      else if (['doc', 'docx', 'txt'].contains(extension)) type = 'doc';

      final fileIndex = FileIndex(
        linkedType: 'general',
        linkedId: 0,
        label: file.name,
        localUri: file.path!,
        fileType: type,
        createdAt: DateTime.now().toIso8601String(),
      );

      ref.read(vaultNotifierProvider.notifier).addFile(fileIndex);
    }
  }

  Future<void> _confirmDelete(FileIndex file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure you want to remove this file from your vault?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && file.fileId != null) {
      ref.read(vaultNotifierProvider.notifier).deleteFile(file.fileId!);
    }
  }
}
