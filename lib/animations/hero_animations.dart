import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Hero animation wrapper for iOS
class iOSHeroAnimation extends StatelessWidget {
  final String tag;
  final Widget child;
  final CreateRectTween? createRectTween;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final bool transitionOnUserGestures;
  
  const iOSHeroAnimation({
    Key? key,
    required this.tag,
    required this.child,
    this.createRectTween,
    this.flightShuttleBuilder,
    this.transitionOnUserGestures = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: createRectTween ?? _defaultCreateRectTween,
      flightShuttleBuilder: flightShuttleBuilder ?? _defaultFlightShuttleBuilder,
      transitionOnUserGestures: transitionOnUserGestures,
      child: child,
    );
  }
  
  static CreateRectTween _defaultCreateRectTween = (begin, end) {
    return MaterialRectArcTween(begin: begin, end: end);
  };
  
  static Widget _defaultFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final Hero fromHero = fromHeroContext.widget as Hero;
    return FadeTransition(
      opacity: animation.drive(
        CurveTween(
          curve: Curves.easeInOut,
        ),
      ),
      child: fromHero.child,
    );
  }
}

// Stock card hero animation
class StockCardHero extends StatelessWidget {
  final String symbol;
  final String companyName;
  final double price;
  final double changePercent;
  final String? imageUrl;
  final VoidCallback? onTap;
  
  const StockCardHero({
    Key? key,
    required this.symbol,
    required this.companyName,
    required this.price,
    required this.changePercent,
    this.imageUrl,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: iOSHeroAnimation(
        tag: 'stock_$symbol',
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (imageUrl != null) ...[
                iOSHeroAnimation(
                  tag: 'stock_image_$symbol',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iOSHeroAnimation(
                      tag: 'stock_symbol_$symbol',
                      child: Text(
                        symbol,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    iOSHeroAnimation(
                      tag: 'stock_company_$symbol',
                      child: Text(
                        companyName,
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  iOSHeroAnimation(
                    tag: 'stock_price_$symbol',
                    child: Text(
                      '\$$price',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  iOSHeroAnimation(
                    tag: 'stock_change_$symbol',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: changePercent >= 0
                            ? CupertinoColors.systemGreen.withOpacity(0.1)
                            : CupertinoColors.systemRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: changePercent >= 0
                              ? CupertinoColors.systemGreen
                              : CupertinoColors.systemRed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Portfolio card hero animation
class PortfolioCardHero extends StatelessWidget {
  final String id;
  final String title;
  final double value;
  final double changeAmount;
  final double changePercent;
  final List<double> chartData;
  final VoidCallback? onTap;
  
  const PortfolioCardHero({
    Key? key,
    required this.id,
    required this.title,
    required this.value,
    required this.changeAmount,
    required this.changePercent,
    required this.chartData,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: iOSHeroAnimation(
        tag: 'portfolio_$id',
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CupertinoColors.activeBlue,
                CupertinoColors.activeBlue.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.activeBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              iOSHeroAnimation(
                tag: 'portfolio_title_$id',
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              iOSHeroAnimation(
                tag: 'portfolio_value_$id',
                child: Text(
                  '\$${value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              iOSHeroAnimation(
                tag: 'portfolio_change_$id',
                child: Row(
                  children: [
                    Icon(
                      changeAmount >= 0
                          ? CupertinoIcons.arrow_up
                          : CupertinoIcons.arrow_down,
                      size: 16,
                      color: CupertinoColors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${changeAmount.abs().toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              iOSHeroAnimation(
                tag: 'portfolio_chart_$id',
                child: SizedBox(
                  height: 60,
                  child: CustomPaint(
                    painter: SimpleChartPainter(
                      data: chartData,
                      color: CupertinoColors.white.withOpacity(0.5),
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget card hero animation
class WidgetCardHero extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  
  const WidgetCardHero({
    Key? key,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: iOSHeroAnimation(
        tag: 'widget_$id',
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CupertinoColors.systemGrey5,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              iOSHeroAnimation(
                tag: 'widget_icon_$id',
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iOSHeroAnimation(
                      tag: 'widget_title_$id',
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    iOSHeroAnimation(
                      tag: 'widget_subtitle_$id',
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey3,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Profile avatar hero animation
class ProfileAvatarHero extends StatelessWidget {
  final String userId;
  final String? imageUrl;
  final String initials;
  final double size;
  final VoidCallback? onTap;
  
  const ProfileAvatarHero({
    Key? key,
    required this.userId,
    this.imageUrl,
    required this.initials,
    this.size = 80,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: iOSHeroAnimation(
        tag: 'profile_avatar_$userId',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                CupertinoColors.activeBlue,
                CupertinoColors.systemIndigo,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.activeBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: size * 0.4,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// Custom chart painter
class SimpleChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  
  SimpleChartPainter({
    required this.data,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range > 0 
          ? (data[i] - minValue) / range 
          : 0.5;
      final y = size.height - (normalizedValue * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant SimpleChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}