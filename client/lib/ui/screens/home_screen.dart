import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/fetch_controls.dart';
import '../widgets/papers_list.dart';
import '../widgets/empty_state.dart';
import '../widgets/news_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _papersScrollController = ScrollController();
  late TabController _tabController;
  bool _briefingExpanded = true;
  bool _controlsExpanded = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(readStatusProvider.notifier).load();
      ref.read(reportsProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _papersScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showReportsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Consumer(
        builder: (context, ref, __) {
          final reportsAsync = ref.watch(reportsProvider);
          return reportsAsync.when(
            loading: () => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SizedBox(
              height: 200,
              child: Center(child: Text('Failed to load reports', style: TextStyle(color: AppColors.textSecondary))),
            ),
            data: (reports) {
              if (reports.isEmpty) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: Text('No reports yet', style: TextStyle(color: AppColors.textMuted))),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: reports.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 4),
                      child: Text(
                        'Past Reports',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    );
                  }
                  final report = reports[i - 1];
                  final date = '${report.createdAt.day}.${report.createdAt.month}.${report.createdAt.year}';
                  final time = '${report.createdAt.hour.toString().padLeft(2, '0')}:${report.createdAt.minute.toString().padLeft(2, '0')}';
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _loadReport(report.id, report.name);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.backgroundDark : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$date  $time  \u00b7  ${report.paperCount} papers  \u00b7  ${report.newsCount} news',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _loadReport(String reportId, String reportName) async {
    ref.read(papersProvider.notifier).setLoading();
    ref.read(newsProvider.notifier).setLoading();
    try {
      final detail = await ref.read(reportsServiceProvider).fetchById(reportId);
      ref.read(papersProvider.notifier).setPapers(detail.papers);
      ref.read(newsProvider.notifier).setNews(detail.news);
      ref.read(briefingProvider.notifier).state = detail.briefing;
      ref.read(activeReportNameProvider.notifier).state = reportName;
    } catch (e) {
      ref.read(papersProvider.notifier).setError(e.toString());
      ref.read(newsProvider.notifier).setError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final papersState = ref.watch(papersProvider);
    final newsState = ref.watch(newsProvider);
    final briefing = ref.watch(briefingProvider);
    final activeReportName = ref.watch(activeReportNameProvider);

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // Header
            SliverToBoxAdapter(
              child: Container(
                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Research',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 26,
                            letterSpacing: -0.8,
                          ),
                        ),
                        Text(
                          activeReportName ?? '${papersState.papers.length} papers \u00b7 ${newsState.items.length} news',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showReportsSheet(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.history_rounded,
                          size: 20,
                          color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ref.read(themeModeProvider.notifier).state =
                            themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          themeMode == ThemeMode.dark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          size: 20,
                          color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Fetch controls toggle
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => setState(() => _controlsExpanded = !_controlsExpanded),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
                  child: Row(
                    children: [
                      Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Controls',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: _controlsExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedCrossFade(
                firstChild: const FetchControls(),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _controlsExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 200),
              ),
            ),

            // Briefing card
            if (briefing != null)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _briefingExpanded = !_briefingExpanded),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 16, 16, _briefingExpanded ? 0 : 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI Briefing',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              AnimatedRotation(
                                turns: _briefingExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 24,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                          child: MarkdownBody(
                            data: briefing,
                            selectable: true,
                            onTapLink: (_, href, __) {
                              if (href != null) launchUrl(Uri.parse(href));
                            },
                            styleSheet: MarkdownStyleSheet(
                              h1: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87),
                              h2: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                              p: TextStyle(fontSize: 13, height: 1.5, color: isDark ? AppColors.textSecondary : Colors.black54),
                              listBullet: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondary : Colors.black54),
                              a: const TextStyle(fontSize: 13, color: AppColors.primary, decoration: TextDecoration.none),
                              horizontalRuleDecoration: BoxDecoration(
                                border: Border(top: BorderSide(color: AppColors.primary.withValues(alpha: 0.15))),
                              ),
                            ),
                          ),
                        ),
                        secondChild: const SizedBox.shrink(),
                        crossFadeState: _briefingExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 200),
                      ),
                    ],
                  ),
                ),
              ),

            // Pinned tab bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                tabBar: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.science_outlined, size: 16),
                          const SizedBox(width: 6),
                          const Text('Papers'),
                          if (papersState.papers.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            _CountBadge(count: papersState.papers.length),
                          ],
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.newspaper_outlined, size: 16),
                          const SizedBox(width: 6),
                          const Text('News'),
                          if (newsState.items.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            _CountBadge(count: newsState.items.length),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              // Papers tab
              papersState.isLoading
                  ? const _LoadingState(label: 'Loading papers...')
                  : papersState.isEmpty
                      ? const EmptyState()
                      : PapersList(
                          papers: papersState.papers,
                          scrollController: _papersScrollController,
                        ),

              // News tab
              newsState.isLoading
                  ? const _LoadingState(label: 'Loading news...')
                  : newsState.isEmpty
                      ? const _EmptyNews()
                      : ListView.builder(
                          itemCount: newsState.items.length,
                          padding: const EdgeInsets.only(top: 4, bottom: 32),
                          itemBuilder: (_, i) => NewsCard(item: newsState.items[i]),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color color;

  _TabBarDelegate({required this.tabBar, required this.color});

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar || color != oldDelegate.color;
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: const TextStyle(fontSize: 10, color: AppColors.primaryLight, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final String label;
  const _LoadingState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _EmptyNews extends StatelessWidget {
  const _EmptyNews();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.newspaper_outlined, size: 48, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text('No news yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          SizedBox(height: 8),
          Text(
            "Tap 'Create Report' to fetch the latest AI news.",
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
