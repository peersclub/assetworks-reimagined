import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../core/theme/ios18_theme.dart';

class iOSFloatingButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? heroTag;
  final String? tooltip;
  final bool mini;
  
  const iOSFloatingButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 56,
    this.heroTag,
    this.tooltip,
    this.mini = false,
  });
  
  @override
  State<iOSFloatingButton> createState() => _iOSFloatingButtonState();
}

class _iOSFloatingButtonState extends State<iOSFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
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
      end: 0.95,
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
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }
  
  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed();
  }
  
  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = widget.mini ? widget.size * 0.75 : widget.size;
    final iconSize = widget.mini ? 20.0 : 24.0;
    
    Widget button = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.backgroundColor ?? iOS18Theme.systemBlue,
                boxShadow: [
                  BoxShadow(
                    color: (widget.backgroundColor ?? iOS18Theme.systemBlue)
                        .withOpacity(0.3),
                    blurRadius: _isPressed ? 8 : 12,
                    offset: Offset(0, _isPressed ? 2 : 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: CupertinoColors.white.withOpacity(0.1),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor ?? CupertinoColors.white,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    
    if (widget.heroTag != null) {
      button = Hero(
        tag: widget.heroTag!,
        child: button,
      );
    }
    
    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }
    
    return button;
  }
}

// Extended FAB with label
class iOSExtendedFloatingButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool extended;
  
  const iOSExtendedFloatingButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.extended = true,
  });
  
  @override
  State<iOSExtendedFloatingButton> createState() => _iOSExtendedFloatingButtonState();
}

class _iOSExtendedFloatingButtonState extends State<iOSExtendedFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _widthAnimation = Tween<double>(
      begin: widget.extended ? 1.0 : 0.0,
      end: widget.extended ? 1.0 : 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: widget.extended ? 1.0 : 0.0,
      end: widget.extended ? 1.0 : 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.extended) {
      _controller.forward();
    }
  }
  
  @override
  void didUpdateWidget(iOSExtendedFloatingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.extended != widget.extended) {
      if (widget.extended) {
        _widthAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
        _opacityAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
        _controller.forward(from: 0);
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
    final backgroundColor = widget.backgroundColor ?? iOS18Theme.systemBlue;
    final foregroundColor = widget.foregroundColor ?? CupertinoColors.white;
    
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              color: foregroundColor,
              size: 24,
            ),
            AnimatedBuilder(
              animation: _widthAnimation,
              builder: (context, child) {
                return SizedBox(
                  width: _widthAnimation.value * 8,
                );
              },
            ),
            AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _opacityAnimation,
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Speed dial FAB
class iOSSpeedDial extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final List<SpeedDialChild> children;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final ValueChanged<bool>? onOpen;
  
  const iOSSpeedDial({
    super.key,
    required this.icon,
    this.activeIcon,
    required this.children,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.onOpen,
  });
  
  @override
  State<iOSSpeedDial> createState() => _iOSSpeedDialState();
}

class _iOSSpeedDialState extends State<iOSSpeedDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  bool _isOpen = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: math.pi / 4,
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
  
  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onOpen?.call(_isOpen);
  }
  
  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? iOS18Theme.systemBlue;
    final foregroundColor = widget.foregroundColor ?? CupertinoColors.white;
    
    return SizedBox(
      width: 56,
      height: 56 + (widget.children.length * 56.0),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Child buttons
          ...widget.children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;
            
            return AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, childWidget) {
                return Positioned(
                  bottom: 0,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      -_expandAnimation.value * (index + 1) * 56,
                    ),
                    child: ScaleTransition(
                      scale: _expandAnimation,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (child.label != null)
                            FadeTransition(
                              opacity: _expandAnimation,
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: iOS18Theme.secondarySystemGroupedBackground
                                      .resolveFrom(context),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: CupertinoColors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  child.label!,
                                  style: TextStyle(
                                    color: iOS18Theme.label.resolveFrom(context),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              child.onPressed();
                              _toggle();
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: child.backgroundColor ?? backgroundColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: (child.backgroundColor ?? backgroundColor)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                child.icon,
                                color: child.foregroundColor ?? foregroundColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          
          // Main FAB
          GestureDetector(
            onTap: _toggle,
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: backgroundColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Transform.rotate(
                    angle: widget.activeIcon != null ? 0 : _rotationAnimation.value,
                    child: Icon(
                      _isOpen && widget.activeIcon != null
                          ? widget.activeIcon
                          : widget.icon,
                      color: foregroundColor,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SpeedDialChild {
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  
  SpeedDialChild({
    required this.icon,
    this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });
}