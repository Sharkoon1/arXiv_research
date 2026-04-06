import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:arxiv_research/services/arxiv_service.dart';

class MockHttpClient extends Mock implements http.Client {}

const _minimalFeed = '''<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <id>https://arxiv.org/abs/2401.00001v1</id>
    <title>Paper</title>
    <summary>Abstract.</summary>
    <published>2024-01-15T00:00:00Z</published>
    <author><name>Alice</name></author>
    <link rel="alternate" href="https://arxiv.org/abs/2401.00001v1"/>
  </entry>
</feed>''';

void main() {
  late MockHttpClient mockClient;
  late ArxivService service;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockClient = MockHttpClient();
    service = ArxivService(client: mockClient);
  });

  tearDown(() => service.dispose());

  group('ArxivService.fetchPapers', () {
    test('returns papers on HTTP 200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(_minimalFeed, 200));

      final papers = await service.fetchPapers(10);
      expect(papers.length, 1);
      expect(papers.first.title, 'Paper');
    });

    test('throws ArxivException on non-200 status', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('error', 503));

      expect(
        () => service.fetchPapers(10),
        throwsA(isA<ArxivException>()),
      );
    });

    test('clamps fetch count to maxFetchCount', () async {
      Uri? capturedUri;
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((invocation) async {
        capturedUri = invocation.positionalArguments.first as Uri;
        return http.Response(_minimalFeed, 200);
      });

      await service.fetchPapers(9999);
      expect(capturedUri?.queryParameters['max_results'], '100');
    });

    test('clamps fetch count to minFetchCount', () async {
      Uri? capturedUri;
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((invocation) async {
        capturedUri = invocation.positionalArguments.first as Uri;
        return http.Response(_minimalFeed, 200);
      });

      await service.fetchPapers(1);
      expect(capturedUri?.queryParameters['max_results'], '5');
    });
  });
}
