import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paper.dart';
import '../services/arxiv_service.dart';
import '../services/storage_service.dart';
import '../core/constants/app_constants.dart';

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final arxivServiceProvider = Provider<ArxivService>((ref) {
  final service = ArxivService();
  ref.onDispose(service.dispose);
  return service;
});

// ---------------------------------------------------------------------------
// Fetch count (slider value)
// ---------------------------------------------------------------------------

final fetchCountProvider = StateProvider<int>(
  (ref) => AppConstants.defaultFetchCount,
);

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

final themeModeProvider = StateProvider<ThemeMode>(
  (ref) => ThemeMode.dark,
);

// ---------------------------------------------------------------------------
// Read status
// ---------------------------------------------------------------------------

class ReadStatusNotifier extends StateNotifier<Set<String>> {
  final StorageService _storage;

  ReadStatusNotifier(this._storage) : super({});

  Future<void> load() async {
    state = await _storage.loadReadIds();
  }

  Future<void> markRead(String paperId) async {
    state = {...state, paperId};
    await _storage.saveReadIds(state);
  }

  bool isRead(String paperId) => state.contains(paperId);
}

final readStatusProvider =
    StateNotifierProvider<ReadStatusNotifier, Set<String>>((ref) {
  return ReadStatusNotifier(ref.read(storageServiceProvider));
});

// ---------------------------------------------------------------------------
// Papers
// ---------------------------------------------------------------------------

enum FetchStatus { idle, loading, success, error }

class PapersState {
  final List<Paper> papers;
  final FetchStatus status;
  final String? errorMessage;
  final DateTime? lastFetched;

  const PapersState({
    this.papers = const [],
    this.status = FetchStatus.idle,
    this.errorMessage,
    this.lastFetched,
  });

  PapersState copyWith({
    List<Paper>? papers,
    FetchStatus? status,
    String? errorMessage,
    DateTime? lastFetched,
    bool clearError = false,
  }) {
    return PapersState(
      papers: papers ?? this.papers,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFetched: lastFetched ?? this.lastFetched,
    );
  }

  bool get isEmpty => papers.isEmpty;
  bool get isLoading => status == FetchStatus.loading;
  bool get hasError => status == FetchStatus.error;
}

class PapersNotifier extends StateNotifier<PapersState> {
  final ArxivService _arxiv;
  final StorageService _storage;

  PapersNotifier(this._arxiv, this._storage) : super(const PapersState());

  Future<void> loadFromCache() async {
    final cached = await _storage.loadPapers();
    final lastFetched = await _storage.loadLastFetchTime();
    if (cached.isNotEmpty) {
      state = state.copyWith(
        papers: cached,
        status: FetchStatus.success,
        lastFetched: lastFetched,
      );
    }
  }

  Future<void> fetchPapers(int count) async {
    state = state.copyWith(
      status: FetchStatus.loading,
      clearError: true,
    );

    try {
      final papers = await _arxiv.fetchPapers(count);
      final now = DateTime.now();
      await _storage.savePapers(papers);
      await _storage.saveLastFetchTime(now);
      state = state.copyWith(
        papers: papers,
        status: FetchStatus.success,
        lastFetched: now,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: FetchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final papersProvider =
    StateNotifierProvider<PapersNotifier, PapersState>((ref) {
  return PapersNotifier(
    ref.read(arxivServiceProvider),
    ref.read(storageServiceProvider),
  );
});
