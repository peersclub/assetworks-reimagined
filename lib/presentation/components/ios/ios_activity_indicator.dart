import 'package:flutter/cupertino.dart';
import 'dart:math' as math;
import '../../../core/theme/ios18_theme.dart';

class iOSActivityIndicator extends StatelessWidget {
  final double radius;
  final bool animating;
  final Color? color;
  
  const iOSActivityIndicator({
    super.key,
    this.radius = 10.0,
    this.animating = true,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return CupertinoActivityIndicator(
      radius: radius,
      animating: animating,
      color: color,
    );
  }
}

// Large activity indicator with label
class iOSLoadingIndicator extends StatelessWidget {
  final String? label;
  final double size;
  final bool animating;
  
  const iOSLoadingIndicator({
    super.key,
    this.label,
    this.size = 20.0,
    this.animating = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CupertinoActivityIndicator(
          radius: size,
          animating: animating,
        ),
        if (label != null) ...[
          const SizedBox(height: 16),
          Text(
            label!,
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 15,
            ),
          ),
        ],
      ],
    );
  }
}

// Full screen loading overlay
class iOSLoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final bool blur;
  
  const iOSLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.blur = true,
  });
  
  @override
  State<iOSLoadingOverlay> createState() => _iOSLoadingOverlayState();
}

class _iOSLoadingOverlayState extends State<iOSLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    if (widget.isLoading) {
      _controller.forward();
    }
  }
  
  @override
  void didUpdateWidget(iOSLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: CupertinoColors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: iOS18Theme.primaryBackground.resolveFrom(context),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CupertinoActivityIndicator(radius: 15),
                      if (widget.message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          widget.message!,
                          style: TextStyle(
                            color: iOS18Theme.label.resolveFrom(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Progress indicator with percentage
class iOSProgressIndicator extends StatefulWidget {
  final double progress;
  final String? label;
  final bool showPercentage;
  final Color? color;
  
  const iOSProgressIndicator({
    super.key,
    required this.progress,
    this.label,
    this.showPercentage = true,
    this.color,
  });
  
  @override
  State<iOSProgressIndicator> createState() => _iOSProgressIndicatorState();
}

class _iOSProgressIndicatorState extends State<iOSProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(iOSProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? iOS18Theme.systemBlue;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: TextStyle(
                color: iOS18Theme.label.resolveFrom(context),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CustomPaint(
                    painter: _CircularProgressPainter(
                      progress: _animation.value,
                      color: color,
                      backgroundColor: iOS18Theme.separator.resolveFrom(context),
                    ),
                  ),
                ),
                if (widget.showPercentage)
                  Text(
                    '${(_animation.value * 100).toInt()}%',
                    style: TextStyle(
                      color: iOS18Theme.label.resolveFrom(context),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  
  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 4.0;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }
  
  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Skeleton loader for content
class iOSSkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  
  const iOSSkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });
  
  @override
  State<iOSSkeletonLoader> createState() => _iOSSkeletonLoaderState();
}

class _iOSSkeletonLoaderState extends State<iOSSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.7,
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
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: iOS18Theme.tertiarySystemFill.resolveFrom(context)
                .withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

// Dots loading indicator
class iOSDotsIndicator extends StatefulWidget {
  final int dotCount;
  final double dotSize;
  final Color? color;
  
  const iOSDotsIndicator({
    super.key,
    this.dotCount = 3,
    this.dotSize = 8,
    this.color,
  });
  
  @override
  State<iOSDotsIndicator> createState() => _iOSDotsIndicatorState();
}

class _iOSDotsIndicatorState extends State<iOSDotsIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  
  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.dotCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();
    
    _startAnimation();
  }
  
  void _startAnimation() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      _controllers[i].repeat(reverse: true);
    }
  }
  
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? iOS18Theme.systemBlue;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.dotSize / 4),
              child: Transform.scale(
                scale: 0.5 + (_animations[index].value * 0.5),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.3 + (_animations[index].value * 0.7)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}