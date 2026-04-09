import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import '../controller/account_setup_controller.dart';
import '../controller/account_setup_state.dart';
import 'podcast_grid_card.dart';

class CategoryPodcastsSheet extends StatefulWidget {
  const CategoryPodcastsSheet({super.key, required this.categoryName});

  final String categoryName;

  @override
  State<CategoryPodcastsSheet> createState() => _CategoryPodcastsSheetState();
}

class _CategoryPodcastsSheetState extends State<CategoryPodcastsSheet> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<AccountSetupController>().expandCategory(widget.categoryName);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AccountSetupController>().loadMoreForCategory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: SemanticColors.backgroundPrimary,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              Expanded(
                child: BlocBuilder<AccountSetupController, AccountSetupState>(
                  builder: (context, state) {
                    if (state.isLoadingExpandedCategory &&
                        state.expandedCategoryPodcasts.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: SemanticColors.interactivePrimary,
                        ),
                      );
                    }

                    final podcasts = state.expandedCategoryPodcasts;
                    final itemCount = podcasts.length +
                        (state.hasMoreExpandedPodcasts ? 1 : 0);

                    return GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: AppSpacing.base,
                      ),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if (index >= podcasts.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.base),
                              child: CircularProgressIndicator(
                                color: SemanticColors.interactivePrimary,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }

                        final podcast = podcasts[index];
                        return PodcastGridCard(
                          title: podcast.title,
                          imageUrl: podcast.imageUrl,
                          isSelected: state.selectedPodcastIds
                              .contains(podcast.id),
                          onTap: () => context
                              .read<AccountSetupController>()
                              .togglePodcast(podcast.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: SemanticColors.borderDefault,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.base,
        AppSpacing.screenHorizontal,
        AppSpacing.base,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.categoryName,
              style: AppTypography.displaySmall.copyWith(
                color: SemanticColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.close,
              color: SemanticColors.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
