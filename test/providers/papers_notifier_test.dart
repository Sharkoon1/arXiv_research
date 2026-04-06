import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:arxiv_research/models/paper.dart';
import 'package:arxiv_research/providers/providers.dart';
import 'package:arxiv_research/services/arxiv_service.dart';
import 'package:arxiv_research/services/storage_service.dart';

class MockArxivService extends Mock implements ArxivService {}

class MockStorageService extends Mock implements StorageService {}

const _paper = Paper(
  id: 'https://arxiv.org/abs/2401.00001',
  title: 'Test',
  abstract: 'Abstract.',
  authors: ['Alice'],
  publishedDate: '2024-01-15T00:00:00Z',
  pdfUrl: 'https://arxiv.org/pdf/2401.00001',
  abstractUrl: 'https://arxiv.org/abs/2401.00001',
  primaryCategory: 'cs.AI',
);

ProviderContainer makeContainer({
  required ArxivService arxiv,
  required StorageService storage,
}) {
  return ProviderContainer(
    overrides: [
      arxivServiceProvider.overrideWithValue(arxiv),
      storageServiceProvider.overrideWithValue(storage),
    ],
  );
}

void main() {
  late MockArxivService mockArxiv;
  late MockStorageService mockStorage;

  setUp(() {
    mockArxiv = MockArxivService();
    mockStorage = MockStorageService();

    when(() => mockStorage.loadPapers()).thenAnswer((_) async => []);
    when(() => mockStorage.loadLastFetchTime()).thenAnswer((_) async => null);
    when(() => mockStorage.savePapers(any())).thenAnswer((_) async {});
    when(() => mockStorage.saveLastFetchTime(any())).thenAnswer((_) async {});
    when(() => mockStorage.loadReadIds()).thenAnswer((_) async => {});
    when(() => mockArxiv.dispose()).thenReturn(null);
  });

  group('PapersNotifier', () {
    test('starts in idle state', () {
      final container = makeContainer(arxiv: mockArxiv, storage: mockStorage);
      addTearDown(container.dispose);

      final state = container.read(papersProvider);
      expect(state.status, FetchStatus.idle);
      expect(state.papers, isEmpty);
    });

    test('loadFromCache populates papers from storage', () async {
      when(() => mockStorage.loadPapers()).thenAnswer((_) async => [_paper]);
      when(() => mockStorage.loadLastFetchTime())
          .thenAnswer((_) async => DateTime(2024, 1, 15));

      final container = makeContainer(arxiv: mockArxiv, storage: mockStorage);
      addTearDown(container.dispose);

      await container.read(papersProvider.notifier).loadFromCache();

      final state = container.read(papersProvider);
      expect(state.papers.length, 1);
      expect(state.status, FetchStatus.success);
    });

    test('fetchPapers transitions to success', () async {
      when(() => mockArxiv.fetchPapers(any()))
          .thenAnswer((_) async => [_paper]);

      final container = makeContainer(arxiv: mockArxiv, storage: mockStorage);
      addTearDown(container.dispose);

      await container.read(papersProvider.notifier).fetchPapers(10);

      final state = container.read(papersProvider);
      expect(state.status, FetchStatus.success);
      expect(state.papers, [_paper]);
    });

    test('fetchPapers transitions to error on exception', () async {
      when(() => mockArxiv.fetchPapers(any()))
          .thenThrow(const ArxivException('network error'));

      final container = makeContainer(arxiv: mockArxiv, storage: mockStorage);
      addTearDown(container.dispose);

      await container.read(papersProvider.notifier).fetchPapers(10);

      final state = container.read(papersProvider);
      expect(state.status, FetchStatus.error);
      expect(state.errorMessage, 'network error');
    });
  });

  group('ReadStatusNotifier', () {
    test('markRead adds id to state and persists', () async {
      when(() => mockStorage.saveReadIds(any())).thenAnswer((_) async {});

      final container = makeContainer(arxiv: mockArxiv, storage: mockStorage);
      addTearDown(container.dispose);

      await container.read(readStatusProvider.notifier).markRead('id-1');

      expect(container.read(readStatusProvider), contains('id-1'));
      verify(() => mockStorage.saveReadIds({'id-1'})).called(1);
    });
  });
}
