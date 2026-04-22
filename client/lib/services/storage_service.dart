import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/report.dart';

class StorageService {
  Future<Set<String>> loadReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(AppConstants.prefsKeyReadIds);
    if (json == null) return {};
    final list = (jsonDecode(json) as List).cast<String>();
    return list.toSet();
  }

  Future<void> saveReadIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.prefsKeyReadIds,
      jsonEncode(ids.toList()),
    );
  }

  Future<ReportDetail?> loadLastReport() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(AppConstants.prefsKeyLastReport);
    if (json == null) return null;
    try {
      return ReportDetail.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      await prefs.remove(AppConstants.prefsKeyLastReport);
      return null;
    }
  }

  Future<void> saveLastReport(ReportDetail report) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.prefsKeyLastReport,
      jsonEncode(report.toJson()),
    );
  }
}
