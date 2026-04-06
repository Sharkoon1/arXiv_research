import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../core/utils/xml_parser.dart';
import '../models/paper.dart';

class ArxivService {
  final http.Client _client;

  ArxivService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Paper>> fetchPapers(int count) async {
    final clampedCount = count.clamp(
      AppConstants.minFetchCount,
      AppConstants.maxFetchCount,
    );

    final uri = Uri.parse(AppConstants.arxivBaseUrl).replace(
      queryParameters: {
        'search_query': AppConstants.searchQuery,
        'start': '0',
        'max_results': clampedCount.toString(),
        'sortBy': 'submittedDate',
        'sortOrder': 'descending',
      },
    );

    final response = await _client.get(
      uri,
      headers: {'User-Agent': 'ArxivResearch/1.0 (personal app)'},
    );

    if (response.statusCode != 200) {
      throw ArxivException(
        'Failed to fetch papers: HTTP ${response.statusCode}',
      );
    }

    final papers = XmlParser.parse(response.body);

    if (papers.isEmpty) {
      throw const ArxivException('No papers returned. ArXiv may be rate-limiting. Try again in a moment.');
    }

    return papers;
  }

  void dispose() => _client.close();
}

class ArxivException implements Exception {
  final String message;
  const ArxivException(this.message);

  @override
  String toString() => message;
}
