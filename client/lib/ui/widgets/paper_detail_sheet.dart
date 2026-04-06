import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/paper.dart';
import '../../core/constants/app_colors.dart';
import 'category_chip.dart';

class PaperDetailSheet extends StatelessWidget {
  final Paper paper;

  const PaperDetailSheet({super.key, required this.paper});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.textMuted : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CategoryChip(category: paper.category),
                          const SizedBox(width: 8),
                          Text(
                            paper.formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textMuted : Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              paper.source,
                              style: const TextStyle(fontSize: 10, color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        paper.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.35),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        paper.authors.join(', '),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondary : Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Summary',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        paper.summary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.6),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Key Contribution',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        paper.keyContribution,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.6),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Why It Matters',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        paper.whyItMatters,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.6),
                      ),
                      const SizedBox(height: 28),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: paper.url));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('URL copied'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.link, size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  paper.url,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.copy, size: 13, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: _SheetButton(
                          label: 'Open Paper',
                          icon: Icons.open_in_new_rounded,
                          onTap: () => _openUrl(paper.url),
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _SheetButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.fetchGradient : null,
          color: isPrimary ? null : AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(color: AppColors.textMuted.withValues(alpha: 0.25), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isPrimary ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
