import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

// Swipe to dismiss card
class SwipeToDismissCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDismissed;
  final VoidCallback? onSwipeStart;
  final VoidCallback? onSwipeUpdate;
  final double dismissThreshold;
  
  const SwipeToDismissCard({
    Key? key,
    required this.child,
    this.onDismissed,
    this.onSwipeStart,
    this.onSwipeUpdate,
    this.dismissThreshold = 0.3,
  }) : super(key: key);
  
  @override
  State<SwipeToDismissCard> createState() => _SwipeToDismissCardState();
}

class _SwipeToDismissCardState extends State<SwipeToDismissCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    widget.onSwipeStart?.call();
  }
  
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
    widget.onSwipeUpdate?.call();
  }
  
  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    final screenWidth = MediaQuery.of(context).size.width;
    final dismissDistance = screenWidth * widget.dismissThreshold;
    
    if (_dragOffset.dx.abs() > dismissDistance) {
      // Dismiss the card
      final direction = _dragOffset.dx > 0 ? 1.0 : -1.0;
      _animation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset(screenWidth * direction * 2, _dragOffset.dy),
      ).animate(_controller);
      
      _controller.forward().then((_) {
        widget.onDismissed?.call();
      });
    } else {
      // Snap back to center
      _animation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ).animate(_controller);
      
      _controller.forward().then((_) {
        setState(() {
          _dragOffset = Offset.zero;
        });
        _controller.reset();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = _isDragging ? _dragOffset : _animation.value;
          final rotation = offset.dx / MediaQuery.of(context).size.width * 0.2;
          
          return Transform(
            transform: Matrix4.identity()
              ..translate(offset.dx, offset.dy)
              ..rotateZ(rotation),
            alignment: Alignment.center,
            child: Opacity(
              opacity: 1 - (offset.dx.abs() / MediaQuery.of(context).size.width * 0.5),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

// Pinch to zoom image
class PinchToZoomImage extends StatefulWidget {
  final String imageUrl;
  final double minScale;
  final double maxScale;
  
  const PinchToZoomImage({
    Key? key,
    required this.imageUrl,
    this.minScale = 1.0,
    this.maxScale = 4.0,
  }) : super(key: key);
  
  @override
  State<PinchToZoomImage> createState() => _PinchToZoomImageState();
}

class _PinchToZoomImageState extends State<PinchToZoomImage>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  
  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }
  
  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _onInteractionEnd(ScaleEndDetails details) {
    double scale = _transformationController.value.getMaxScaleOnAxis();
    
    if (scale < widget.minScale) {
      _animateToScale(widget.minScale);
    } else if (scale > widget.maxScale) {
      _animateToScale(widget.maxScale);
    }
  }
  
  void _animateToScale(double scale) {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity()..scale(scale),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward(from: 0).then((_) {
      _transformationController.value = _animation!.value;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      onInteractionEnd: _onInteractionEnd,
      child: Image.network(
        widget.imageUrl,
        fit: BoxFit.contain,
      ),
    );
  }
}

// Drag to reorder list
class DragToReorderList extends StatefulWidget {
  final List<DragItem> items;
  final Function(int oldIndex, int newIndex) onReorder;
  
  const DragToReorderList({
    Key? key,
    required this.items,
    required this.onReorder,
  }) : super(key: key);
  
  @override
  State<DragToReorderList> createState() => _DragToReorderListState();
}

class _DragToReorderListState extends State<DragToReorderList> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: widget.items.length,
      onReorder: widget.onReorder,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Material(
              elevation: 8,
              shadowColor: CupertinoColors.systemGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return Container(
          key: ValueKey(item.id),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: CupertinoColors.systemGrey5,
                width: 1,
              ),
            ),
            child: ListTile(
              leading: Icon(
                item.icon,
                color: CupertinoColors.activeBlue,
              ),
              title: Text(item.title),
              subtitle: Text(item.subtitle),
              trailing: Icon(
                CupertinoIcons.bars,
                color: CupertinoColors.systemGrey3,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Pull to refresh with custom animation
class CustomPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final double triggerDistance;
  
  const CustomPullToRefresh({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.triggerDistance = 100,
  }) : super(key: key);
  
  @override
  State<CustomPullToRefresh> createState() => _CustomPullToRefreshState();
}

class _CustomPullToRefreshState extends State<CustomPullToRefresh>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragDistance = 0;
  bool _isRefreshing = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification) {
          if (notification.overscroll < 0 && !_isRefreshing) {
            setState(() {
              _dragDistance -= notification.overscroll;
              _dragDistance = _dragDistance.clamp(0, widget.triggerDistance * 1.5);
            });
            
            if (_dragDistance >= widget.triggerDistance) {
              _triggerRefresh();
            }
          }
        } else if (notification is ScrollEndNotification) {
          if (_dragDistance > 0 && _dragDistance < widget.triggerDistance && !_isRefreshing) {
            setState(() {
              _dragDistance = 0;
            });
          }
        }
        return false;
      },
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(0, _dragDistance),
            child: widget.child,
          ),
          if (_dragDistance > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _dragDistance,
              child: Container(
                alignment: Alignment.center,
                child: _buildRefreshIndicator(),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildRefreshIndicator() {
    final progress = (_dragDistance / widget.triggerDistance).clamp(0.0, 1.0);
    
    if (_isRefreshing) {
      return const CupertinoActivityIndicator(radius: 12);
    }
    
    return Transform.scale(
      scale: progress,
      child: Transform.rotate(
        angle: progress * 2 * 3.14159,
        child: Icon(
          CupertinoIcons.arrow_clockwise,
          color: CupertinoColors.activeBlue,
          size: 24,
        ),
      ),
    );
  }
  
  Future<void> _triggerRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    _controller.repeat();
    
    await widget.onRefresh();
    
    _controller.stop();
    
    setState(() {
      _isRefreshing = false;
      _dragDistance = 0;
    });
  }
}

// Elastic scroll physics
class ElasticScrollPhysics extends ScrollPhysics {
  final double elasticFactor;
  
  const ElasticScrollPhysics({
    ScrollPhysics? parent,
    this.elasticFactor = 0.3,
  }) : super(parent: parent);
  
  @override
  ElasticScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ElasticScrollPhysics(
      parent: buildParent(ancestor),
      elasticFactor: elasticFactor,
    );
  }
  
  @override
  SpringDescription get spring => SpringDescription(
    mass: 0.5,
    stiffness: 100,
    damping: 1,
  );
}

// Gesture controlled slider
class GestureControlledSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  
  const GestureControlledSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
  }) : super(key: key);
  
  @override
  State<GestureControlledSlider> createState() => _GestureControlledSliderState();
}

class _GestureControlledSliderState extends State<GestureControlledSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentValue = 0;
  
  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation = Tween<double>(
      begin: _currentValue,
      end: _currentValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final percentage = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
        final value = widget.min + (widget.max - widget.min) * percentage;
        
        setState(() {
          _currentValue = value;
        });
        
        widget.onChanged(value);
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: MediaQuery.of(context).size.width * 
                  ((_currentValue - widget.min) / (widget.max - widget.min)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.activeBlue,
                    CupertinoColors.systemIndigo,
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 
                  ((_currentValue - widget.min) / (widget.max - widget.min)) - 22,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data models
class DragItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  
  DragItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}