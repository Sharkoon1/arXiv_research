import 'package:arxiv_research/models/news_item.dart';
import 'package:arxiv_research/models/paper.dart';
import 'package:arxiv_research/providers/providers.dart';
import 'package:arxiv_research/core/utils/api_exception.dart';
import 'package:arxiv_research/services/news_service.dart';
import 'package:arxiv_research/services/papers_service.dart';
import 'package:arxiv_research/services/reports_service.dart';
import 'package:arxiv_research/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPapersService extends Mock implements PapersService {}
class MockNewsService extends Mock implements NewsService {}
class MockReportsService extends Mock implements ReportsService {}
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
  required PapersService papers,
  required NewsService news,
  required ReportsService reports,
  required StorageService storage,
}) {
  return ProviderContainer(overrides: [
    papersServiceProvider.overrideWithValue(papers),
    newsServiceProvider.overrideWithValue(news),
    reportsServiceProvider.overrideWithValue(reports),
    storageServiceProvider.overrideWithValue(storage),
  ]);
}

void main() {
  late MockPapersService mockPapers;
  late MockNewsService mockNews;
  late MockReportsService mockReports;
  late MockStorageService mockStorage;

  setUp(() {
    mockPapers = MockPapersService();
    mockNews = MockNewsService();
    mockReports = MockReportsService();
    mockStorage = MockStorageService();

    when(() => mockStorage.loadReadIds()).thenAnswer((_) async => {});
    when(() => mockPapers.dispose()).thenReturn(null);
    when(() => mockNews.dispose()).thenReturn(null);
    when(() => mockReports.dispose()).thenReturn(null);
  });

  group('PapersNotifier', () {
    test('starts in idle state', () {
      final container = makeContainer(
        papers: mockPapers,
        news: mockNews,
        reports: mockReports,
        storage: mockStorage,
      );
      addTearDown(container.dispose);
      expect(container.read(papersProvider).status, FetchStatus.idle);
    });

    test('loadPapers transitions to success', () async {
      when(() => mockPapers.fetchAll()).thenAnswer((_) async => [_paper]);

      final container = makeContainer(
        papers: mockPapers,
        news: mockNews,
        reports: mockReports,
        storage: mockStorage,
      );
      addTearDown(container.dispose);

      await container.read(papersProvider.notifier).loadPapers();

      final state = container.read(papersProvider);
      expect(state.status, FetchStatus.success);
      expect(state.papers, [_paper]);
    });

    test('loadPapers transitions to error on exception', () async {
      when(() => mockPapers.fetchAll())
          .thenThrow(const ApiException('network error'));

      final container = makeContainer(
        papers: mockPapers,
        news: mockNews,
        reports: mockReports,
        storage: mockStorage,
      );
      addTearDown(container.dispose);

      await container.read(papersProvider.notifier).loadPapers();

      final state = container.read(papersProvider);
      expect(state.status, FetchStatus.error);
      expect(state.errorMessage, 'network error');
    });
  });

  group('NewsNotifier', () {
    test('loadNews transitions to success', () async {
      when(() => mockNews.fetchAll()).thenAnswer((_) async => [_news]);

      final container = makeContainer(
        papers: mockPapers,
        news: mockNews,
        reports: mockReports,
        storage: mockStorage,
      );
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

      final container = makeContainer(
        papers: mockPapers,
        news: mockNews,
        reports: mockReports,
        storage: mockStorage,
      );
      addTearDown(container.dispose);

      await container.read(readStatusProvider.notifier).markRead('id-1');

      expect(container.read(readStatusProvider), contains('id-1'));
      verify(() => mockStorage.saveReadIds({'id-1'})).called(1);
    });
  });
}
