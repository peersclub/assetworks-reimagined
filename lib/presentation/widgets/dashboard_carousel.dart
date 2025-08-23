import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';

class DashboardCarousel extends StatefulWidget {
  final List<DashboardCarouselItem> items;
  final Function(int)? onPageChanged;
  
  const DashboardCarousel({
    Key? key,
    required this.items,
    this.onPageChanged,
  }) : super(key: key);
  
  @override
  State<DashboardCarousel> createState() => _DashboardCarouselState();
}

class _DashboardCarouselState extends State<DashboardCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onPageChanged?.call(index);
            },
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppCard(
                  onTap: item.onTap,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: item.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              item.icon,
                              color: item.color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark 
                                        ? AppColors.textSecondaryDark 
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.value,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (item.subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (item.trend != null) ...[
                                        Icon(
                                          item.trend == DashboardTrend.up
                                              ? LucideIcons.trendingUp
                                              : item.trend == DashboardTrend.down
                                                  ? LucideIcons.trendingDown
                                                  : LucideIcons.minus,
                                          size: 16,
                                          color: item.trend == DashboardTrend.up
                                              ? AppColors.success
                                              : item.trend == DashboardTrend.down
                                                  ? AppColors.error
                                                  : AppColors.neutral500,
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        item.subtitle!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: item.trend == DashboardTrend.up
                                              ? AppColors.success
                                              : item.trend == DashboardTrend.down
                                                  ? AppColors.error
                                                  : (isDark 
                                                      ? AppColors.textSecondaryDark 
                                                      : AppColors.textSecondaryLight),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (item.actionIcon != null)
                            Icon(
                              item.actionIcon,
                              size: 20,
                              color: isDark 
                                  ? AppColors.neutral600 
                                  : AppColors.neutral400,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Page indicators
        if (widget.items.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.items.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? AppColors.primary
                        : (isDark ? AppColors.neutral700 : AppColors.neutral300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

enum DashboardTrend { up, down, neutral }

class DashboardCarouselItem {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final DashboardTrend? trend;
  final IconData? actionIcon;
  final VoidCallback? onTap;
  
  const DashboardCarouselItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.trend,
    this.actionIcon,
    this.onTap,
  });
}