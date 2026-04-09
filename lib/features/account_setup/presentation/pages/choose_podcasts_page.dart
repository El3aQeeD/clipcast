import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/cc_button.dart';
import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import '../components/category_podcasts_sheet.dart';
import '../components/more_in_category_card.dart';
import '../components/podcast_grid_card.dart';
import '../components/setup_search_field.dart';
import '../controller/account_setup_controller.dart';
import '../controller/account_setup_state.dart';

class ChoosePodcastsPage extends StatefulWidget {
  const ChoosePodcastsPage({super.key});

  @override
  State<ChoosePodcastsPage> createState() => _ChoosePodcastsPageState();
}

class _ChoosePodcastsPageState extends State<ChoosePodcastsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final cubit = context.read<AccountSetupController>();
    if (cubit.state.groupedPodcasts.isEmpty) {
      cubit.loadPodcasts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AccountSetupController>().loadMorePodcasts();
    }
  }

  void _showCategorySheet(String categoryName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AccountSetupController>(),
        child: CategoryPodcastsSheet(categoryName: categoryName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountSetupController, AccountSetupState>(
      builder: (context, state) {
        final isLoading = state.status == AccountSetupStatus.loadingPodcasts;
        final isSubmitting = state.status == AccountSetupStatus.submitting;
        final categoryKeys = state.podcastCategoryKeys;

        return BlocListener<AccountSetupController, AccountSetupState>(
          listenWhen: (prev, curr) =>
              curr.status == AccountSetupStatus.setupComplete,
          listener: (context, state) {
            context.go('/account-setup/great-picks');
          },
          child: Column(
            children: [
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: SemanticColors.interactivePrimary,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        itemCount: categoryKeys.length + 2,
                        itemBuilder: (context, index) {
                          if (index == 0) return _buildHeader(state);

                          if (index <= categoryKeys.length) {
                            final category = categoryKeys[index - 1];
                            final podcasts =
                                state.groupedPodcasts[category] ?? [];
                            return _buildCategoryRow(
                              state: state,
                              category: category,
                              podcasts: podcasts,
                            );
                          }

                          if (state.isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.all(AppSpacing.base),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: SemanticColors.interactivePrimary,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
              ),
              _buildBottomBar(state, isSubmitting),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AccountSetupState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Now choose some\npodcasts.',
          style: AppTypography.displayMedium.copyWith(
            color: SemanticColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        SetupSearchField(
          hintText: 'Search podcasts',
          onChanged: (q) =>
              context.read<AccountSetupController>().updateSearch(q),
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _buildCategoryRow({
    required AccountSetupState state,
    required String category,
    required List podcasts,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < 2; i++) ...[
            Expanded(
              child: i < podcasts.length
                  ? PodcastGridCard(
                      title: podcasts[i].title,
                      imageUrl: podcasts[i].imageUrl,
                      isSelected:
                          state.selectedPodcastIds.contains(podcasts[i].id),
                      onTap: () => context
                          .read<AccountSetupController>()
                          .togglePodcast(podcasts[i].id),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: MoreInCategoryCard(
              categoryName: category,
              onTap: () => _showCategorySheet(category),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(AccountSetupState state, bool isSubmitting) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.base,
      ),
      child: Column(
        children: [
          CcButton(
            label: 'Add Favorite Podcasts',
            isLoading: isSubmitting,
            onPressed: state.selectedPodcastIds.isEmpty
                ? null
                : () =>
                    context.read<AccountSetupController>().submitChoices(),
            variant: state.selectedPodcastIds.isEmpty
                ? CcButtonVariant.disabled
                : CcButtonVariant.primary,
          ),
          const SizedBox(height: AppSpacing.xl),
          GestureDetector(
            onTap: isSubmitting
                ? null
                : () =>
                    context.read<AccountSetupController>().submitChoices(),
            child: Text(
              'Skip For Now',
              style: AppTypography.labelLarge.copyWith(
                color: SemanticColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
