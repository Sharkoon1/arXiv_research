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

  static const List<String> paperCategories = [
    'LLM',
    'Machine Learning',
    'Reasoning',
    'Agents',
    'Optimization',
    'Architecture',
    'Robotics',
    'Computer Vision',
    'Safety',
    'Benchmark',
  ];

  static const List<String> defaultPaperCategories = [
    'LLM',
    'Machine Learning',
    'Reasoning',
    'Agents',
    'Optimization',
  ];

  static const List<String> newsCategories = [
    'Model Release',
    'Product',
    'Industry',
    'Funding',
    'Partnership',
    'Hardware',
    'Policy',
    'Research',
    'Safety',
    'Job Market',
  ];

  static const List<String> defaultNewsCategories = [
    'Model Release',
    'Product',
    'Industry',
    'Funding',
    'Partnership',
  ];
}
