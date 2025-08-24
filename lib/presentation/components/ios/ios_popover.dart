import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../core/theme/ios18_theme.dart';

class iOSPopover extends StatelessWidget {
  final Widget child;
  final Widget content;
  final PopoverDirection preferredDirection;
  final double arrowSize;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsets? contentPadding;
  final double maxWidth;
  final double maxHeight;
  
  const iOSPopover({
    super.key,
    required this.child,
    required this.content,
    this.preferredDirection = PopoverDirection.bottom,
    this.arrowSize = 10,
    this.backgroundColor,
    this.borderRadius = 12,
    this.contentPadding,
    this.maxWidth = 300,
    this.maxHeight = 400,
  });
  
  void show(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    Navigator.of(context).push(
      _PopoverRoute(
        targetOffset: offset,
        targetSize: size,
        content: content,
        preferredDirection: preferredDirection,
        arrowSize: arrowSize,
        backgroundColor: backgroundColor ?? iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: borderRadius,
        contentPadding: contentPadding ?? const EdgeInsets.all(12),
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        show(context);
      },
      child: child,
    );
  }
}

enum PopoverDirection { top, bottom, left, right, auto }

class _PopoverRoute extends PopupRoute<void> {
  final Offset targetOffset;
  final Size targetSize;
  final Widget content;
  final PopoverDirection preferredDirection;
  final double arrowSize;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsets contentPadding;
  final double maxWidth;
  final double maxHeight;
  
  _PopoverRoute({
    required this.targetOffset,
    required this.targetSize,
    required this.content,
    required this.preferredDirection,
    required this.arrowSize,
    required this.backgroundColor,
    required this.borderRadius,
    required this.contentPadding,
    required this.maxWidth,
    required this.maxHeight,
  });
  
  @override
  Color? get barrierColor => CupertinoColors.black.withOpacity(0.2);
  
  @override
  bool get barrierDismissible => true;
  
  @override
  String? get barrierLabel => null;
  
  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);
  
  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _PopoverContent(
      targetOffset: targetOffset,
      targetSize: targetSize,
      content: content,
      preferredDirection: preferredDirection,
      arrowSize: arrowSize,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      contentPadding: contentPadding,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      animation: animation,
    );
  }
}

class _PopoverContent extends StatefulWidget {
  final Offset targetOffset;
  final Size targetSize;
  final Widget content;
  final PopoverDirection preferredDirection;
  final double arrowSize;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsets contentPadding;
  final double maxWidth;
  final double maxHeight;
  final Animation<double> animation;
  
  const _PopoverContent({
    required this.targetOffset,
    required this.targetSize,
    required this.content,
    required this.preferredDirection,
    required this.arrowSize,
    required this.backgroundColor,
    required this.borderRadius,
    required this.contentPadding,
    required this.maxWidth,
    required this.maxHeight,
    required this.animation,
  });
  
  @override
  State<_PopoverContent> createState() => _PopoverContentState();
}

class _PopoverContentState extends State<_PopoverContent> {
  PopoverDirection? _actualDirection;
  Offset? _popoverOffset;
  double? _arrowOffset;
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;
    
    // Calculate position
    _calculatePosition(screenSize, safeArea);
    
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return Stack(
          children: [
            if (_popoverOffset != null)
              Positioned(
                left: _popoverOffset!.dx,
                top: _popoverOffset!.dy,
                child: FadeTransition(
                  opacity: widget.animation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.9,
                      end: 1.0,
                    ).animate(CurvedAnimation(
                      parent: widget.animation,
                      curve: Curves.easeOutBack,
                    )),
                    child: _buildPopover(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  
  void _calculatePosition(Size screenSize, EdgeInsets safeArea) {
    final availableWidth = screenSize.width - safeArea.left - safeArea.right;
    final availableHeight = screenSize.height - safeArea.top - safeArea.bottom;
    
    final popoverWidth = widget.maxWidth.clamp(0, availableWidth);
    final popoverHeight = widget.maxHeight.clamp(0, availableHeight);
    
    // Determine actual direction based on available space
    _actualDirection = widget.preferredDirection;
    
    switch (widget.preferredDirection) {
      case PopoverDirection.bottom:
        final spaceBelow = screenSize.height - widget.targetOffset.dy - widget.targetSize.height;
        if (spaceBelow < popoverHeight + widget.arrowSize) {
          _actualDirection = PopoverDirection.top;
        }
        break;
      case PopoverDirection.top:
        final spaceAbove = widget.targetOffset.dy;
        if (spaceAbove < popoverHeight + widget.arrowSize) {
          _actualDirection = PopoverDirection.bottom;
        }
        break;
      case PopoverDirection.left:
        final spaceLeft = widget.targetOffset.dx;
        if (spaceLeft < popoverWidth + widget.arrowSize) {
          _actualDirection = PopoverDirection.right;
        }
        break;
      case PopoverDirection.right:
        final spaceRight = screenSize.width - widget.targetOffset.dx - widget.targetSize.width;
        if (spaceRight < popoverWidth + widget.arrowSize) {
          _actualDirection = PopoverDirection.left;
        }
        break;
      case PopoverDirection.auto:
        // Auto-detect best direction
        final spaceBelow = screenSize.height - widget.targetOffset.dy - widget.targetSize.height;
        final spaceAbove = widget.targetOffset.dy;
        
        if (spaceBelow >= popoverHeight + widget.arrowSize) {
          _actualDirection = PopoverDirection.bottom;
        } else if (spaceAbove >= popoverHeight + widget.arrowSize) {
          _actualDirection = PopoverDirection.top;
        } else {
          _actualDirection = PopoverDirection.bottom;
        }
        break;
    }
    
    // Calculate popover position based on direction
    switch (_actualDirection!) {
      case PopoverDirection.bottom:
        _popoverOffset = Offset(
          (widget.targetOffset.dx + widget.targetSize.width / 2 - popoverWidth / 2)
              .clamp(safeArea.left + 10, screenSize.width - popoverWidth - safeArea.right - 10),
          widget.targetOffset.dy + widget.targetSize.height + widget.arrowSize,
        );
        _arrowOffset = widget.targetOffset.dx + widget.targetSize.width / 2 - _popoverOffset!.dx;
        break;
      case PopoverDirection.top:
        _popoverOffset = Offset(
          (widget.targetOffset.dx + widget.targetSize.width / 2 - popoverWidth / 2)
              .clamp(safeArea.left + 10, screenSize.width - popoverWidth - safeArea.right - 10),
          widget.targetOffset.dy - popoverHeight - widget.arrowSize,
        );
        _arrowOffset = widget.targetOffset.dx + widget.targetSize.width / 2 - _popoverOffset!.dx;
        break;
      case PopoverDirection.left:
        _popoverOffset = Offset(
          widget.targetOffset.dx - popoverWidth - widget.arrowSize,
          (widget.targetOffset.dy + widget.targetSize.height / 2 - popoverHeight / 2)
              .clamp(safeArea.top + 10, screenSize.height - popoverHeight - safeArea.bottom - 10),
        );
        _arrowOffset = widget.targetOffset.dy + widget.targetSize.height / 2 - _popoverOffset!.dy;
        break;
      case PopoverDirection.right:
        _popoverOffset = Offset(
          widget.targetOffset.dx + widget.targetSize.width + widget.arrowSize,
          (widget.targetOffset.dy + widget.targetSize.height / 2 - popoverHeight / 2)
              .clamp(safeArea.top + 10, screenSize.height - popoverHeight - safeArea.bottom - 10),
        );
        _arrowOffset = widget.targetOffset.dy + widget.targetSize.height / 2 - _popoverOffset!.dy;
        break;
      default:
        break;
    }
  }
  
  Widget _buildPopover() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
      ),
      child: CustomPaint(
        painter: _PopoverPainter(
          direction: _actualDirection!,
          arrowSize: widget.arrowSize,
          arrowOffset: _arrowOffset!,
          backgroundColor: widget.backgroundColor,
          borderRadius: widget.borderRadius,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: widget.contentPadding,
              decoration: BoxDecoration(
                color: widget.backgroundColor.withOpacity(0.95),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: iOS18Theme.separator.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: widget.content,
            ),
          ),
        ),
      ),
    );
  }
}

class _PopoverPainter extends CustomPainter {
  final PopoverDirection direction;
  final double arrowSize;
  final double arrowOffset;
  final Color backgroundColor;
  final double borderRadius;
  
  _PopoverPainter({
    required this.direction,
    required this.arrowSize,
    required this.arrowOffset,
    required this.backgroundColor,
    required this.borderRadius,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // Draw arrow based on direction
    switch (direction) {
      case PopoverDirection.bottom:
        path.moveTo(arrowOffset - arrowSize, 0);
        path.lineTo(arrowOffset, -arrowSize);
        path.lineTo(arrowOffset + arrowSize, 0);
        break;
      case PopoverDirection.top:
        path.moveTo(arrowOffset - arrowSize, size.height);
        path.lineTo(arrowOffset, size.height + arrowSize);
        path.lineTo(arrowOffset + arrowSize, size.height);
        break;
      case PopoverDirection.left:
        path.moveTo(size.width, arrowOffset - arrowSize);
        path.lineTo(size.width + arrowSize, arrowOffset);
        path.lineTo(size.width, arrowOffset + arrowSize);
        break;
      case PopoverDirection.right:
        path.moveTo(0, arrowOffset - arrowSize);
        path.lineTo(-arrowSize, arrowOffset);
        path.lineTo(0, arrowOffset + arrowSize);
        break;
      default:
        break;
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(_PopoverPainter oldDelegate) {
    return oldDelegate.direction != direction ||
        oldDelegate.arrowOffset != arrowOffset;
  }
}

// Tooltip-style popover
class iOSTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Duration? showDuration;
  final bool preferBelow;
  
  const iOSTooltip({
    super.key,
    required this.child,
    required this.message,
    this.textStyle,
    this.backgroundColor,
    this.showDuration,
    this.preferBelow = true,
  });
  
  @override
  State<iOSTooltip> createState() => _iOSTooltipState();
}

class _iOSTooltipState extends State<iOSTooltip> {
  OverlayEntry? _overlayEntry;
  
  void _showTooltip() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _TooltipOverlay(
        message: widget.message,
        targetOffset: offset,
        targetSize: size,
        textStyle: widget.textStyle,
        backgroundColor: widget.backgroundColor,
        preferBelow: widget.preferBelow,
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
    HapticFeedback.selectionFeedback();
    
    if (widget.showDuration != null) {
      Future.delayed(widget.showDuration!, _hideTooltip);
    }
  }
  
  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showTooltip,
      onLongPressEnd: (_) => _hideTooltip(),
      child: widget.child,
    );
  }
}

class _TooltipOverlay extends StatefulWidget {
  final String message;
  final Offset targetOffset;
  final Size targetSize;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final bool preferBelow;
  
  const _TooltipOverlay({
    required this.message,
    required this.targetOffset,
    required this.targetSize,
    this.textStyle,
    this.backgroundColor,
    required this.preferBelow,
  });
  
  @override
  State<_TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<_TooltipOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final tooltipPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    
    // Calculate text size
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.message,
        style: widget.textStyle ?? TextStyle(
          color: CupertinoColors.white,
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: screenSize.width - 40);
    
    final tooltipWidth = textPainter.width + tooltipPadding.horizontal;
    final tooltipHeight = textPainter.height + tooltipPadding.vertical;
    
    // Calculate position
    double left = widget.targetOffset.dx + widget.targetSize.width / 2 - tooltipWidth / 2;
    left = left.clamp(10.0, screenSize.width - tooltipWidth - 10);
    
    double top;
    bool showBelow = widget.preferBelow;
    
    if (showBelow) {
      top = widget.targetOffset.dy + widget.targetSize.height + 8;
      if (top + tooltipHeight > screenSize.height - 20) {
        showBelow = false;
        top = widget.targetOffset.dy - tooltipHeight - 8;
      }
    } else {
      top = widget.targetOffset.dy - tooltipHeight - 8;
      if (top < 20) {
        showBelow = true;
        top = widget.targetOffset.dy + widget.targetSize.height + 8;
      }
    }
    
    return Positioned(
      left: left,
      top: top,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: tooltipPadding,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? iOS18Theme.label,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.message,
              style: widget.textStyle ?? TextStyle(
                color: iOS18Theme.primaryBackground,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}