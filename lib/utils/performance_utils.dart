import 'dart:async';
import 'package:flutter/material.dart';

/// 🚀 PERFORMANCE UTILITIES
/// Senior Developer Best Practices for Flutter Performance

class PerformanceUtils {
  // Prevent instantiation
  PerformanceUtils._();

  /// Debounce function calls (e.g., search queries)
  /// Usage: final debouncer = Debouncer(milliseconds: 500);
  ///        debouncer.run(() => search(query));
  static Debouncer createDebouncer({int milliseconds = 500}) {
    return Debouncer(milliseconds: milliseconds);
  }

  /// Throttle function calls (e.g., scroll events)
  /// Usage: final throttler = Throttler(milliseconds: 300);
  ///        throttler.run(() => loadMore());
  static Throttler createThrottler({int milliseconds = 300}) {
    return Throttler(milliseconds: milliseconds);
  }
}

/// Debouncer - delays function execution until user stops typing
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Throttler - limits function execution frequency
class Throttler {
  final int milliseconds;
  Timer? _timer;
  bool _canExecute = true;

  Throttler({required this.milliseconds});

  void run(VoidCallback action) {
    if (_canExecute) {
      _canExecute = false;
      action();
      _timer = Timer(Duration(milliseconds: milliseconds), () {
        _canExecute = true;
      });
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Lazy loading helper for lists
/// Automatically loads more when user scrolls to bottom
class LazyLoadController {
  final ScrollController scrollController;
  final VoidCallback onLoadMore;
  final double threshold;
  bool _isLoading = false;

  LazyLoadController({
    required this.scrollController,
    required this.onLoadMore,
    this.threshold = 200.0,
  }) {
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_isLoading) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    if (maxScroll - currentScroll <= threshold) {
      _isLoading = true;
      onLoadMore();
      // Reset after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _isLoading = false;
      });
    }
  }

  void dispose() {
    scrollController.removeListener(_scrollListener);
  }
}

/// Image cache helper
class ImageCacheHelper {
  // Set max cache size (default is 100MB)
  static void configureImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 1000; // Number of images
    PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20; // 200MB
  }

  // Precache important images
  static Future<void> precacheImages(BuildContext context, List<String> assets) async {
    for (final asset in assets) {
      await precacheImage(AssetImage(asset), context);
    }
  }
}

/// Memoization helper for expensive computations
class Memoizer<T> {
  final Map<String, T> _cache = {};

  T call(String key, T Function() computation) {
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    final result = computation();
    _cache[key] = result;
    return result;
  }

  void clear() {
    _cache.clear();
  }

  void remove(String key) {
    _cache.remove(key);
  }
}
