import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preppilot/features/vault/model/file_index_model.dart';
import 'package:preppilot/features/vault/repo/vault_repo.dart';

final vaultRepositoryProvider = Provider((ref) => VaultRepository());

class VaultNotifier extends AsyncNotifier<List<FileIndex>> {
  @override
  FutureOr<List<FileIndex>> build() async {
    return _fetchAllFiles();
  }

  Future<List<FileIndex>> _fetchAllFiles() async {
    final repo = ref.read(vaultRepositoryProvider);
    return await repo.getAllFiles();
  }

  Future<void> refreshFiles() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAllFiles());
  }

  Future<void> addFile(FileIndex file) async {
    final repo = ref.read(vaultRepositoryProvider);
    await repo.insertFile(file);
    await refreshFiles();
  }

  Future<void> deleteFile(int fileId) async {
    final repo = ref.read(vaultRepositoryProvider);
    await repo.deleteFile(fileId);
    await refreshFiles();
  }
}

final vaultNotifierProvider = AsyncNotifierProvider<VaultNotifier, List<FileIndex>>(() {
  return VaultNotifier();
});

final filesByLinkedItemProvider = Provider.family<List<FileIndex>, (String, int)>((ref, arg) {
  final allFilesAsync = ref.watch(vaultNotifierProvider);
  return allFilesAsync.when(
    data: (files) {
      return files.where((f) => f.linkedType == arg.$1 && f.linkedId == arg.$2).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final filesByTypeProvider = Provider.family<List<FileIndex>, String>((ref, type) {
  final allFilesAsync = ref.watch(vaultNotifierProvider);
  return allFilesAsync.when(
    data: (files) {
      if (type == 'All') return files;
      return files.where((f) => f.fileType == type).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
