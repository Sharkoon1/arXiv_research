import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class FetchControls extends ConsumerWidget {
  const FetchControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final papersState = ref.watch(papersProvider);
    final count = ref.watch(fetchCountProvider);
    final isLoading = papersState.isLoading;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Count label + value
          Row(
            children: [
              Text(
                'Papers to fetch',
                style: TextStyle(
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context),
            child: Slider(
              value: count.toDouble(),
              min: AppConstants.minFetchCount.toDouble(),
              max: AppConstants.maxFetchCount.toDouble(),
              divisions: (AppConstants.maxFetchCount - AppConstants.minFetchCount) ~/ 5,
              onChanged: isLoading
                  ? null
                  : (val) {
                      ref.read(fetchCountProvider.notifier).state =
                          (val ~/ 5 * 5).clamp(
                            AppConstants.minFetchCount,
                            AppConstants.maxFetchCount,
                          );
                    },
            ),
          ),

          // Range labels
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
          const SizedBox(height: 16),

          // Fetch button
          SizedBox(
            width: double.infinity,
            child: _FetchButton(
              count: count,
              isLoading: isLoading,
              onTap: () => ref.read(papersProvider.notifier).fetchPapers(count),
            ),
          ),

          // Error message
          if (papersState.hasError && papersState.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      papersState.errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
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

class _FetchButton extends StatelessWidget {
  final int count;
  final bool isLoading;
  final VoidCallback onTap;

  const _FetchButton({
    required this.count,
    required this.isLoading,
    required this.onTap,
  });

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
                    color: AppColors.primary.withOpacity(0.35),
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Fetch $count Papers',
                      style: const TextStyle(
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
