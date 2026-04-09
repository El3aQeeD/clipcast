import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/cc_button.dart';
import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import '../components/setup_search_field.dart';
import '../components/speaker_avatar.dart';
import '../controller/account_setup_controller.dart';
import '../controller/account_setup_state.dart';

class ChooseSpeakersPage extends StatefulWidget {
  const ChooseSpeakersPage({super.key});

  @override
  State<ChooseSpeakersPage> createState() => _ChooseSpeakersPageState();
}

class _ChooseSpeakersPageState extends State<ChooseSpeakersPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final cubit = context.read<AccountSetupController>();
    if (cubit.state.speakers.isEmpty) {
      cubit.loadSpeakers();
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
      context.read<AccountSetupController>().loadMoreSpeakers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountSetupController, AccountSetupState>(
      builder: (context, state) {
        final isLoading =
            state.status == AccountSetupStatus.loadingSpeakers;
        final speakers = state.filteredSpeakers;

        return Column(
          children: [
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.xxl),
                          Text(
                            'Choose 3 or more speakers you like.',
                            style: AppTypography.displayMedium.copyWith(
                              color: SemanticColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          SetupSearchField(
                            hintText: 'Search Speakers',
                            onChanged: (q) => context
                                .read<AccountSetupController>()
                                .updateSearch(q),
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                        ],
                      ),
                    ),
                  ),
                  if (isLoading && speakers.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: SemanticColors.interactivePrimary,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                      ),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final speaker = speakers[index];
                            return SpeakerAvatar(
                              name: speaker.name,
                              photoUrl: speaker.photoUrl,
                              isSelected: state.selectedSpeakerIds
                                  .contains(speaker.id),
                              onTap: () => context
                                  .read<AccountSetupController>()
                                  .toggleSpeaker(speaker.id),
                            );
                          },
                          childCount: speakers.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: AppSpacing.base,
                          mainAxisSpacing: AppSpacing.lg,
                        ),
                      ),
                    ),
                  if (state.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.base),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: SemanticColors.interactivePrimary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
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
                    label: 'Add Favorite Speakers',
                    onPressed: state.selectedSpeakerIds.length < 3
                        ? null
                        : () => context.go('/account-setup/podcasts'),
                    variant: state.selectedSpeakerIds.length < 3
                        ? CcButtonVariant.disabled
                        : CcButtonVariant.primary,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GestureDetector(
                    onTap: () => context.go('/account-setup/podcasts'),
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
