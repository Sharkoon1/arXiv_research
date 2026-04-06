import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/news_item.dart';
import '../models/paper.dart';

class CollectResult {
  final String reportId;
  final String reportName;
  final List<Paper> papers;
  final List<NewsItem> news;
  final String? briefing;
  final List<String> errors;

  const CollectResult({
    required this.reportId,
    required this.reportName,
    required this.papers,
    required this.news,
    this.briefing,
    this.errors = const [],
  });
}

class ReportSummary {
  final String id;
  final String name;
  final DateTime createdAt;
  final int paperCount;
  final int newsCount;

  const ReportSummary({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.paperCount,
    required this.newsCount,
  });
}

class ReportDetail {
  final String id;
  final String name;
  final String? briefing;
  final List<Paper> papers;
  final List<NewsItem> news;
  final DateTime createdAt;

  const ReportDetail({
    required this.id,
    required this.name,
    this.briefing,
    required this.papers,
    required this.news,
    required this.createdAt,
  });
}

class BackendService {
  final String baseUrl;
  final http.Client _client;

  BackendService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? AppConstants.backendBaseUrl,
        _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-Api-Key': AppConstants.apiKey,
  };

  Future<CollectResult> startCollection({
    required int papersLimit,
    required int newsLimit,
  }) async {
    final resp = await _client.post(
      Uri.parse('$baseUrl/collect'),
      headers: _headers,
      body: jsonEncode({
        'papers_limit': papersLimit.clamp(1, 50),
        'news_limit': newsLimit.clamp(1, 50),
      }),
    ).timeout(const Duration(seconds: 180));
    if (resp.statusCode != 200) {
      throw BackendException('Failed to collect: HTTP ${resp.statusCode}');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final papersList = (json['papers'] as List)
        .map((e) => Paper.fromJson(_toCamelPaper(e as Map<String, dynamic>)))
        .toList();
    final newsList = (json['news'] as List)
        .map((e) => NewsItem.fromJson(_toCamelNews(e as Map<String, dynamic>)))
        .toList();
    final errors = (json['errors'] as List?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    final briefing = json['briefing'] as String?;
    return CollectResult(
      reportId: json['report_id'] as String,
      reportName: json['report_name'] as String,
      papers: papersList,
      news: newsList,
      briefing: briefing,
      errors: errors,
    );
  }

  Future<List<ReportSummary>> getReports() async {
    final resp = await _client.get(Uri.parse('$baseUrl/reports'), headers: _headers);
    if (resp.statusCode != 200) {
      throw BackendException('Failed to fetch reports: HTTP ${resp.statusCode}');
    }
    final list = jsonDecode(resp.body) as List;
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return ReportSummary(
        id: m['id'] as String,
        name: m['name'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
        paperCount: m['paper_count'] as int,
        newsCount: m['news_count'] as int,
      );
    }).toList();
  }

  Future<ReportDetail> getReport(String reportId) async {
    final resp = await _client.get(Uri.parse('$baseUrl/reports/$reportId'), headers: _headers);
    if (resp.statusCode != 200) {
      throw BackendException('Failed to fetch report: HTTP ${resp.statusCode}');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    return ReportDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      briefing: json['briefing'] as String?,
      papers: (json['papers'] as List)
          .map((e) => Paper.fromJson(_toCamelPaper(e as Map<String, dynamic>)))
          .toList(),
      news: (json['news'] as List)
          .map((e) => NewsItem.fromJson(_toCamelNews(e as Map<String, dynamic>)))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Future<List<Paper>> getPapers() async {
    final resp = await _client.get(Uri.parse('$baseUrl/papers'), headers: _headers);
    if (resp.statusCode != 200) {
      throw BackendException('Failed to fetch papers: HTTP ${resp.statusCode}');
    }
    final list = jsonDecode(resp.body) as List;
    return list.map((e) => Paper.fromJson(_toCamelPaper(e as Map<String, dynamic>))).toList();
  }

  Future<List<NewsItem>> getNews() async {
    final resp = await _client.get(Uri.parse('$baseUrl/news'), headers: _headers);
    if (resp.statusCode != 200) {
      throw BackendException('Failed to fetch news: HTTP ${resp.statusCode}');
    }
    final list = jsonDecode(resp.body) as List;
    return list.map((e) => NewsItem.fromJson(_toCamelNews(e as Map<String, dynamic>))).toList();
  }

  static Map<String, dynamic> _toCamelPaper(Map<String, dynamic> e) => {
    'id': e['id'],
    'title': e['title'],
    'summary': e['summary'],
    'keyContribution': e['key_contribution'] ?? '',
    'whyItMatters': e['why_it_matters'] ?? '',
    'authors': e['authors'] ?? [],
    'source': e['source'] ?? '',
    'url': e['url'] ?? '',
    'publishedDate': e['published_date'] ?? '',
    'category': e['category'] ?? '',
    'importanceScore': e['importance_score'] ?? 0,
    'isRead': e['isRead'] ?? false,
  };

  static Map<String, dynamic> _toCamelNews(Map<String, dynamic> e) => {
    'id': e['id'],
    'title': e['title'],
    'summary': e['summary'],
    'whyItMatters': e['why_it_matters'] ?? '',
    'sourceName': e['source_name'] ?? '',
    'url': e['url'] ?? '',
    'publishedDate': e['published_date'] ?? '',
    'category': e['category'] ?? '',
    'importanceScore': e['importance_score'] ?? 0,
  };

  void dispose() => _client.close();
}

class BackendException implements Exception {
  final String message;
  const BackendException(this.message);

  @override
  String toString() => message;
}
