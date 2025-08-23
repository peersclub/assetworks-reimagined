import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';

class TrendingWidgetsCarousel extends StatelessWidget {
  const TrendingWidgetsCarousel({Key? key}) : super(key: key);
  
  final List<Map<String, dynamic>> trendingWidgets = const [
    {
      'id': '1',
      'title': 'AI Sales Predictor',
      'creator': 'Alex Chen',
      'trend': '+45%',
      'icon': LucideIcons.trendingUp,
      'color': Color(0xFF4CAF50),
      'likes': 892,
    },
    {
      'id': '2',
      'title': 'Customer Churn Analysis',
      'creator': 'Maria Garcia',
      'trend': '+38%',
      'icon': LucideIcons.users,
      'color': Color(0xFF2196F3),
      'likes': 756,
    },
    {
      'id': '3',
      'title': 'Revenue Forecast Dashboard',
      'creator': 'James Wilson',
      'trend': '+32%',
      'icon': LucideIcons.dollarSign,
      'color': Color(0xFFFF9800),
      'likes': 623,
    },
    {
      'id': '4',
      'title': 'Inventory Optimizer',
      'creator': 'Sarah Lee',
      'trend': '+28%',
      'icon': LucideIcons.package,
      'color': Color(0xFF9C27B0),
      'likes': 512,
    },
    {
      'id': '5',
      'title': 'Marketing ROI Tracker',
      'creator': 'David Brown',
      'trend': '+24%',
      'icon': LucideIcons.target,
      'color': Color(0xFFE91E63),
      'likes': 445,
    },
  ];
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      height: 180,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: trendingWidgets.length,
        itemBuilder: (context, index) {
          final widget = trendingWidgets[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 160,
              child: AppCard(
                onTap: () => _openWidget(widget),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon and Trend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            widget['icon'],
                            size: 20,
                            color: widget['color'],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.trendingUp,
                                size: 12,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                widget['trend'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      widget['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Creator
                    Text(
                      widget['creator'],
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    
                    // Stats
                    Row(
                      children: [
                        Icon(
                          LucideIcons.heart,
                          size: 14,
                          color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget['likes'].toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Trending',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
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
        },
      ),
    );
  }
  
  void _openWidget(Map<String, dynamic> widget) {
    Get.toNamed('/widget-view', arguments: widget);
  }
}