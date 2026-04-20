import 'dart:convert';

import 'package:arxiv_research/core/utils/api_exception.dart';
import 'package:arxiv_research/services/reports_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

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

final _reportSummary = {
  'id': 'report-1',
  'name': 'Morning briefing',
  'created_at': '2024-01-15T08:00:00Z',
  'paper_count': 3,
  'news_count': 5,
};

final _reportDetail = {
  'id': 'report-1',
  'name': 'Morning briefing',
  'briefing': 'Highlights of the day.',
  'papers': [_paper],
  'news': [_news],
  'created_at': '2024-01-15T08:00:00Z',
};

final _collectResponse = {
  'report_id': 'report-1',
  'report_name': 'Morning briefing',
  'papers': [_paper],
  'news': [_news],
  'briefing': 'Highlights of the day.',
  'errors': <String>[],
};

void main() {
  late MockHttpClient mockClient;
  late ReportsService service;

  setUpAll(() => registerFallbackValue(Uri()));

  setUp(() {
    mockClient = MockHttpClient();
    service = ReportsService(baseUrl: 'http://localhost:8000', client: mockClient);
  });

  group('ReportsService.fetchAll', () {
    test('returns list of ReportSummary on 200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode([_reportSummary]), 200));

      final reports = await service.fetchAll();
      expect(reports.length, 1);
      expect(reports.first.id, 'report-1');
      expect(reports.first.paperCount, 3);
      expect(reports.first.newsCount, 5);
    });

    test('throws ApiException on non-200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('error', 500));

      expect(() => service.fetchAll(), throwsA(isA<ApiException>()));
    });
  });

  group('ReportsService.fetchById', () {
    test('returns ReportDetail with papers and news on 200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(_reportDetail), 200));

      final detail = await service.fetchById('report-1');
      expect(detail.id, 'report-1');
      expect(detail.briefing, 'Highlights of the day.');
      expect(detail.papers.length, 1);
      expect(detail.papers.first.title, 'Test Paper');
      expect(detail.news.length, 1);
      expect(detail.news.first.title, 'AI News');
    });

    test('throws ApiException on non-200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('error', 404));

      expect(() => service.fetchById('missing'), throwsA(isA<ApiException>()));
    });
  });

  group('ReportsService.startCollection', () {
    test('returns CollectResult with papers and news on 200', () async {
      when(() => mockClient.post(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(jsonEncode(_collectResponse), 200));

      final result = await service.startCollection(papersLimit: 10, newsLimit: 10);
      expect(result.reportId, 'report-1');
      expect(result.papers.length, 1);
      expect(result.papers.first.title, 'Test Paper');
      expect(result.news.length, 1);
      expect(result.news.first.title, 'AI News');
      expect(result.errors, isEmpty);
    });

    test('throws ApiException on non-200', () async {
      when(() => mockClient.post(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('error', 500));

      expect(
        () => service.startCollection(papersLimit: 10, newsLimit: 10),
        throwsA(isA<ApiException>()),
      );
    });

    test('omits paper_categories and news_categories when empty', () async {
      String? capturedBody;
      when(() => mockClient.post(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((invocation) async {
        capturedBody = invocation.namedArguments[#body] as String;
        return http.Response(jsonEncode(_collectResponse), 200);
      });

      await service.startCollection(papersLimit: 10, newsLimit: 10);

      final body = jsonDecode(capturedBody!) as Map<String, dynamic>;
      expect(body.containsKey('paper_categories'), isFalse);
      expect(body.containsKey('news_categories'), isFalse);
    });

    test('includes paper_categories and news_categories when provided', () async {
      String? capturedBody;
      when(() => mockClient.post(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((invocation) async {
        capturedBody = invocation.namedArguments[#body] as String;
        return http.Response(jsonEncode(_collectResponse), 200);
      });

      await service.startCollection(
        papersLimit: 10,
        newsLimit: 10,
        paperCategories: ['LLM'],
        newsCategories: ['industry'],
      );

      final body = jsonDecode(capturedBody!) as Map<String, dynamic>;
      expect(body['paper_categories'], ['LLM']);
      expect(body['news_categories'], ['industry']);
    });
  });
}
