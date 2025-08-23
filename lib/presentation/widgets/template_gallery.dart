import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/widget_template.dart';
import '../../data/templates/investment_templates.dart';

class TemplateGallery extends StatefulWidget {
  final Function(WidgetTemplate) onTemplateSelected;
  
  const TemplateGallery({
    Key? key,
    required this.onTemplateSelected,
  }) : super(key: key);
  
  @override
  State<TemplateGallery> createState() => _TemplateGalleryState();
}

class _TemplateGalleryState extends State<TemplateGallery> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  
  List<String> get _categories => [
    'All',
    ...InvestmentTemplates.categories,
  ];
  
  List<WidgetTemplate> get _filteredTemplates {
    var templates = InvestmentTemplates.allTemplates;
    
    // Filter by category
    if (_selectedCategory != 'All') {
      templates = templates.where((t) => t.category == _selectedCategory).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      templates = templates.where((t) => 
        t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return templates;
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search templates...',
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              filled: true,
              fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        
        // Category Filters
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (category != 'All') ...[
                        Icon(
                          _getCategoryIcon(category),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        ),
                      ),
                      if (category != 'All') ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? Colors.white.withOpacity(0.2)
                              : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _getCategoryCount(category).toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? AppColors.neutral800 : AppColors.neutral100,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  side: BorderSide(
                    color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.neutral700 : AppColors.neutral300),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Templates Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filteredTemplates.length} Templates',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              if (_selectedCategory != 'All')
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'All';
                    });
                  },
                  child: const Text('Clear Filter'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Templates Grid
        Expanded(
          child: _filteredTemplates.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.searchX,
                      size: 48,
                      color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No templates found',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _filteredTemplates.length,
                itemBuilder: (context, index) {
                  final template = _filteredTemplates[index];
                  return _TemplateCard(
                    template: template,
                    onTap: () => widget.onTemplateSelected(template),
                  );
                },
              ),
        ),
      ],
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Stocks':
        return LucideIcons.trendingUp;
      case 'Bonds':
        return LucideIcons.fileText;
      case 'Crypto':
        return LucideIcons.bitcoin;
      case 'Commodities':
        return LucideIcons.package;
      case 'Portfolio':
        return LucideIcons.pieChart;
      case 'Market Analysis':
        return LucideIcons.barChart3;
      default:
        return LucideIcons.layoutGrid;
    }
  }
  
  int _getCategoryCount(String category) {
    if (category == 'All') {
      return InvestmentTemplates.allTemplates.length;
    }
    return InvestmentTemplates.getTemplatesByCategory(category).length;
  }
}

class _TemplateCard extends StatelessWidget {
  final WidgetTemplate template;
  final VoidCallback onTap;
  
  const _TemplateCard({
    required this.template,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getCategoryColor(template.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(template.category),
                  size: 12,
                  color: _getCategoryColor(template.category),
                ),
                const SizedBox(width: 4),
                Text(
                  template.category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getCategoryColor(template.category),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Title
          Text(
            template.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // Description
          Expanded(
            child: Text(
              template.description,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (template.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.crown,
                        size: 10,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'FREE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              Icon(
                LucideIcons.arrowRight,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Stocks':
        return LucideIcons.trendingUp;
      case 'Bonds':
        return LucideIcons.fileText;
      case 'Crypto':
        return LucideIcons.bitcoin;
      case 'Commodities':
        return LucideIcons.package;
      case 'Portfolio':
        return LucideIcons.pieChart;
      case 'Market Analysis':
        return LucideIcons.barChart3;
      default:
        return LucideIcons.layoutGrid;
    }
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Stocks':
        return AppColors.success;
      case 'Bonds':
        return AppColors.info;
      case 'Crypto':
        return AppColors.warning;
      case 'Commodities':
        return AppColors.error;
      case 'Portfolio':
        return AppColors.primary;
      case 'Market Analysis':
        return const Color(0xFF9333EA);
      default:
        return AppColors.neutral500;
    }
  }
}