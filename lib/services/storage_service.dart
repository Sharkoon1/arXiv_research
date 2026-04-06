import 'dart:convert';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/paper.dart';

class StorageService {
  Box<dynamic>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(AppConstants.hiveBoxName);
  }

  Future<List<Paper>> loadPapers() async {
    final box = _box;
    if (box == null || box.isEmpty) return [];

    return box.values
        .map((raw) {
          try {
            final json = Map<String, dynamic>.from(raw as Map);
            return Paper.fromJson(json);
          } catch (_) {
            return null;
          }
        })
        .whereType<Paper>()
        .toList();
  }

  Future<void> savePapers(List<Paper> papers) async {
    final box = _box;
    if (box == null) return;

    await box.clear();
    final entries = {
      for (int i = 0; i < papers.length; i++)
        i.toString(): papers[i].toJson(),
    };
    await box.putAll(entries);
  }

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

  Future<DateTime?> loadLastFetchTime() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(AppConstants.prefsKeyLastFetch);
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  Future<void> saveLastFetchTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefsKeyLastFetch, time.toIso8601String());
  }
}
