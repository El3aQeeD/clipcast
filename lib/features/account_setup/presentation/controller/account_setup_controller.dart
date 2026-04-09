import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/setup_podcast_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_podcasts_by_category_usecase.dart';
import '../../domain/usecases/get_podcasts_for_setup_usecase.dart';
import '../../domain/usecases/get_speakers_usecase.dart';
import '../../domain/usecases/save_onboarding_choices_usecase.dart';
import 'account_setup_state.dart';

const _pageSize = 20;

class AccountSetupController extends Cubit<AccountSetupState> {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetSpeakersUseCase _getSpeakersUseCase;
  final GetPodcastsForSetupUseCase _getPodcastsForSetupUseCase;
  final GetPodcastsByCategoryUseCase _getPodcastsByCategoryUseCase;
  final SaveOnboardingChoicesUseCase _saveOnboardingChoicesUseCase;

  AccountSetupController({
    required GetCategoriesUseCase getCategoriesUseCase,
    required GetSpeakersUseCase getSpeakersUseCase,
    required GetPodcastsForSetupUseCase getPodcastsForSetupUseCase,
    required GetPodcastsByCategoryUseCase getPodcastsByCategoryUseCase,
    required SaveOnboardingChoicesUseCase saveOnboardingChoicesUseCase,
  })  : _getCategoriesUseCase = getCategoriesUseCase,
        _getSpeakersUseCase = getSpeakersUseCase,
        _getPodcastsForSetupUseCase = getPodcastsForSetupUseCase,
        _getPodcastsByCategoryUseCase = getPodcastsByCategoryUseCase,
        _saveOnboardingChoicesUseCase = saveOnboardingChoicesUseCase,
        super(const AccountSetupState());

  // ── Categories ──────────────────────────────────────────────

  Future<void> loadCategories() async {
    emit(state.copyWith(
      status: AccountSetupStatus.loadingCategories,
      categoriesOffset: 0,
      hasMoreCategories: true,
    ));
    try {
      final categories = await _getCategoriesUseCase(
        offset: 0,
        limit: 200,
      );
      emit(state.copyWith(
        status: AccountSetupStatus.categoriesLoaded,
        categories: categories,
        categoriesOffset: categories.length,
        hasMoreCategories: false,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: AccountSetupStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountSetupStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMoreCategories() async {
    if (!state.hasMoreCategories || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final more = await _getCategoriesUseCase(
        offset: state.categoriesOffset,
        limit: _pageSize,
      );
      emit(state.copyWith(
        categories: [...state.categories, ...more],
        categoriesOffset: state.categoriesOffset + more.length,
        hasMoreCategories: more.length >= _pageSize,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  void toggleCategory(String categoryId) {
    final selected = Set<String>.from(state.selectedCategoryIds);
    if (selected.contains(categoryId)) {
      selected.remove(categoryId);
    } else {
      selected.add(categoryId);
    }
    emit(state.copyWith(
      selectedCategoryIds: selected,
      groupedPodcasts: const {},
      podcastsOffset: 0,
      hasMorePodcasts: true,
    ));
  }

  void toggleShowAllCategories() {
    emit(state.copyWith(showAllCategories: !state.showAllCategories));
  }

  // ── Speakers ────────────────────────────────────────────────

  Future<void> loadSpeakers() async {
    emit(state.copyWith(
      status: AccountSetupStatus.loadingSpeakers,
      currentStep: 2,
      searchQuery: '',
      speakersOffset: 0,
      hasMoreSpeakers: true,
    ));
    try {
      final speakers = await _getSpeakersUseCase(
        offset: 0,
        limit: _pageSize,
      );
      emit(state.copyWith(
        status: AccountSetupStatus.speakersLoaded,
        speakers: speakers,
        speakersOffset: speakers.length,
        hasMoreSpeakers: speakers.length >= _pageSize,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: AccountSetupStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountSetupStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMoreSpeakers() async {
    if (!state.hasMoreSpeakers || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final more = await _getSpeakersUseCase(
        offset: state.speakersOffset,
        limit: _pageSize,
      );
      emit(state.copyWith(
        speakers: [...state.speakers, ...more],
        speakersOffset: state.speakersOffset + more.length,
        hasMoreSpeakers: more.length >= _pageSize,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  void toggleSpeaker(String speakerId) {
    final selected = Set<String>.from(state.selectedSpeakerIds);
    if (selected.contains(speakerId)) {
      selected.remove(speakerId);
    } else {
      selected.add(speakerId);
    }
    emit(state.copyWith(selectedSpeakerIds: selected));
  }

  // ── Podcasts (grouped by category) ─────────────────────────

  Future<void> loadPodcasts() async {
    emit(state.copyWith(
      status: AccountSetupStatus.loadingPodcasts,
      currentStep: 3,
      searchQuery: '',
      podcastsOffset: 0,
      hasMorePodcasts: true,
      groupedPodcasts: const {},
    ));
    try {
      final categoryNames = state.selectedTopLevelCategoryNames;
      final results = await _getPodcastsForSetupUseCase(
        categoryNames,
        offset: 0,
        limit: _pageSize,
      );
      final grouped = _groupByCategory(results);
      emit(state.copyWith(
        status: AccountSetupStatus.podcastsLoaded,
        groupedPodcasts: grouped,
        podcastsOffset: results.length,
        hasMorePodcasts: results.length >= _pageSize,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: AccountSetupStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountSetupStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMorePodcasts() async {
    if (!state.hasMorePodcasts || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final categoryNames = state.selectedTopLevelCategoryNames;
      final more = await _getPodcastsForSetupUseCase(
        categoryNames,
        offset: state.podcastsOffset,
        limit: _pageSize,
      );
      final merged = Map<String, List<SetupPodcastEntity>>.from(
        state.groupedPodcasts,
      );
      for (final entry in _groupByCategory(more).entries) {
        merged[entry.key] = [...(merged[entry.key] ?? []), ...entry.value];
      }
      emit(state.copyWith(
        groupedPodcasts: merged,
        podcastsOffset: state.podcastsOffset + more.length,
        hasMorePodcasts: more.length >= _pageSize,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  void togglePodcast(String podcastId) {
    final selected = Set<String>.from(state.selectedPodcastIds);
    if (selected.contains(podcastId)) {
      selected.remove(podcastId);
    } else {
      selected.add(podcastId);
    }
    emit(state.copyWith(selectedPodcastIds: selected));
  }

  // ── Expanded category (bottom sheet) ───────────────────────

  Future<void> expandCategory(String categoryName) async {
    emit(state.copyWith(
      expandedCategory: categoryName,
      expandedCategoryPodcasts: const [],
      expandedCategoryOffset: 0,
      hasMoreExpandedPodcasts: true,
      isLoadingExpandedCategory: true,
    ));
    try {
      final results = await _getPodcastsByCategoryUseCase(
        categoryName: categoryName,
        offset: 0,
        limit: _pageSize,
      );
      emit(state.copyWith(
        expandedCategoryPodcasts: results,
        expandedCategoryOffset: results.length,
        hasMoreExpandedPodcasts: results.length >= _pageSize,
        isLoadingExpandedCategory: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingExpandedCategory: false));
    }
  }

  Future<void> loadMoreForCategory() async {
    if (!state.hasMoreExpandedPodcasts || state.isLoadingMore) return;
    final category = state.expandedCategory;
    if (category == null) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final more = await _getPodcastsByCategoryUseCase(
        categoryName: category,
        offset: state.expandedCategoryOffset,
        limit: _pageSize,
      );
      emit(state.copyWith(
        expandedCategoryPodcasts: [
          ...state.expandedCategoryPodcasts,
          ...more,
        ],
        expandedCategoryOffset: state.expandedCategoryOffset + more.length,
        hasMoreExpandedPodcasts: more.length >= _pageSize,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  // ── Search ──────────────────────────────────────────────────

  void updateSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  // ── Submit ──────────────────────────────────────────────────

  Future<void> submitChoices() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      emit(state.copyWith(
        status: AccountSetupStatus.error,
        errorMessage: 'User not authenticated',
      ));
      return;
    }

    emit(state.copyWith(status: AccountSetupStatus.submitting));
    try {
      final imageUrls = await _saveOnboardingChoicesUseCase(
        userId: userId,
        categoryIds: state.selectedCategoryIds.toList(),
        speakerIds: state.selectedSpeakerIds.toList(),
        podcastIds: state.selectedPodcastIds.toList(),
      );
      emit(state.copyWith(
        status: AccountSetupStatus.setupComplete,
        curatedPodcastImageUrls: imageUrls,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: AccountSetupStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountSetupStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(status: AccountSetupStatus.categoriesLoaded));
  }

  // ── Helpers ─────────────────────────────────────────────────

  Map<String, List<SetupPodcastEntity>> _groupByCategory(
    List<SetupPodcastEntity> podcasts,
  ) {
    final map = <String, List<SetupPodcastEntity>>{};
    for (final p in podcasts) {
      final key = p.categoryGroup ?? 'Other';
      map.putIfAbsent(key, () => []).add(p);
    }
    return map;
  }
}
