import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Parallax scrolling controller
class ParallaxController extends ChangeNotifier {
  double _scrollOffset = 0.0;
  double get scrollOffset => _scrollOffset;
  
  void updateScrollOffset(double offset) {
    _scrollOffset = offset;
    notifyListeners();
  }
}

// Parallax image widget
class ParallaxImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double parallaxOffset;
  final BoxFit fit;
  
  const ParallaxImage({
    Key? key,
    required this.imageUrl,
    required this.height,
    this.parallaxOffset = 0.3,
    this.fit = BoxFit.cover,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: Transform.translate(
            offset: Offset(0, parallaxOffset * 100),
            child: Container(
              height: height * 1.3,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: fit,
                  alignment: Alignment(0, -parallaxOffset),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Parallax scrolling list
class ParallaxScrollingList extends StatefulWidget {
  final List<ParallaxItem> items;
  final double itemHeight;
  final double parallaxFactor;
  
  const ParallaxScrollingList({
    Key? key,
    required this.items,
    this.itemHeight = 250,
    this.parallaxFactor = 0.5,
  }) : super(key: key);
  
  @override
  State<ParallaxScrollingList> createState() => _ParallaxScrollingListState();
}

class _ParallaxScrollingListState extends State<ParallaxScrollingList> {
  late ScrollController _scrollController;
  final Map<int, GlobalKey> _itemKeys = {};
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    for (int i = 0; i < widget.items.length; i++) {
      _itemKeys[i] = GlobalKey();
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ParallaxListItem(
                key: _itemKeys[index],
                item: widget.items[index],
                height: widget.itemHeight,
                scrollController: _scrollController,
                parallaxFactor: widget.parallaxFactor,
              );
            },
            childCount: widget.items.length,
          ),
        ),
      ],
    );
  }
}

// Parallax list item
class ParallaxListItem extends StatelessWidget {
  final ParallaxItem item;
  final double height;
  final ScrollController scrollController;
  final double parallaxFactor;
  
  const ParallaxListItem({
    Key? key,
    required this.item,
    required this.height,
    required this.scrollController,
    required this.parallaxFactor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedBuilder(
        animation: scrollController,
        builder: (context, child) {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox == null || !renderBox.hasSize) {
            return child!;
          }
          
          final offset = renderBox.localToGlobal(Offset.zero);
          final viewportHeight = MediaQuery.of(context).size.height;
          final scrollFraction = (offset.dy / viewportHeight).clamp(-1.0, 1.0);
          final parallax = scrollFraction * parallaxFactor * 100;
          
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Background image with parallax
                Positioned(
                  top: -parallax,
                  left: 0,
                  right: 0,
                  height: height * 1.3,
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        child: Container(),
      ),
    );
  }
}

// Parallax header
class ParallaxHeader extends StatelessWidget {
  final Widget child;
  final String backgroundImage;
  final double expandedHeight;
  final double parallaxFactor;
  
  const ParallaxHeader({
    Key? key,
    required this.child,
    required this.backgroundImage,
    this.expandedHeight = 300,
    this.parallaxFactor = 0.5,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      stretch: true,
      pinned: true,
      backgroundColor: CupertinoColors.systemBackground,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final percentage = (constraints.maxHeight - kToolbarHeight) /
              (expandedHeight - kToolbarHeight);
          final parallax = (1 - percentage) * parallaxFactor * 100;
          
          return FlexibleSpaceBar(
            title: AnimatedOpacity(
              opacity: percentage < 0.5 ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: child,
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Transform.translate(
                  offset: Offset(0, parallax),
                  child: Image.network(
                    backgroundImage,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.fadeTitle,
            ],
          );
        },
      ),
    );
  }
}

// Parallax stack view
class ParallaxStackView extends StatefulWidget {
  final List<ParallaxLayer> layers;
  final Widget child;
  
  const ParallaxStackView({
    Key? key,
    required this.layers,
    required this.child,
  }) : super(key: key);
  
  @override
  State<ParallaxStackView> createState() => _ParallaxStackViewState();
}

class _ParallaxStackViewState extends State<ParallaxStackView> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...widget.layers.map((layer) {
          final parallax = _scrollOffset * layer.speed;
          return Positioned(
            top: layer.top - parallax,
            left: layer.left,
            right: layer.right,
            bottom: layer.bottom != null ? layer.bottom! + parallax : null,
            child: layer.child,
          );
        }).toList(),
        SingleChildScrollView(
          controller: _scrollController,
          child: widget.child,
        ),
      ],
    );
  }
}

// Parallax card
class ParallaxCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final double parallaxOffset;
  final VoidCallback? onTap;
  
  const ParallaxCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.parallaxOffset = 0.0,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Transform.translate(
                offset: Offset(0, -parallaxOffset * 50),
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
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
    );
  }
}

// Data models
class ParallaxItem {
  final String imageUrl;
  final String title;
  final String subtitle;
  
  ParallaxItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });
}

class ParallaxLayer {
  final Widget child;
  final double speed;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  
  ParallaxLayer({
    required this.child,
    required this.speed,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });
}