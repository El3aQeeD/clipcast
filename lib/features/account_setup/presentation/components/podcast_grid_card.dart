import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';

class PodcastGridCard extends StatelessWidget {
  const PodcastGridCard({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.imageUrl,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                    border: Border.all(
                      color: isSelected
                          ? SemanticColors.interactivePrimary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.md - 1),
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: SemanticColors.backgroundSurface,
                              child: const Icon(
                                Icons.podcasts,
                                color: SemanticColors.textSecondary,
                                size: 32,
                              ),
                            ),
                            errorWidget: (_, _, _) => Container(
                              color: SemanticColors.backgroundSurface,
                              child: const Icon(
                                Icons.podcasts,
                                color: SemanticColors.textSecondary,
                                size: 32,
                              ),
                            ),
                          )
                        : Container(
                            color: SemanticColors.backgroundSurface,
                            child: const Center(
                              child: Icon(
                                Icons.podcasts,
                                color: SemanticColors.textSecondary,
                                size: 32,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: SemanticColors.interactivePrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: SemanticColors.textOnPrimary,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMedium.copyWith(
              color: SemanticColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
