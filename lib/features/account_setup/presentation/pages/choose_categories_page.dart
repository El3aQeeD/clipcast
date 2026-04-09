import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/cc_button.dart';
import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import '../components/category_chip.dart';
import '../controller/account_setup_controller.dart';
import '../controller/account_setup_state.dart';

class ChooseCategoriesPage extends StatefulWidget {
  const ChooseCategoriesPage({super.key});

  @override
  State<ChooseCategoriesPage> createState() => _ChooseCategoriesPageState();
}

class _ChooseCategoriesPageState extends State<ChooseCategoriesPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final cubit = context.read<AccountSetupController>();
    if (cubit.state.categories.isEmpty) {
      cubit.loadCategories();
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
      context.read<AccountSetupController>().loadMoreCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountSetupController, AccountSetupState>(
      builder: (context, state) {
        final isLoading =
            state.status == AccountSetupStatus.loadingCategories;
        final categories = state.displayedCategories;

        return Column(
          children: [
            Expanded(
              child: isLoading && categories.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: SemanticColors.interactivePrimary,
                      ),
                    )
                  : ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                      ),
                      children: [
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          'Pick your favorite categories to get started.',
                          style: AppTypography.displayMedium.copyWith(
                            color: SemanticColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        _CategoriesCard(
                          categories: categories,
                          selectedIds: state.selectedCategoryIds,
                          totalCount: state.categories.length,
                          showingAll: state.showAllCategories,
                          hasMore: state.hasMoreCategories,
                          onToggle: (id) => context
                              .read<AccountSetupController>()
                              .toggleCategory(id),
                          onShowAll: () => context
                              .read<AccountSetupController>()
                              .toggleShowAllCategories(),
                        ),
                        if (state.isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.all(AppSpacing.base),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: SemanticColors.interactivePrimary,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.base,
              ),
              child: Column(
                children: [
                  CcButton(
                    label: 'Add Favorite Categories',
                    onPressed: state.selectedCategoryIds.isEmpty
                        ? null
                        : () => context.go('/account-setup/speakers'),
                    variant: state.selectedCategoryIds.isEmpty
                        ? CcButtonVariant.disabled
                        : CcButtonVariant.primary,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GestureDetector(
                    onTap: () => context.go('/account-setup/speakers'),
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
            ),
          ],
        );
      },
    );
  }
}

class _CategoriesCard extends StatelessWidget {
  const _CategoriesCard({
    required this.categories,
    required this.selectedIds,
    required this.totalCount,
    required this.showingAll,
    required this.hasMore,
    required this.onToggle,
    required this.onShowAll,
  });

  final List categories;
  final Set<String> selectedIds;
  final int totalCount;
  final bool showingAll;
  final bool hasMore;
  final ValueChanged<String> onToggle;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      decoration: BoxDecoration(
        color: SemanticColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: SemanticColors.borderDefault),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.base,
            alignment: WrapAlignment.center,
            children: categories.map((cat) {
              return CategoryChip(
                label: cat.name,
                isSelected: selectedIds.contains(cat.id),
                onTap: () => onToggle(cat.id),
              );
            }).toList(),
          ),
          if (!showingAll && totalCount > categories.length) ...[
            const SizedBox(height: AppSpacing.xxl),
            GestureDetector(
              onTap: onShowAll,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See All $totalCount Categories',
                    style: AppTypography.labelLarge.copyWith(
                      color: SemanticColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: SemanticColors.textSecondary,
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
