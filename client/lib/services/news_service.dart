import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../core/utils/api_exception.dart';
import '../models/news_item.dart';

class NewsService {
  final String baseUrl;
  final http.Client _client;

  NewsService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? AppConstants.backendBaseUrl,
        _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-Api-Key': AppConstants.apiKey,
      };

  Future<List<NewsItem>> fetchAll() async {
    final resp = await _client.get(
      Uri.parse('$baseUrl/news'),
      headers: _headers,
    );
    if (resp.statusCode != 200) {
      throw ApiException('Failed to fetch news: HTTP ${resp.statusCode}');
    }
    final list = jsonDecode(resp.body) as List;
    return list
        .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void dispose() => _client.close();
}
