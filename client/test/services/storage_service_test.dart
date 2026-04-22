import 'dart:convert';

import 'package:arxiv_research/core/constants/app_constants.dart';
import 'package:arxiv_research/models/report.dart';
import 'package:arxiv_research/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

ReportDetail _buildReport() => ReportDetail(
      id: 'report-1',
      name: 'Morning briefing',
      briefing: 'Highlights.',
      papers: const [],
      news: const [],
      createdAt: DateTime.parse('2024-01-15T08:00:00Z'),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('StorageService.readIds', () {
    test('returns empty set when nothing stored', () async {
      final ids = await StorageService().loadReadIds();
      expect(ids, isEmpty);
    });

    test('persists and reloads ids', () async {
      final service = StorageService();
      await service.saveReadIds({'a', 'b'});
      expect(await service.loadReadIds(), {'a', 'b'});
    });
  });

  group('StorageService.lastReport', () {
    test('returns null when nothing cached', () async {
      expect(await StorageService().loadLastReport(), isNull);
    });

    test('roundtrips a ReportDetail', () async {
      final service = StorageService();
      final report = _buildReport();

      await service.saveLastReport(report);
      final loaded = await service.loadLastReport();

      expect(loaded, isNotNull);
      expect(loaded!.id, report.id);
      expect(loaded.name, report.name);
      expect(loaded.briefing, report.briefing);
      expect(loaded.createdAt, report.createdAt);
    });

    test('discards corrupt cached payload', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefsKeyLastReport: jsonEncode({'not': 'a report'}),
      });

      expect(await StorageService().loadLastReport(), isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppConstants.prefsKeyLastReport), isNull);
    });
  });
}
