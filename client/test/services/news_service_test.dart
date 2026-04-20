import 'dart:convert';

import 'package:arxiv_research/core/utils/api_exception.dart';
import 'package:arxiv_research/services/news_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

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
  late NewsService service;

  setUpAll(() => registerFallbackValue(Uri()));

  setUp(() {
    mockClient = MockHttpClient();
    service = NewsService(baseUrl: 'http://localhost:8000', client: mockClient);
  });

  group('NewsService.fetchAll', () {
    test('returns list of news on 200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode([_news]), 200));

      final news = await service.fetchAll();
      expect(news.length, 1);
      expect(news.first.title, 'AI News');
      expect(news.first.sourceName, 'TechCrunch');
      expect(news.first.importanceScore, 80);
    });

    test('throws ApiException on non-200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('error', 500));

      expect(() => service.fetchAll(), throwsA(isA<ApiException>()));
    });
  });
}
