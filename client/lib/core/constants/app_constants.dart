import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String backendBaseUrl = kDebugMode
      ? 'http://localhost:8000'
      : 'https://arxiv-research.onrender.com';

  static const String apiKey = String.fromEnvironment('API_KEY');
  static const int defaultFetchCount = 25;
  static const int minFetchCount = 5;
  static const int maxFetchCount = 50;

  static const String prefsKeyReadIds = 'read_paper_ids';
}
