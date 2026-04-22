import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/report.dart';

class FetchControls extends ConsumerWidget {
  const FetchControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final papersState = ref.watch(papersProvider);
    final newsState = ref.watch(newsProvider);
    final papersLimit = ref.watch(papersFetchLimitProvider);
    final newsLimit = ref.watch(newsFetchLimitProvider);
    final isLoading = papersState.isLoading || newsState.isLoading;

    final papersAgentStatus = ref.watch(papersAgentStatusProvider);
    final newsAgentStatus = ref.watch(newsAgentStatusProvider);
    final summarizeAgentStatus = ref.watch(summarizeAgentStatusProvider);
    final showAgentStatus = papersAgentStatus != AgentStatus.idle ||
        newsAgentStatus != AgentStatus.idle ||
        summarizeAgentStatus != AgentStatus.idle;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LimitRow(
            label: 'Papers limit',
            count: papersLimit,
            enabled: !isLoading,
            onChanged: (v) => ref.read(papersFetchLimitProvider.notifier).state = v,
          ),
          const SizedBox(height: 8),
          _CategoryChips(
            allCategories: AppConstants.paperCategories,
            selectedProvider: selectedPaperCategoriesProvider,
            enabled: !isLoading,
          ),
          const SizedBox(height: 16),
          _LimitRow(
            label: 'News limit',
            count: newsLimit,
            enabled: !isLoading,
            onChanged: (v) => ref.read(newsFetchLimitProvider.notifier).state = v,
          ),
          const SizedBox(height: 8),
          _CategoryChips(
            allCategories: AppConstants.newsCategories,
            selectedProvider: selectedNewsCategoriesProvider,
            enabled: !isLoading,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _CreateReportButton(
              isLoading: isLoading,
              onTap: () async {
                // Reset agent statuses
                ref.read(papersAgentStatusProvider.notifier).state = AgentStatus.loading;
                ref.read(newsAgentStatusProvider.notifier).state = AgentStatus.loading;
                ref.read(summarizeAgentStatusProvider.notifier).state = AgentStatus.idle;

                ref.read(papersProvider.notifier).setLoading();
                ref.read(newsProvider.notifier).setLoading();
                WakelockPlus.enable();
                try {
                  final paperCats = ref.read(selectedPaperCategoriesProvider).toList();
                  final newsCats = ref.read(selectedNewsCategoriesProvider).toList();
                  final result = await ref
                      .read(reportsServiceProvider)
                      .startCollection(
                        papersLimit: papersLimit,
                        newsLimit: newsLimit,
                        paperCategories: paperCats,
                        newsCategories: newsCats,
                      );

                  // Papers & news done
                  ref.read(papersAgentStatusProvider.notifier).state = AgentStatus.success;
                  ref.read(newsAgentStatusProvider.notifier).state = AgentStatus.success;

                  ref.read(papersProvider.notifier).setPapers(result.papers);
                  ref.read(newsProvider.notifier).setNews(result.news);

                  // Summarize status
                  if (result.briefing != null) {
                    ref.read(summarizeAgentStatusProvider.notifier).state = AgentStatus.success;
                  } else {
                    ref.read(summarizeAgentStatusProvider.notifier).state = AgentStatus.error;
                  }

                  ref.read(briefingProvider.notifier).state = result.briefing;
                  ref.read(activeReportNameProvider.notifier).state = result.reportName;
                  await ref.read(storageServiceProvider).saveLastReport(
                        ReportDetail(
                          id: result.reportId,
                          name: result.reportName,
                          briefing: result.briefing,
                          papers: result.papers,
                          news: result.news,
                          createdAt: DateTime.now(),
                        ),
                      );
                  ref.read(reportsProvider.notifier).load();
                  if (result.errors.isNotEmpty) {
                    ref.read(papersProvider.notifier).setError(result.errors.join('\n'));
                  }
                  WakelockPlus.disable();
                } catch (e) {
                  ref.read(papersAgentStatusProvider.notifier).state = AgentStatus.error;
                  ref.read(newsAgentStatusProvider.notifier).state = AgentStatus.error;
                  ref.read(summarizeAgentStatusProvider.notifier).state = AgentStatus.error;
                  ref.read(papersProvider.notifier).setError(e.toString());
                  ref.read(newsProvider.notifier).setError(e.toString());
                  WakelockPlus.disable();
                }
              },
            ),
          ),

          // Agent status indicators
          if (showAgentStatus) ...[
            const SizedBox(height: 16),
            _AgentStatusRow(
              label: 'research-agent collecting latest ai research papers',
              status: papersAgentStatus,
            ),
            const SizedBox(height: 8),
            _AgentStatusRow(
              label: 'research-agent collecting latest ai news',
              status: newsAgentStatus,
            ),
            const SizedBox(height: 8),
            _AgentStatusRow(
              label: 'research-agent analyzing and writing summary',
              status: summarizeAgentStatus,
            ),
          ],

          if ((papersState.hasError && papersState.errorMessage != null) ||
              (newsState.hasError && newsState.errorMessage != null)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      papersState.errorMessage ?? newsState.errorMessage ?? '',
                      style: const TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AgentStatusRow extends StatelessWidget {
  final String label;
  final AgentStatus status;

  const _AgentStatusRow({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: _buildIcon(),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            status == AgentStatus.loading ? '$label...' : label,
            style: TextStyle(
              fontSize: 12,
              color: switch (status) {
                AgentStatus.loading => AppColors.primary,
                AgentStatus.success => Colors.green,
                AgentStatus.error => AppColors.error,
                AgentStatus.idle => AppColors.textMuted,
              },
              fontWeight: status == AgentStatus.loading ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return switch (status) {
      AgentStatus.loading => const _PulsingDot(),
      AgentStatus.success => const Icon(Icons.check_circle_rounded, size: 16, color: Colors.green),
      AgentStatus.error => const Icon(Icons.error_rounded, size: 16, color: AppColors.error),
      AgentStatus.idle => Icon(Icons.circle_outlined, size: 16, color: AppColors.textMuted.withValues(alpha: 0.4)),
    };
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = _controller.value;
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.4 + value * 0.6),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: value * 0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _LimitRow extends StatelessWidget {
  final String label;
  final int count;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const _LimitRow({
    required this.label,
    required this.count,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.fetchGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: count.toDouble(),
          min: AppConstants.minFetchCount.toDouble(),
          max: AppConstants.maxFetchCount.toDouble(),
          divisions: (AppConstants.maxFetchCount - AppConstants.minFetchCount) ~/ 5,
          onChanged: enabled
              ? (v) => onChanged((v ~/ 5 * 5).clamp(
                    AppConstants.minFetchCount,
                    AppConstants.maxFetchCount,
                  ))
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text('${AppConstants.minFetchCount}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const Spacer(),
              Text('${AppConstants.maxFetchCount}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  final List<String> allCategories;
  final StateProvider<Set<String>> selectedProvider;
  final bool enabled;

  const _CategoryChips({
    required this.allCategories,
    required this.selectedProvider,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected chips (removable)
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: selected.map((category) {
            return Chip(
              label: Text(
                category,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white70),
              onDeleted: enabled && selected.length > 1
                  ? () {
                      ref.read(selectedProvider.notifier).state =
                          selected.where((c) => c != category).toSet();
                    }
                  : null,
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          }).toList(),
        ),
        // Add button (dropdown)
        if (enabled && selected.length < 5) ...[
          const SizedBox(height: 6),
          PopupMenuButton<String>(
            onSelected: (category) {
              final current = ref.read(selectedProvider);
              if (current.length < 5) {
                ref.read(selectedProvider.notifier).state = {...current, category};
              }
            },
            itemBuilder: (_) => allCategories
                .where((c) => !selected.contains(c))
                .map((c) => PopupMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Add category',
                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CreateReportButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _CreateReportButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          gradient: isLoading ? null : AppColors.fetchGradient,
          color: isLoading ? AppColors.cardDark : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(AppColors.primaryLight),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Create Report',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
