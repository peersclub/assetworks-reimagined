import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// Basic flip card
class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Duration duration;
  final Curve curve;
  final bool flipOnTap;
  
  const FlipCard({
    Key? key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOut,
    this.flipOnTap = true,
  }) : super(key: key);
  
  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.flipOnTap ? _flip : null,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isShowingFront = _animation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(math.pi * _animation.value),
            child: isShowingFront
                ? widget.front
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}

// 3D flip card with depth
class Flip3DCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final double width;
  final double height;
  final Duration duration;
  
  const Flip3DCard({
    Key? key,
    required this.front,
    required this.back,
    required this.width,
    required this.height,
    this.duration = const Duration(milliseconds: 800),
  }) : super(key: key);
  
  @override
  State<Flip3DCard> createState() => _Flip3DCardState();
}

class _Flip3DCardState extends State<Flip3DCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isFront = true;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.95),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.95, end: 1.0),
        weight: 0.5,
      ),
    ]).animate(_controller);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isShowingFront = _rotationAnimation.value < math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..scale(_scaleAnimation.value)
              ..rotateY(_rotationAnimation.value),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2 * _scaleAnimation.value),
                    blurRadius: 20,
                    offset: Offset(0, 10 * (1 - _scaleAnimation.value)),
                  ),
                ],
              ),
              child: isShowingFront
                  ? widget.front
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: widget.back,
                    ),
            ),
          );
        },
      ),
    );
  }
}

// Horizontal flip card
class HorizontalFlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Duration duration;
  final double perspective;
  
  const HorizontalFlipCard({
    Key? key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 700),
    this.perspective = 0.003,
  }) : super(key: key);
  
  @override
  State<HorizontalFlipCard> createState() => _HorizontalFlipCardState();
}

class _HorizontalFlipCardState extends State<HorizontalFlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx.abs() > 100) {
          _flip();
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isShowingFront = _animation.value < 0.5;
          final rotation = _animation.value * math.pi;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, widget.perspective)
              ..rotateY(rotation),
            child: isShowingFront
                ? widget.front
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}

// Vertical flip card
class VerticalFlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Duration duration;
  
  const VerticalFlipCard({
    Key? key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 700),
  }) : super(key: key);
  
  @override
  State<VerticalFlipCard> createState() => _VerticalFlipCardState();
}

class _VerticalFlipCardState extends State<VerticalFlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dy.abs() > 100) {
          _flip();
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isShowingFront = _animation.value < 0.5;
          final rotation = _animation.value * math.pi;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(rotation),
            child: isShowingFront
                ? widget.front
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateX(math.pi),
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}

// Multi-axis flip card
class MultiAxisFlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Duration duration;
  
  const MultiAxisFlipCard({
    Key? key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);
  
  @override
  State<MultiAxisFlipCard> createState() => _MultiAxisFlipCardState();
}

class _MultiAxisFlipCardState extends State<MultiAxisFlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _xRotation;
  late Animation<double> _yRotation;
  late Animation<double> _zRotation;
  bool _isFront = true;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _xRotation = Tween<double>(
      begin: 0,
      end: math.pi * 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
    
    _yRotation = Tween<double>(
      begin: 0,
      end: math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
    ));
    
    _zRotation = Tween<double>(
      begin: 0,
      end: math.pi * 0.25,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isShowingFront = _yRotation.value < math.pi / 2;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_xRotation.value)
              ..rotateY(_yRotation.value)
              ..rotateZ(_zRotation.value),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: isShowingFront
                  ? widget.front
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: widget.back,
                    ),
            ),
          );
        },
      ),
    );
  }
}