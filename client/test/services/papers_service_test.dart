import 'dart:convert';

import 'package:arxiv_research/core/utils/api_exception.dart';
import 'package:arxiv_research/services/papers_service.dart';
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

void main() {
  late MockHttpClient mockClient;
  late PapersService service;

  setUpAll(() => registerFallbackValue(Uri()));

  setUp(() {
    mockClient = MockHttpClient();
    service = PapersService(baseUrl: 'http://localhost:8000', client: mockClient);
  });

  group('PapersService.fetchAll', () {
    test('returns list of papers on 200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode([_paper]), 200));

      final papers = await service.fetchAll();
      expect(papers.length, 1);
      expect(papers.first.title, 'Test Paper');
      expect(papers.first.keyContribution, 'Contribution.');
      expect(papers.first.importanceScore, 85);
    });

    test('throws ApiException on non-200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('error', 500));

      expect(() => service.fetchAll(), throwsA(isA<ApiException>()));
    });
  });
}
