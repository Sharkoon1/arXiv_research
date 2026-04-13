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
    'Multimodal',
    'Reasoning & Agents',
    'Robotics & Safety',
    'Efficiency & Architecture',
    'Computer Vision',
    'NLP',
    'Reinforcement Learning',
    'Generative Models',
    'Quantization & Pruning',
  ];

  static const List<String> defaultPaperCategories = [
    'LLM',
    'Multimodal',
    'Reasoning & Agents',
    'Robotics & Safety',
    'Efficiency & Architecture',
  ];

  static const List<String> newsCategories = [
    'Model Releases',
    'Industry & Products',
    'Policy & Regulation',
    'Hardware & Infrastructure',
    'Funding & Acquisitions',
    'Open Source',
    'Startups',
    'Big Tech',
    'Research Breakthroughs',
    'AI Ethics',
  ];

  static const List<String> defaultNewsCategories = [
    'Model Releases',
    'Industry & Products',
    'Policy & Regulation',
    'Hardware & Infrastructure',
    'Funding & Acquisitions',
  ];
}
