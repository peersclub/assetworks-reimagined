import 'package:flutter/cupertino.dart';
import 'dart:math' as math;
import '../../../core/theme/ios18_theme.dart';

class iOSLinearProgressIndicator extends StatefulWidget {
  final double value;
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool showPercentage;
  
  const iOSLinearProgressIndicator({
    super.key,
    required this.value,
    this.height = 4,
    this.color,
    this.backgroundColor,
    this.borderRadius,
    this.showPercentage = false,
  });
  
  @override
  State<iOSLinearProgressIndicator> createState() => _iOSLinearProgressIndicatorState();
}

class _iOSLinearProgressIndicatorState extends State<iOSLinearProgressIndicator>
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
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(iOSLinearProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value,
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showPercentage)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${(_animation.value * 100).toInt()}%',
                  style: TextStyle(
                    color: iOS18Theme.label.resolveFrom(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? 
                    iOS18Theme.separator.resolveFrom(context).withOpacity(0.3),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
              ),
              child: ClipRRect(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: _animation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.color ?? iOS18Theme.systemBlue,
                          borderRadius: widget.borderRadius ?? 
                              BorderRadius.circular(widget.height / 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Circular progress indicator
class iOSCircularProgressIndicator extends StatefulWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final Widget? child;
  
  const iOSCircularProgressIndicator({
    super.key,
    required this.value,
    this.size = 60,
    this.strokeWidth = 4,
    this.color,
    this.backgroundColor,
    this.child,
  });
  
  @override
  State<iOSCircularProgressIndicator> createState() => _iOSCircularProgressIndicatorState();
}

class _iOSCircularProgressIndicatorState extends State<iOSCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(iOSCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value,
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              progress: _animation.value,
              color: widget.color ?? iOS18Theme.systemBlue,
              backgroundColor: widget.backgroundColor ?? 
                  iOS18Theme.separator.resolveFrom(context).withOpacity(0.3),
              strokeWidth: widget.strokeWidth,
            ),
            child: Center(child: widget.child),
          ),
        );
      },
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  
  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
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

// Segmented progress indicator
class iOSSegmentedProgressIndicator extends StatelessWidget {
  final int totalSegments;
  final int currentSegment;
  final double height;
  final double spacing;
  final Color? activeColor;
  final Color? inactiveColor;
  final BorderRadius? borderRadius;
  
  const iOSSegmentedProgressIndicator({
    super.key,
    required this.totalSegments,
    required this.currentSegment,
    this.height = 4,
    this.spacing = 4,
    this.activeColor,
    this.inactiveColor,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSegments, (index) {
        final isActive = index < currentSegment;
        return Expanded(
          child: Container(
            height: height,
            margin: EdgeInsets.symmetric(horizontal: index == 0 || index == totalSegments - 1 ? 0 : spacing / 2),
            decoration: BoxDecoration(
              color: isActive
                  ? (activeColor ?? iOS18Theme.systemBlue)
                  : (inactiveColor ?? iOS18Theme.separator.resolveFrom(context).withOpacity(0.3)),
              borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            ),
          ),
        );
      }),
    );
  }
}

// Download progress indicator
class iOSDownloadProgressIndicator extends StatefulWidget {
  final double progress;
  final String? label;
  final VoidCallback? onCancel;
  
  const iOSDownloadProgressIndicator({
    super.key,
    required this.progress,
    this.label,
    this.onCancel,
  });
  
  @override
  State<iOSDownloadProgressIndicator> createState() => _iOSDownloadProgressIndicatorState();
}

class _iOSDownloadProgressIndicatorState extends State<iOSDownloadProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _iconController;
  late Animation<double> _progressAnimation;
  late Animation<double> _iconRotation;
  
  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _iconController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    
    _iconRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_iconController);
    
    _progressController.forward();
  }
  
  @override
  void didUpdateWidget(iOSDownloadProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.forward(from: 0);
      
      if (widget.progress >= 1.0) {
        _iconController.stop();
      }
    }
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _iconController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_progressAnimation, _iconRotation]),
            builder: (context, child) {
              final isComplete = _progressAnimation.value >= 1.0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CustomPaint(
                      painter: _CircularProgressPainter(
                        progress: _progressAnimation.value,
                        color: isComplete ? iOS18Theme.systemGreen : iOS18Theme.systemBlue,
                        backgroundColor: iOS18Theme.separator.resolveFrom(context).withOpacity(0.3),
                        strokeWidth: 6,
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: isComplete ? 0 : _iconRotation.value,
                    child: Icon(
                      isComplete ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.arrow_down_circle,
                      color: isComplete ? iOS18Theme.systemGreen : iOS18Theme.systemBlue,
                      size: 40,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (widget.label != null)
            Text(
              widget.label!,
              style: TextStyle(
                color: iOS18Theme.label.resolveFrom(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Text(
                '${(_progressAnimation.value * 100).toInt()}%',
                style: TextStyle(
                  color: iOS18Theme.secondaryLabel.resolveFrom(context),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          if (widget.onCancel != null && widget.progress < 1.0) ...[
            const SizedBox(height: 16),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              color: iOS18Theme.systemRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              onPressed: widget.onCancel,
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: iOS18Theme.systemRed,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Step progress indicator
class iOSStepProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final List<String>? stepLabels;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;
  
  const iOSStepProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.stepLabels,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(totalSteps * 2 - 1, (index) {
            if (index.isOdd) {
              // Connector line
              final stepIndex = index ~/ 2;
              final isCompleted = stepIndex < currentStep - 1;
              return Expanded(
                child: Container(
                  height: 2,
                  color: isCompleted
                      ? (completedColor ?? iOS18Theme.systemGreen)
                      : (inactiveColor ?? iOS18Theme.separator.resolveFrom(context).withOpacity(0.3)),
                ),
              );
            } else {
              // Step circle
              final stepIndex = index ~/ 2;
              final isCompleted = stepIndex < currentStep - 1;
              final isActive = stepIndex == currentStep - 1;
              final isUpcoming = stepIndex >= currentStep;
              
              return Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? (completedColor ?? iOS18Theme.systemGreen)
                      : isActive
                          ? (activeColor ?? iOS18Theme.systemBlue)
                          : (inactiveColor ?? iOS18Theme.separator.resolveFrom(context).withOpacity(0.3)),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          color: CupertinoColors.white,
                          size: 16,
                        )
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            color: isUpcoming
                                ? iOS18Theme.label.resolveFrom(context)
                                : CupertinoColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            }
          }),
        ),
        if (stepLabels != null && stepLabels!.length == totalSteps) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: stepLabels!.asMap().entries.map((entry) {
              final index = entry.key;
              final label = entry.value;
              final isActive = index == currentStep - 1;
              
              return Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? iOS18Theme.label.resolveFrom(context)
                        : iOS18Theme.secondaryLabel.resolveFrom(context),
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}