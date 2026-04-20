import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../core/utils/api_exception.dart';
import '../models/report.dart';

class ReportsService {
  final String baseUrl;
  final http.Client _client;

  ReportsService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? AppConstants.backendBaseUrl,
        _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-Api-Key': AppConstants.apiKey,
      };

  Future<List<ReportSummary>> fetchAll() async {
    final resp = await _client.get(
      Uri.parse('$baseUrl/reports'),
      headers: _headers,
    );
    if (resp.statusCode != 200) {
      throw ApiException('Failed to fetch reports: HTTP ${resp.statusCode}');
    }
    final list = jsonDecode(resp.body) as List;
    return list
        .map((e) => ReportSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ReportDetail> fetchById(String id) async {
    final resp = await _client.get(
      Uri.parse('$baseUrl/reports/$id'),
      headers: _headers,
    );
    if (resp.statusCode != 200) {
      throw ApiException('Failed to fetch report: HTTP ${resp.statusCode}');
    }
    return ReportDetail.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<CollectResult> startCollection({
    required int papersLimit,
    required int newsLimit,
    List<String> paperCategories = const [],
    List<String> newsCategories = const [],
  }) async {
    final resp = await _client
        .post(
          Uri.parse('$baseUrl/collect'),
          headers: _headers,
          body: jsonEncode({
            'papers_limit': papersLimit.clamp(1, 50),
            'news_limit': newsLimit.clamp(1, 50),
            if (paperCategories.isNotEmpty) 'paper_categories': paperCategories,
            if (newsCategories.isNotEmpty) 'news_categories': newsCategories,
          }),
        )
        .timeout(const Duration(seconds: 180));
    if (resp.statusCode != 200) {
      throw ApiException('Failed to collect: HTTP ${resp.statusCode}');
    }
    return CollectResult.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  void dispose() => _client.close();
}
