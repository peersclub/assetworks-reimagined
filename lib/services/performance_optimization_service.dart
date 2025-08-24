import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'dart:ui' as ui;

class PerformanceOptimizationService {
  static final PerformanceOptimizationService _instance = 
      PerformanceOptimizationService._internal();
  factory PerformanceOptimizationService() => _instance;
  PerformanceOptimizationService._internal();

  // Performance metrics
  final Map<String, Duration> _performanceMetrics = {};
  final Map<String, int> _frameDrops = {};
  
  // FPS tracking
  int _frameCount = 0;
  DateTime _lastFPSCheck = DateTime.now();
  double _currentFPS = 60.0;

  // Initialize performance monitoring
  void initialize() {
    // Monitor frame timing
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
    
    // Start FPS tracking
    _startFPSTracking();
    
    // Enable performance overlay in debug mode
    if (kDebugMode) {
      debugPrintRebuildDirtyWidgets = false; // Reduce debug noise
    }
  }

  // Frame timing callback
  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildDuration = timing.buildDuration;
      final rasterDuration = timing.rasterDuration;
      final totalDuration = buildDuration + rasterDuration;
      
      // Check for frame drops (>16ms for 60fps)
      if (totalDuration.inMilliseconds > 16) {
        _recordFrameDrop('frame_${DateTime.now().millisecondsSinceEpoch}');
      }
    }
  }

  // Start FPS tracking
  void _startFPSTracking() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastFPSCheck);
      
      if (elapsed.inMilliseconds > 0) {
        _currentFPS = (_frameCount * 1000) / elapsed.inMilliseconds;
        _frameCount = 0;
        _lastFPSCheck = now;
      }
    });
    
    // Count frames
    SchedulerBinding.instance.addPersistentFrameCallback((_) {
      _frameCount++;
    });
  }

  // Get current FPS
  double get currentFPS => _currentFPS;

  // Check if maintaining 60fps
  bool get is60FPS => _currentFPS >= 59.0;

  // Record performance metric
  void recordMetric(String name, Duration duration) {
    _performanceMetrics[name] = duration;
  }

  // Record frame drop
  void _recordFrameDrop(String location) {
    _frameDrops[location] = (_frameDrops[location] ?? 0) + 1;
  }

  // Get performance report
  Map<String, dynamic> getPerformanceReport() {
    return {
      'current_fps': _currentFPS,
      'is_60fps': is60FPS,
      'metrics': _performanceMetrics,
      'frame_drops': _frameDrops,
    };
  }

  // Clear metrics
  void clearMetrics() {
    _performanceMetrics.clear();
    _frameDrops.clear();
  }
}

// Optimized image widget with caching
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final int? cacheWidth;
  final int? cacheHeight;
  final bool enableMemoryCache;

  const OptimizedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.cacheWidth,
    this.cacheHeight,
    this.enableMemoryCache = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate optimal cache dimensions based on device pixel ratio
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final optimalCacheWidth = cacheWidth ?? 
        (width != null ? (width! * devicePixelRatio).round() : null);
    final optimalCacheHeight = cacheHeight ?? 
        (height != null ? (height! * devicePixelRatio).round() : null);

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: optimalCacheWidth,
        cacheHeight: optimalCacheHeight,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            child: child,
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: CupertinoColors.systemGrey6,
            child: const Icon(
              CupertinoIcons.photo,
              color: CupertinoColors.systemGrey,
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: optimalCacheWidth,
        cacheHeight: optimalCacheHeight,
      );
    }
  }
}

// Lazy loading list with virtualization
class LazyLoadingList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<List<T>> Function()? onLoadMore;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  final int itemsPerBatch;
  final double itemExtent;

  const LazyLoadingList({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.scrollController,
    this.padding,
    this.itemsPerBatch = 20,
    this.itemExtent = 60.0,
  }) : super(key: key);

  @override
  State<LazyLoadingList<T>> createState() => _LazyLoadingListState<T>();
}

class _LazyLoadingListState<T> extends State<LazyLoadingList<T>> {
  late ScrollController _scrollController;
  final List<T> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _items.addAll(widget.items);
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore || widget.onLoadMore == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await widget.onLoadMore!();
      
      setState(() {
        _items.addAll(newItems);
        _hasMore = newItems.length >= widget.itemsPerBatch;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemExtent: widget.itemExtent, // Improves performance with fixed heights
      itemCount: _items.length + (_isLoading ? 1 : 0),
      cacheExtent: widget.itemExtent * 5, // Cache 5 items outside viewport
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CupertinoActivityIndicator(),
            ),
          );
        }
        
        return widget.itemBuilder(context, _items[index], index);
      },
    );
  }
}

// Memory-efficient widget that releases resources when not visible
class MemoryOptimizedWidget extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final VoidCallback? onVisible;
  final VoidCallback? onHidden;

  const MemoryOptimizedWidget({
    Key? key,
    required this.builder,
    this.onVisible,
    this.onHidden,
  }) : super(key: key);

  @override
  State<MemoryOptimizedWidget> createState() => _MemoryOptimizedWidgetState();
}

class _MemoryOptimizedWidgetState extends State<MemoryOptimizedWidget> 
    with WidgetsBindingObserver {
  bool _isVisible = true;
  Widget? _cachedWidget;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _isVisible = state == AppLifecycleState.resumed;
      
      if (_isVisible) {
        widget.onVisible?.call();
        _cachedWidget = null; // Clear cache to rebuild
      } else {
        widget.onHidden?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      // Return empty container when not visible to save memory
      return const SizedBox.shrink();
    }
    
    // Cache and reuse widget when visible
    _cachedWidget ??= widget.builder(context);
    return _cachedWidget!;
  }
}

// Debounced search/input handler
class DebouncedAction {
  final Duration delay;
  Timer? _timer;

  DebouncedAction({this.delay = const Duration(milliseconds: 500)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

// Throttled scroll handler
class ThrottledScrollHandler {
  final Duration interval;
  DateTime _lastRun = DateTime.now();
  Timer? _timer;

  ThrottledScrollHandler({this.interval = const Duration(milliseconds: 100)});

  void run(VoidCallback action) {
    final now = DateTime.now();
    final timeSinceLastRun = now.difference(_lastRun);
    
    if (timeSinceLastRun >= interval) {
      action();
      _lastRun = now;
    } else {
      _timer?.cancel();
      _timer = Timer(interval - timeSinceLastRun, () {
        action();
        _lastRun = DateTime.now();
      });
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}

// Optimized animation controller with automatic disposal
class OptimizedAnimationController extends AnimationController {
  OptimizedAnimationController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 300),
  }) : super(vsync: vsync, duration: duration);

  @override
  TickerFuture forward({double? from}) {
    // Only animate if not already at target
    if (value < 1.0) {
      return super.forward(from: from);
    }
    return TickerFuture.complete();
  }

  @override
  TickerFuture reverse({double? from}) {
    // Only animate if not already at target
    if (value > 0.0) {
      return super.reverse(from: from);
    }
    return TickerFuture.complete();
  }
}

// RepaintBoundary wrapper for expensive widgets
class OptimizedRepaintBoundary extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const OptimizedRepaintBoundary({
    Key? key,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (enabled) {
      return RepaintBoundary(
        child: child,
      );
    }
    return child;
  }
}