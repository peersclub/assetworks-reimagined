import 'package:flutter/cupertino.dart';
import '../../../core/theme/ios_theme.dart';

class iOSShimmerLoader extends StatefulWidget {
  final double? height;
  final double? width;

  const iOSShimmerLoader({
    Key? key,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  State<iOSShimmerLoader> createState() => _iOSShimmerLoaderState();
}

class _iOSShimmerLoaderState extends State<iOSShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height ?? 100,
          width: widget.width ?? double.infinity,
          margin: const EdgeInsets.only(bottom: iOS18Theme.spacing12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _animation.value, 0),
              end: Alignment(1.0 + _animation.value, 0),
              colors: isDarkMode
                  ? [
                      iOS18Theme.systemGray5.darkColor,
                      iOS18Theme.systemGray4.darkColor,
                      iOS18Theme.systemGray5.darkColor,
                    ]
                  : [
                      iOS18Theme.systemGray6.color,
                      iOS18Theme.systemGray5.color,
                      iOS18Theme.systemGray6.color,
                    ],
            ),
          ),
        );
      },
    );
  }
}