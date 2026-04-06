import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/paper.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_colors.dart';
import 'status_badge.dart';
import 'category_chip.dart';
import 'paper_detail_sheet.dart';

class PaperCard extends ConsumerWidget {
  final Paper paper;

  const PaperCard({super.key, required this.paper});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readIds = ref.watch(readStatusProvider);
    final isRead = readIds.contains(paper.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        ref.read(readStatusProvider.notifier).markRead(paper.id);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => PaperDetailSheet(paper: paper),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: category + status badge
              Row(
                children: [
                  CategoryChip(category: paper.primaryCategory),
                  const Spacer(),
                  StatusBadge(isRead: isRead),
                  const SizedBox(width: 8),
                  Text(
                    paper.formattedDate,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMuted : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                paper.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isRead
                      ? (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight)
                      : (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Authors
              Text(
                paper.authorsPreview,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Abstract preview
              Text(
                paper.abstract,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  height: 1.45,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Action row
              Row(
                children: [
                  _ActionButton(
                    label: 'Abstract',
                    icon: Icons.article_outlined,
                    onTap: () => _openUrl(paper.abstractUrl),
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    label: 'PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    onTap: () => _openUrl(paper.pdfUrl),
                    isPrimary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.fetchGradient : null,
          color: isPrimary ? null : AppColors.cardDark.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
          border: isPrimary
              ? null
              : Border.all(color: AppColors.textMuted.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isPrimary ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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
