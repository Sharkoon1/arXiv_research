import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:arxiv_research/services/backend_service.dart';

class MockHttpClient extends Mock implements http.Client {}

const _paper = {
  'id': 'uuid-1',
  'title': 'Test Paper',
  'summary': 'Summary.',
  'key_contribution': 'Contribution.',
  'why_it_matters': 'Matters.',
  'authors': ['Alice'],
  'source': 'arXiv',
  'url': 'https://arxiv.org/abs/2401.00001',
  'published_date': '2024-01-15',
  'category': 'LLM',
  'importance_score': 85,
};

const _news = {
  'id': 'uuid-2',
  'title': 'AI News',
  'summary': 'Summary.',
  'why_it_matters': 'Matters.',
  'source_name': 'TechCrunch',
  'url': 'https://techcrunch.com/article',
  'published_date': '2024-01-15',
  'category': 'industry',
  'importance_score': 80,
};

void main() {
  late MockHttpClient mockClient;
  late BackendService service;

  setUpAll(() => registerFallbackValue(Uri()));

  setUp(() {
    mockClient = MockHttpClient();
    service = BackendService(baseUrl: 'http://localhost:8000', client: mockClient);
  });

  group('BackendService.startCollection', () {
    test('returns CollectResult with papers and news on 200', () async {
      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'papers': [_paper],
                'news': [_news],
                'errors': [],
              }),
              200));

      final result = await service.startCollection(papersLimit: 10, newsLimit: 10);
      expect(result.papers.length, 1);
      expect(result.papers.first.title, 'Test Paper');
      expect(result.news.length, 1);
      expect(result.news.first.title, 'AI News');
      expect(result.errors, isEmpty);
    });

    test('throws BackendException on non-200', () async {
      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('error', 500));

      expect(() => service.startCollection(papersLimit: 10, newsLimit: 10),
          throwsA(isA<BackendException>()));
    });
  });

  group('BackendService.getPapers', () {
    test('returns list of papers on 200', () async {
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(jsonEncode([_paper]), 200));

      final papers = await service.getPapers();
      expect(papers.length, 1);
      expect(papers.first.title, 'Test Paper');
    });
  });

  group('BackendService.getNews', () {
    test('returns list of news on 200', () async {
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(jsonEncode([_news]), 200));

      final news = await service.getNews();
      expect(news.length, 1);
      expect(news.first.title, 'AI News');
    });
  });
}
