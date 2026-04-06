import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

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
}
