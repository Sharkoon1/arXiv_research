class AppConstants {
  AppConstants._();

  static const String arxivBaseUrl = 'https://export.arxiv.org/api/query';
  static const String searchQuery = 'cat:cs.AI OR cat:cs.LG OR cat:cs.CV OR cat:cs.CL';
  static const int defaultFetchCount = 25;
  static const int minFetchCount = 5;
  static const int maxFetchCount = 100;

  static const String hiveBoxName = 'papers';
  static const String prefsKeyReadIds = 'read_paper_ids';
  static const String prefsKeyLastFetch = 'last_fetch_time';
}
