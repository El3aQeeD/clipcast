import '../../domain/entities/category_entity.dart';
import '../../domain/entities/setup_podcast_entity.dart';
import '../../domain/entities/speaker_entity.dart';

enum AccountSetupStatus {
  initial,
  loadingCategories,
  categoriesLoaded,
  loadingSpeakers,
  speakersLoaded,
  loadingPodcasts,
  podcastsLoaded,
  submitting,
  setupComplete,
  error,
}

class AccountSetupState {
  final AccountSetupStatus status;
  final int currentStep;

  final List<CategoryEntity> categories;
  final Set<String> selectedCategoryIds;
  final int categoriesOffset;
  final bool hasMoreCategories;

  final List<SpeakerEntity> speakers;
  final Set<String> selectedSpeakerIds;
  final int speakersOffset;
  final bool hasMoreSpeakers;

  final Map<String, List<SetupPodcastEntity>> groupedPodcasts;
  final Set<String> selectedPodcastIds;
  final int podcastsOffset;
  final bool hasMorePodcasts;

  final String? expandedCategory;
  final List<SetupPodcastEntity> expandedCategoryPodcasts;
  final int expandedCategoryOffset;
  final bool hasMoreExpandedPodcasts;
  final bool isLoadingExpandedCategory;

  final bool isLoadingMore;
  final String? errorMessage;
  final String searchQuery;
  final bool showAllCategories;
  final List<String> curatedPodcastImageUrls;

  const AccountSetupState({
    this.status = AccountSetupStatus.initial,
    this.currentStep = 1,
    this.categories = const [],
    this.selectedCategoryIds = const {},
    this.categoriesOffset = 0,
    this.hasMoreCategories = true,
    this.speakers = const [],
    this.selectedSpeakerIds = const {},
    this.speakersOffset = 0,
    this.hasMoreSpeakers = true,
    this.groupedPodcasts = const {},
    this.selectedPodcastIds = const {},
    this.podcastsOffset = 0,
    this.hasMorePodcasts = true,
    this.expandedCategory,
    this.expandedCategoryPodcasts = const [],
    this.expandedCategoryOffset = 0,
    this.hasMoreExpandedPodcasts = true,
    this.isLoadingExpandedCategory = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.searchQuery = '',
    this.showAllCategories = false,
    this.curatedPodcastImageUrls = const [],
  });

  AccountSetupState copyWith({
    AccountSetupStatus? status,
    int? currentStep,
    List<CategoryEntity>? categories,
    Set<String>? selectedCategoryIds,
    int? categoriesOffset,
    bool? hasMoreCategories,
    List<SpeakerEntity>? speakers,
    Set<String>? selectedSpeakerIds,
    int? speakersOffset,
    bool? hasMoreSpeakers,
    Map<String, List<SetupPodcastEntity>>? groupedPodcasts,
    Set<String>? selectedPodcastIds,
    int? podcastsOffset,
    bool? hasMorePodcasts,
    String? expandedCategory,
    List<SetupPodcastEntity>? expandedCategoryPodcasts,
    int? expandedCategoryOffset,
    bool? hasMoreExpandedPodcasts,
    bool? isLoadingExpandedCategory,
    bool? isLoadingMore,
    String? errorMessage,
    String? searchQuery,
    bool? showAllCategories,
    List<String>? curatedPodcastImageUrls,
  }) {
    return AccountSetupState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      categories: categories ?? this.categories,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      categoriesOffset: categoriesOffset ?? this.categoriesOffset,
      hasMoreCategories: hasMoreCategories ?? this.hasMoreCategories,
      speakers: speakers ?? this.speakers,
      selectedSpeakerIds: selectedSpeakerIds ?? this.selectedSpeakerIds,
      speakersOffset: speakersOffset ?? this.speakersOffset,
      hasMoreSpeakers: hasMoreSpeakers ?? this.hasMoreSpeakers,
      groupedPodcasts: groupedPodcasts ?? this.groupedPodcasts,
      selectedPodcastIds: selectedPodcastIds ?? this.selectedPodcastIds,
      podcastsOffset: podcastsOffset ?? this.podcastsOffset,
      hasMorePodcasts: hasMorePodcasts ?? this.hasMorePodcasts,
      expandedCategory: expandedCategory ?? this.expandedCategory,
      expandedCategoryPodcasts:
          expandedCategoryPodcasts ?? this.expandedCategoryPodcasts,
      expandedCategoryOffset:
          expandedCategoryOffset ?? this.expandedCategoryOffset,
      hasMoreExpandedPodcasts:
          hasMoreExpandedPodcasts ?? this.hasMoreExpandedPodcasts,
      isLoadingExpandedCategory:
          isLoadingExpandedCategory ?? this.isLoadingExpandedCategory,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      showAllCategories: showAllCategories ?? this.showAllCategories,
      curatedPodcastImageUrls:
          curatedPodcastImageUrls ?? this.curatedPodcastImageUrls,
    );
  }

  List<CategoryEntity> get topLevelCategories =>
      categories.where((c) => c.parentId == null).toList();

  List<CategoryEntity> get displayedCategories {
    if (showAllCategories) return categories;
    final topLevel = topLevelCategories;
    return topLevel.isEmpty ? categories : topLevel;
  }

  List<SpeakerEntity> get filteredSpeakers {
    if (searchQuery.isEmpty) return speakers;
    final query = searchQuery.toLowerCase();
    return speakers
        .where((s) => s.name.toLowerCase().contains(query))
        .toList();
  }

  /// Category names from groupedPodcasts keys, preserving order.
  List<String> get podcastCategoryKeys => groupedPodcasts.keys.toList();

  List<String> get selectedCategoryNames {
    final idSet = selectedCategoryIds;
    return categories
        .where((c) => idSet.contains(c.id))
        .map((c) => c.name)
        .toList();
  }

  /// Maps selected categories to top-level names that match podcasts.categories.
  /// If a subcategory is selected, resolves it to its parent's name.
  /// Falls back to all top-level names when nothing is selected.
  List<String> get selectedTopLevelCategoryNames {
    if (selectedCategoryIds.isEmpty) {
      return topLevelCategories.map((c) => c.name).toList();
    }
    final topLevel = topLevelCategories;
    final topLevelMap = {for (final c in topLevel) c.id: c.name};
    final names = <String>{};
    for (final id in selectedCategoryIds) {
      if (topLevelMap.containsKey(id)) {
        names.add(topLevelMap[id]!);
      } else {
        // Subcategory — find its parent
        final sub = categories.firstWhere(
          (c) => c.id == id,
          orElse: () => categories.first,
        );
        if (sub.parentId != null && topLevelMap.containsKey(sub.parentId)) {
          names.add(topLevelMap[sub.parentId]!);
        }
      }
    }
    return names.isEmpty
        ? topLevel.map((c) => c.name).toList()
        : names.toList();
  }
}
