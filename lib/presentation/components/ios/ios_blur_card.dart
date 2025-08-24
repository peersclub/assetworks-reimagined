import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../../../core/theme/ios18_theme.dart';

class iOSBlurCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? color;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  
  const iOSBlurCard({
    super.key,
    required this.child,
    this.blur = 20,
    this.color,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (color ?? iOS18Theme.primaryBackground.resolveFrom(context))
                  .withOpacity(0.7),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: iOS18Theme.separator.resolveFrom(context).withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Glass morphism card
class iOSGlassCard extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double blur;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Gradient? gradient;
  
  const iOSGlassCard({
    super.key,
    required this.child,
    this.opacity = 0.2,
    this.blur = 25,
    this.borderRadius,
    this.padding,
    this.gradient,
  });
  
  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient ?? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CupertinoColors.white.withOpacity(opacity),
                CupertinoColors.white.withOpacity(opacity * 0.5),
              ],
            ),
            borderRadius: radius,
            border: Border.all(
              color: CupertinoColors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Adaptive blur card that changes based on scroll
class iOSAdaptiveBlurCard extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  final double maxBlur;
  final double minBlur;
  final double threshold;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  
  const iOSAdaptiveBlurCard({
    super.key,
    required this.child,
    required this.scrollController,
    this.maxBlur = 30,
    this.minBlur = 10,
    this.threshold = 100,
    this.borderRadius,
    this.padding,
  });
  
  @override
  State<iOSAdaptiveBlurCard> createState() => _iOSAdaptiveBlurCardState();
}

class _iOSAdaptiveBlurCardState extends State<iOSAdaptiveBlurCard> {
  double _currentBlur = 10;
  
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateBlur);
  }
  
  @override
  void dispose() {
    widget.scrollController.removeListener(_updateBlur);
    super.dispose();
  }
  
  void _updateBlur() {
    if (widget.scrollController.hasClients) {
      final offset = widget.scrollController.offset;
      final blurValue = widget.minBlur + 
          ((widget.maxBlur - widget.minBlur) * 
           (offset / widget.threshold).clamp(0, 1));
      
      if (_currentBlur != blurValue) {
        setState(() {
          _currentBlur = blurValue;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(16);
    
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _currentBlur, sigmaY: _currentBlur),
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: iOS18Theme.primaryBackground.resolveFrom(context)
                .withOpacity(0.8),
            borderRadius: radius,
            border: Border.all(
              color: iOS18Theme.separator.resolveFrom(context).withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// Material You style card with depth
class iOSDepthCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  
  const iOSDepthCard({
    super.key,
    required this.child,
    this.elevation = 4,
    this.color,
    this.borderRadius,
    this.padding,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    final cardColor = color ?? iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.04 * elevation),
              blurRadius: elevation * 2,
              offset: Offset(0, elevation),
            ),
            BoxShadow(
              color: cardColor,
              blurRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.95),
                borderRadius: radius,
                border: Border.all(
                  color: iOS18Theme.separator.resolveFrom(context).withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// Neumorphic style card
class iOSNeumorphicCard extends StatelessWidget {
  final Widget child;
  final double depth;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final bool isPressed;
  
  const iOSNeumorphicCard({
    super.key,
    required this.child,
    this.depth = 10,
    this.color,
    this.borderRadius,
    this.padding,
    this.isPressed = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    final baseColor = color ?? iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context);
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: radius,
        boxShadow: isPressed ? [] : [
          BoxShadow(
            color: isDark 
                ? CupertinoColors.black 
                : CupertinoColors.white.withOpacity(0.8),
            offset: Offset(-depth, -depth),
            blurRadius: depth * 1.5,
          ),
          BoxShadow(
            color: isDark
                ? CupertinoColors.black.withOpacity(0.5)
                : CupertinoColors.black.withOpacity(0.15),
            offset: Offset(depth, depth),
            blurRadius: depth * 1.5,
          ),
        ],
      ),
      child: child,
    );
  }
}

// Animated gradient card
class iOSGradientCard extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Duration animationDuration;
  
  const iOSGradientCard({
    super.key,
    required this.child,
    required this.colors,
    this.borderRadius,
    this.padding,
    this.animationDuration = const Duration(seconds: 3),
  });
  
  @override
  State<iOSGradientCard> createState() => _iOSGradientCardState();
}

class _iOSGradientCardState extends State<iOSGradientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(20);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: widget.padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
              transform: GradientRotation(_animation.value * 2 * 3.14159),
            ),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(0.1),
                  borderRadius: radius,
                  border: Border.all(
                    color: CupertinoColors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Hoverable card with elevation
class iOSHoverCard extends StatefulWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  
  const iOSHoverCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.onTap,
  });
  
  @override
  State<iOSHoverCard> createState() => _iOSHoverCardState();
}

class _iOSHoverCardState extends State<iOSHoverCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: 4,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _controller.forward();
  }
  
  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
    widget.onTap?.call();
  }
  
  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(16);
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: iOS18Theme.systemBlue.withOpacity(0.1 * _elevationAnimation.value / 8),
                    blurRadius: _elevationAnimation.value * 2,
                    offset: Offset(0, _elevationAnimation.value),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: widget.padding ?? const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: iOS18Theme.secondarySystemGroupedBackground
                          .resolveFrom(context).withOpacity(0.9),
                      borderRadius: radius,
                      border: Border.all(
                        color: iOS18Theme.separator.resolveFrom(context).withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}