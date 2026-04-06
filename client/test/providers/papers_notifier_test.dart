import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:arxiv_research/models/paper.dart';
import 'package:arxiv_research/models/news_item.dart';
import 'package:arxiv_research/providers/providers.dart';
import 'package:arxiv_research/services/backend_service.dart';
import 'package:arxiv_research/services/storage_service.dart';

class MockBackendService extends Mock implements BackendService {}
class MockStorageService extends Mock implements StorageService {}

const _paper = Paper(
  id: 'uuid-1',
  title: 'Test',
  summary: 'Summary.',
  keyContribution: 'Contribution.',
  whyItMatters: 'Matters.',
  authors: ['Alice'],
  source: 'arXiv',
  url: 'https://arxiv.org/abs/2401.00001',
  publishedDate: '2024-01-15',
  category: 'LLM',
  importanceScore: 85,
);

const _news = NewsItem(
  id: 'uuid-2',
  title: 'AI News',
  summary: 'Summary.',
  whyItMatters: 'Matters.',
  sourceName: 'TechCrunch',
  url: 'https://techcrunch.com/article',
  publishedDate: '2024-01-15',
  category: 'industry',
  importanceScore: 80,
);

ProviderContainer makeContainer({
  required BackendService backend,
  required StorageService storage,
}) {
  return ProviderContainer(overrides: [
    backendServiceProvider.overrideWithValue(backend),
    storageServiceProvider.overrideWithValue(storage),
  ]);
}

void main() {
  late MockBackendService mockBackend;
  late MockStorageService mockStorage;

  setUp(() {
    mockBackend = MockBackendService();
    mockStorage = MockStorageService();

    when(() => mockStorage.loadReadIds()).thenAnswer((_) async => {});
    when(() => mockBackend.dispose()).thenReturn(null);
  });

  group('PapersNotifier', () {
    test('starts in idle state', () {
      final container = makeContainer(backend: mockBackend, storage: mockStorage);
      addTearDown(container.dispose);
      expect(container.read(papersProvider).status, FetchStatus.idle);
    });

    test('loadPapers transitions to success', () async {
      when(() => mockBackend.getPapers()).thenAnswer((_) async => [_paper]);

      final container = makeContainer(backend: mockBackend, storage: mockStorage);
      addTearDown(container.dispose);

      await container.read(papersProvider.notifier).loadPapers();

      final state = container.read(papersProvider);
      expect(state.status, FetchStatus.success);
      expect(state.papers, [_paper]);
    });

    test('loadPapers transitions to error on exception', () async {
      when(() => mockBackend.getPapers())
          .thenThrow(const BackendException('network error'));

      final container = makeContainer(backend: mockBackend, storage: mockStorage);
      addTearDown(container.dispose);

      await container.read(papersProvider.notifier).loadPapers();

      final state = container.read(papersProvider);
      expect(state.status, FetchStatus.error);
      expect(state.errorMessage, 'network error');
    });
  });

  group('NewsNotifier', () {
    test('loadNews transitions to success', () async {
      when(() => mockBackend.getNews()).thenAnswer((_) async => [_news]);

      final container = makeContainer(backend: mockBackend, storage: mockStorage);
      addTearDown(container.dispose);

      await container.read(newsProvider.notifier).loadNews();

      final state = container.read(newsProvider);
      expect(state.status, FetchStatus.success);
      expect(state.items, [_news]);
    });
  });

  group('ReadStatusNotifier', () {
    test('markRead adds id and persists', () async {
      when(() => mockStorage.saveReadIds(any())).thenAnswer((_) async {});

      final container = makeContainer(backend: mockBackend, storage: mockStorage);
      addTearDown(container.dispose);

      await container.read(readStatusProvider.notifier).markRead('id-1');

      expect(container.read(readStatusProvider), contains('id-1'));
      verify(() => mockStorage.saveReadIds({'id-1'})).called(1);
    });
  });
}
