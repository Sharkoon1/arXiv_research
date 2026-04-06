// Smoke test — verifies the app widget tree builds without crashing.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:arxiv_research/main.dart';
import 'package:arxiv_research/providers/providers.dart';
import 'package:arxiv_research/services/arxiv_service.dart';
import 'package:arxiv_research/services/storage_service.dart';

class MockArxivService extends Mock implements ArxivService {}
class MockStorageService extends Mock implements StorageService {}

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    final mockArxiv = MockArxivService();
    final mockStorage = MockStorageService();

    when(() => mockStorage.loadPapers()).thenAnswer((_) async => []);
    when(() => mockStorage.loadLastFetchTime()).thenAnswer((_) async => null);
    when(() => mockStorage.loadReadIds()).thenAnswer((_) async => {});
    when(() => mockArxiv.dispose()).thenReturn(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          arxivServiceProvider.overrideWithValue(mockArxiv),
          storageServiceProvider.overrideWithValue(mockStorage),
        ],
        child: const App(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
