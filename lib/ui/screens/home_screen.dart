import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/fetch_controls.dart';
import '../widgets/papers_list.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  bool _showHeaderShadow = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final showShadow = _scrollController.offset > 0;
      if (showShadow != _showHeaderShadow) {
        setState(() => _showHeaderShadow = showShadow);
      }
    });

    // Load cached papers on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(papersProvider.notifier).loadFromCache();
      ref.read(readStatusProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final papersState = ref.watch(papersProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar area
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                boxShadow: _showHeaderShadow
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ArXiv Research',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 26,
                          letterSpacing: -0.8,
                        ),
                      ),
                      if (papersState.lastFetched != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${papersState.papers.length} papers · updated ${_relativeTime(papersState.lastFetched!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ] else if (papersState.isEmpty) ...[
                        const SizedBox(height: 2),
                        const Text(
                          'ML & AI · cs.AI · cs.LG',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Spacer(),
                  // Theme toggle
                  GestureDetector(
                    onTap: () {
                      ref.read(themeModeProvider.notifier).state =
                          themeMode == ThemeMode.dark
                              ? ThemeMode.light
                              : ThemeMode.dark;
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

            // Fetch controls (sticky)
            const FetchControls(),

            const SizedBox(height: 4),

            // Papers count header
            if (papersState.papers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  '${papersState.papers.length} Papers',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.4,
                  ),
                ),
              ),

            // Content
            Expanded(
              child: papersState.isLoading
                  ? const _LoadingState()
                  : papersState.isEmpty
                      ? const EmptyState()
                      : PapersList(
                          papers: papersState.papers,
                          scrollController: _scrollController,
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

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
              backgroundColor: AppColors.primary.withOpacity(0.15),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Fetching from ArXiv...',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
