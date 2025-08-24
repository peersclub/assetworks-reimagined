import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../core/theme/ios18_theme.dart';

class iOSToast {
  static OverlayEntry? _currentToast;
  
  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.top,
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _currentToast?.remove();
    
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        position: position,
        onTap: onTap,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: () {
          _currentToast?.remove();
          _currentToast = null;
        },
      ),
    );
    
    _currentToast = entry;
    overlay.insert(entry);
    
    Future.delayed(duration, () {
      if (_currentToast == entry) {
        entry.remove();
        _currentToast = null;
      }
    });
  }
  
  static void dismiss() {
    _currentToast?.remove();
    _currentToast = null;
  }
}

enum ToastType { success, error, warning, info }
enum ToastPosition { top, bottom, center }

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final ToastPosition position;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;
  
  const _ToastWidget({
    required this.message,
    required this.type,
    required this.position,
    this.onTap,
    this.actionLabel,
    this.onAction,
    required this.onDismiss,
  });
  
  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: widget.position == ToastPosition.top
          ? const Offset(0, -1)
          : widget.position == ToastPosition.bottom
              ? const Offset(0, 1)
              : const Offset(0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _controller.forward();
    HapticFeedback.lightImpact();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return CupertinoIcons.checkmark_circle_fill;
      case ToastType.error:
        return CupertinoIcons.xmark_circle_fill;
      case ToastType.warning:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case ToastType.info:
        return CupertinoIcons.info_circle_fill;
    }
  }
  
  Color _getColor() {
    switch (widget.type) {
      case ToastType.success:
        return iOS18Theme.systemGreen;
      case ToastType.error:
        return iOS18Theme.systemRed;
      case ToastType.warning:
        return iOS18Theme.systemOrange;
      case ToastType.info:
        return iOS18Theme.systemBlue;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;
    
    return Positioned(
      top: widget.position == ToastPosition.top ? safeArea.top + 20 : null,
      bottom: widget.position == ToastPosition.bottom ? safeArea.bottom + 20 : null,
      left: 20,
      right: 20,
      child: widget.position == ToastPosition.center
          ? Center(child: _buildToast(context))
          : _buildToast(context),
    );
  }
  
  Widget _buildToast(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          onHorizontalDragEnd: (details) {
            if (details.velocity.pixelsPerSecond.dx.abs() > 100) {
              _controller.reverse().then((_) {
                widget.onDismiss();
              });
            }
          },
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: iOS18Theme.primaryBackground.resolveFrom(context)
                        .withOpacity(0.95),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: iOS18Theme.separator.resolveFrom(context).withOpacity(0.3),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIcon(),
                        color: _getColor(),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: iOS18Theme.label.resolveFrom(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (widget.actionLabel != null) ...[
                        const SizedBox(width: 12),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          minSize: 28,
                          color: _getColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            widget.onAction?.call();
                            widget.onDismiss();
                          },
                          child: Text(
                            widget.actionLabel!,
                            style: TextStyle(
                              color: _getColor(),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Snackbar style notification
class iOSSnackbar extends StatefulWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final SnackbarStyle style;
  
  const iOSSnackbar({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(seconds: 4),
    this.style = SnackbarStyle.floating,
  });
  
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    SnackbarStyle style = SnackbarStyle.floating,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => iOSSnackbar(
        message: message,
        actionLabel: actionLabel,
        onAction: () {
          onAction?.call();
          entry.remove();
        },
        duration: duration,
        style: style,
      ),
    );
    
    overlay.insert(entry);
    
    Future.delayed(duration, () {
      entry.remove();
    });
  }
  
  @override
  State<iOSSnackbar> createState() => _iOSSnackbarState();
}

enum SnackbarStyle { floating, fixed, minimal }

class _iOSSnackbarState extends State<iOSSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
    
    Future.delayed(widget.duration - const Duration(milliseconds: 350), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;
    
    return Positioned(
      bottom: widget.style == SnackbarStyle.fixed ? 0 : safeArea.bottom + 20,
      left: widget.style == SnackbarStyle.floating ? 20 : 0,
      right: widget.style == SnackbarStyle.floating ? 20 : 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildSnackbar(context),
        ),
      ),
    );
  }
  
  Widget _buildSnackbar(BuildContext context) {
    if (widget.style == SnackbarStyle.minimal) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: iOS18Theme.label.resolveFrom(context),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            widget.message,
            style: TextStyle(
              color: iOS18Theme.primaryBackground.resolveFrom(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          widget.style == SnackbarStyle.floating ? 12 : 0,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: widget.actionLabel != null ? 8 : 16,
              top: 14,
              bottom: 14 + (widget.style == SnackbarStyle.fixed ? MediaQuery.of(context).padding.bottom : 0),
            ),
            decoration: BoxDecoration(
              color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context)
                  .withOpacity(0.98),
              borderRadius: BorderRadius.circular(
                widget.style == SnackbarStyle.floating ? 12 : 0,
              ),
              border: widget.style == SnackbarStyle.floating
                  ? Border.all(
                      color: iOS18Theme.separator.resolveFrom(context).withOpacity(0.3),
                      width: 0.5,
                    )
                  : null,
              boxShadow: widget.style == SnackbarStyle.floating
                  ? [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: iOS18Theme.label.resolveFrom(context),
                      fontSize: 15,
                    ),
                  ),
                ),
                if (widget.actionLabel != null) ...[
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minSize: 36,
                    onPressed: widget.onAction,
                    child: Text(
                      widget.actionLabel!,
                      style: TextStyle(
                        color: iOS18Theme.systemBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Banner notification
class iOSBanner {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    IconData? icon,
    Color? color,
    Duration duration = const Duration(seconds: 5),
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => _BannerWidget(
        title: title,
        message: message,
        icon: icon,
        color: color,
        onTap: () {
          onTap?.call();
          entry.remove();
        },
        onDismiss: () => entry.remove(),
      ),
    );
    
    overlay.insert(entry);
    
    Future.delayed(duration, () {
      entry.remove();
    });
  }
}

class _BannerWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;
  
  const _BannerWidget({
    required this.title,
    required this.message,
    this.icon,
    this.color,
    this.onTap,
    required this.onDismiss,
  });
  
  @override
  State<_BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<_BannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    
    _controller.forward();
    HapticFeedback.notificationOccurred(HapticNotificationFeedback.success);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;
    
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: widget.onTap,
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy < -100) {
                _controller.reverse().then((_) {
                  widget.onDismiss();
                });
              }
            },
            child: Container(
              padding: EdgeInsets.only(
                top: safeArea.top + 12,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              decoration: BoxDecoration(
                color: widget.color ?? iOS18Theme.systemBlue,
                boxShadow: [
                  BoxShadow(
                    color: (widget.color ?? iOS18Theme.systemBlue).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: CupertinoColors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.message,
                          style: TextStyle(
                            color: CupertinoColors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}