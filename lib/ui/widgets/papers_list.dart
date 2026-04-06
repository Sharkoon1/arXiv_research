import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/paper.dart';
import 'paper_card.dart';

class PapersList extends StatelessWidget {
  final List<Paper> papers;
  final ScrollController? scrollController;

  const PapersList({
    super.key,
    required this.papers,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 4, bottom: 32),
      itemCount: papers.length,
      itemBuilder: (context, index) {
        return PaperCard(paper: papers[index])
            .animate(delay: Duration(milliseconds: 40 * index.clamp(0, 20)))
            .slideY(
              begin: 0.15,
              end: 0,
              curve: Curves.easeOutCubic,
              duration: 280.ms,
            )
            .fadeIn(duration: 250.ms);
      },
    );
  }
}
