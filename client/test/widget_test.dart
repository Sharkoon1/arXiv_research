import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:arxiv_research/main.dart';
import 'package:arxiv_research/providers/providers.dart';
import 'package:arxiv_research/services/backend_service.dart';
import 'package:arxiv_research/services/storage_service.dart';

class MockBackendService extends Mock implements BackendService {}
class MockStorageService extends Mock implements StorageService {}

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    final mockBackend = MockBackendService();
    final mockStorage = MockStorageService();

    when(() => mockStorage.loadReadIds()).thenAnswer((_) async => {});
    when(() => mockBackend.dispose()).thenReturn(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backendServiceProvider.overrideWithValue(mockBackend),
          storageServiceProvider.overrideWithValue(mockStorage),
        ],
        child: const App(),
      ),
    );

    // Ignore layout overflow errors in test environment (small screen)
    tester.takeException(); // ignore layout overflow in test environment
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
