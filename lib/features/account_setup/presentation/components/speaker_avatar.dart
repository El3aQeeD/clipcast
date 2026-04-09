import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';

class SpeakerAvatar extends StatelessWidget {
  const SpeakerAvatar({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
    this.photoUrl,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onTap;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SemanticColors.backgroundSecondary,
                    border: Border.all(
                      color: isSelected
                          ? SemanticColors.interactivePrimary
                          : SemanticColors.borderDefault,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: ClipOval(
                    child: _buildImage(),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: -4,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: SemanticColors.interactivePrimary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SemanticColors.backgroundPrimary,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: SemanticColors.textOnPrimary,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: 98,
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleSmall.copyWith(
                color: isSelected
                    ? SemanticColors.textPrimary
                    : SemanticColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      final image = CachedNetworkImage(
        imageUrl: photoUrl!,
        fit: BoxFit.cover,
        width: 88,
        height: 88,
        placeholder: (_, _) => _placeholder(),
        errorWidget: (_, _, _) => _placeholder(),
      );

      if (isSelected) {
        return Stack(
          children: [
            image,
            Container(
              color: SemanticColors.interactivePrimary.withValues(alpha: 0.2),
            ),
          ],
        );
      }

      return Opacity(opacity: 0.8, child: image);
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: SemanticColors.backgroundSurface,
      child: Center(
        child: name.isNotEmpty
            ? Text(
                name[0].toUpperCase(),
                style: AppTypography.headlineLarge.copyWith(
                  color: SemanticColors.textSecondary,
                ),
              )
            : const Icon(
                Icons.person,
                color: SemanticColors.textSecondary,
                size: 36,
              ),
      ),
    );
  }
}
