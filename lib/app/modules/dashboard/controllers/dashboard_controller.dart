import 'package:get/get.dart';
import '../../../data/models/widget_model.dart';
import '../../../data/models/analysis_model.dart';
import '../../../data/repositories/widget_repository.dart';
import '../../../data/repositories/analysis_repository.dart';

class DashboardController extends GetxController {
  // Repositories
  final WidgetRepository _widgetRepository = WidgetRepository();
  final AnalysisRepository _analysisRepository = AnalysisRepository();
  
  // Observables
  final RxInt currentTabIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Data Lists
  final RxList<WidgetModel> myAnalysisList = <WidgetModel>[].obs;
  final RxList<WidgetModel> savedAnalysisList = <WidgetModel>[].obs;
  final RxList<AnalysisModel> popularAnalysisList = <AnalysisModel>[].obs;
  
  // Statistics
  final RxInt totalWidgets = 0.obs;
  final RxInt totalViews = 0.obs;
  final RxInt totalLikes = 0.obs;
  final RxInt totalShares = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  @override
  void onReady() {
    super.onReady();
    // Load data when view is ready
    refreshData();
  }

  /// Switch between tabs
  void switchTab(int index) {
    currentTabIndex.value = index;
    if (index == 0) {
      loadMyAnalysis();
    } else {
      loadSavedAnalysis();
    }
  }

  /// Load all dashboard data
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      await Future.wait([
        loadMyAnalysis(),
        loadSavedAnalysis(),
        loadPopularAnalysis(),
        loadStatistics(),
      ]);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load dashboard data: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Load user's created analysis
  Future<void> loadMyAnalysis() async {
    try {
      final widgets = await _widgetRepository.getMyWidgets();
      myAnalysisList.value = widgets;
    } catch (e) {
      _handleError('Failed to load your analysis', e);
    }
  }

  /// Load saved analysis
  Future<void> loadSavedAnalysis() async {
    try {
      final widgets = await _widgetRepository.getSavedWidgets();
      savedAnalysisList.value = widgets;
    } catch (e) {
      _handleError('Failed to load saved analysis', e);
    }
  }

  /// Load popular analysis
  Future<void> loadPopularAnalysis() async {
    try {
      final analysis = await _analysisRepository.getPopularAnalysis();
      popularAnalysisList.value = analysis;
    } catch (e) {
      _handleError('Failed to load popular analysis', e);
    }
  }

  /// Load user statistics
  Future<void> loadStatistics() async {
    try {
      final stats = await _widgetRepository.getUserStatistics();
      totalWidgets.value = stats['totalWidgets'] ?? 0;
      totalViews.value = stats['totalViews'] ?? 0;
      totalLikes.value = stats['totalLikes'] ?? 0;
      totalShares.value = stats['totalShares'] ?? 0;
    } catch (e) {
      _handleError('Failed to load statistics', e);
    }
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  /// Handle widget actions
  Future<void> likeWidget(String widgetId) async {
    try {
      await _widgetRepository.likeWidget(widgetId);
      // Update local state
      _updateWidgetLikeStatus(widgetId, true);
    } catch (e) {
      Get.snackbar('Error', 'Failed to like widget');
    }
  }

  Future<void> saveWidget(String widgetId) async {
    try {
      await _widgetRepository.saveWidget(widgetId);
      // Reload saved widgets
      await loadSavedAnalysis();
      Get.snackbar('Success', 'Widget saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save widget');
    }
  }

  Future<void> shareWidget(String widgetId) async {
    try {
      await _widgetRepository.shareWidget(widgetId);
      Get.snackbar('Success', 'Widget shared successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to share widget');
    }
  }

  /// Delete widget
  Future<void> deleteWidget(String widgetId) async {
    try {
      await _widgetRepository.deleteWidget(widgetId);
      myAnalysisList.removeWhere((widget) => widget.id == widgetId);
      Get.snackbar('Success', 'Widget deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete widget');
    }
  }

  /// Private helper methods
  void _handleError(String message, dynamic error) {
    debugPrint('$message: $error');
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: CupertinoColors.systemRed.withOpacity(0.9),
      colorText: CupertinoColors.white,
    );
  }

  void _updateWidgetLikeStatus(String widgetId, bool isLiked) {
    // Update in my analysis list
    final myIndex = myAnalysisList.indexWhere((w) => w.id == widgetId);
    if (myIndex != -1) {
      myAnalysisList[myIndex] = myAnalysisList[myIndex].copyWith(
        isLiked: isLiked,
        likes: isLiked 
            ? myAnalysisList[myIndex].likes + 1 
            : myAnalysisList[myIndex].likes - 1,
      );
    }
    
    // Update in saved analysis list
    final savedIndex = savedAnalysisList.indexWhere((w) => w.id == widgetId);
    if (savedIndex != -1) {
      savedAnalysisList[savedIndex] = savedAnalysisList[savedIndex].copyWith(
        isLiked: isLiked,
        likes: isLiked 
            ? savedAnalysisList[savedIndex].likes + 1 
            : savedAnalysisList[savedIndex].likes - 1,
      );
    }
  }

  void debugPrint(String message) {
    print('[DashboardController] $message');
  }
}