import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/news_item.dart';
import '../models/paper.dart';
import '../services/backend_service.dart';
import '../services/storage_service.dart';

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------

final backendServiceProvider = Provider<BackendService>((ref) {
  final service = BackendService();
  ref.onDispose(service.dispose);
  return service;
});

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// ---------------------------------------------------------------------------
// Fetch limits
// ---------------------------------------------------------------------------

final papersFetchLimitProvider = StateProvider<int>((ref) => 25);
final newsFetchLimitProvider = StateProvider<int>((ref) => 25);

// ---------------------------------------------------------------------------
// Briefing
// ---------------------------------------------------------------------------

final briefingProvider = StateProvider<String?>((ref) => null);
final activeReportNameProvider = StateProvider<String?>((ref) => null);

// ---------------------------------------------------------------------------
// Agent status (for loading indicator)
// ---------------------------------------------------------------------------

enum AgentStatus { idle, loading, success, error }

final papersAgentStatusProvider = StateProvider<AgentStatus>((ref) => AgentStatus.idle);
final newsAgentStatusProvider = StateProvider<AgentStatus>((ref) => AgentStatus.idle);
final summarizeAgentStatusProvider = StateProvider<AgentStatus>((ref) => AgentStatus.idle);

// ---------------------------------------------------------------------------
// Reports
// ---------------------------------------------------------------------------

class ReportsNotifier extends StateNotifier<AsyncValue<List<ReportSummary>>> {
  final BackendService _backend;

  ReportsNotifier(this._backend) : super(const AsyncValue.data([]));

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final reports = await _backend.getReports();
      state = AsyncValue.data(reports);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, AsyncValue<List<ReportSummary>>>((ref) {
  return ReportsNotifier(ref.read(backendServiceProvider));
});

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

  const PapersState({
    this.papers = const [],
    this.status = FetchStatus.idle,
    this.errorMessage,
  });

  PapersState copyWith({
    List<Paper>? papers,
    FetchStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PapersState(
      papers: papers ?? this.papers,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isEmpty => papers.isEmpty;
  bool get isLoading => status == FetchStatus.loading;
  bool get hasError => status == FetchStatus.error;
}

class PapersNotifier extends StateNotifier<PapersState> {
  final BackendService _backend;

  PapersNotifier(this._backend) : super(const PapersState());

  Future<void> loadPapers() async {
    state = state.copyWith(status: FetchStatus.loading, clearError: true);
    try {
      final papers = await _backend.getPapers();
      state = state.copyWith(papers: papers, status: FetchStatus.success);
    } catch (e) {
      state = state.copyWith(status: FetchStatus.error, errorMessage: e.toString());
    }
  }

  void setLoading() => state = state.copyWith(status: FetchStatus.loading, clearError: true);

  void setPapers(List<Paper> papers) =>
      state = state.copyWith(papers: papers, status: FetchStatus.success);

  void setError(String message) =>
      state = state.copyWith(status: FetchStatus.error, errorMessage: message);
}

final papersProvider = StateNotifierProvider<PapersNotifier, PapersState>((ref) {
  return PapersNotifier(ref.read(backendServiceProvider));
});

// ---------------------------------------------------------------------------
// News
// ---------------------------------------------------------------------------

class NewsState {
  final List<NewsItem> items;
  final FetchStatus status;
  final String? errorMessage;

  const NewsState({
    this.items = const [],
    this.status = FetchStatus.idle,
    this.errorMessage,
  });

  NewsState copyWith({
    List<NewsItem>? items,
    FetchStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NewsState(
      items: items ?? this.items,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isEmpty => items.isEmpty;
  bool get isLoading => status == FetchStatus.loading;
  bool get hasError => status == FetchStatus.error;
}

class NewsNotifier extends StateNotifier<NewsState> {
  final BackendService _backend;

  NewsNotifier(this._backend) : super(const NewsState());

  Future<void> loadNews() async {
    state = state.copyWith(status: FetchStatus.loading, clearError: true);
    try {
      final items = await _backend.getNews();
      state = state.copyWith(items: items, status: FetchStatus.success);
    } catch (e) {
      state = state.copyWith(status: FetchStatus.error, errorMessage: e.toString());
    }
  }

  void setLoading() => state = state.copyWith(status: FetchStatus.loading, clearError: true);

  void setNews(List<NewsItem> items) =>
      state = state.copyWith(items: items, status: FetchStatus.success);

  void setError(String message) =>
      state = state.copyWith(status: FetchStatus.error, errorMessage: message);
}

final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  return NewsNotifier(ref.read(backendServiceProvider));
});
