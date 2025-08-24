import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/ios18_theme.dart';
import '../../../../core/services/dynamic_island_service.dart';
import '../../../../core/services/home_widget_service.dart';

class iOSWidgetPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> widgetData;
  
  const iOSWidgetPreviewScreen({
    super.key,
    required this.widgetData,
  });

  @override
  State<iOSWidgetPreviewScreen> createState() => _iOSWidgetPreviewScreenState();
}

class _iOSWidgetPreviewScreenState extends State<iOSWidgetPreviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  
  int _selectedSizeIndex = 0;
  int _selectedStyleIndex = 0;
  bool _isDarkMode = false;
  bool _showGrid = true;
  
  final List<WidgetSize> _widgetSizes = [
    WidgetSize('Small', 2, 2, CupertinoIcons.square),
    WidgetSize('Medium', 4, 2, CupertinoIcons.rectangle),
    WidgetSize('Large', 4, 4, CupertinoIcons.square_fill),
    WidgetSize('Extra Large', 6, 4, CupertinoIcons.rectangle_fill),
  ];
  
  final List<WidgetStyle> _widgetStyles = [
    WidgetStyle('Default', 'Clean and minimal design'),
    WidgetStyle('Detailed', 'Shows more information'),
    WidgetStyle('Compact', 'Space-saving layout'),
    WidgetStyle('Premium', 'Advanced features'),
  ];
  
  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }
  
  void _selectSize(int index) {
    HapticFeedback.selectionFeedback();
    setState(() {
      _selectedSizeIndex = index;
    });
  }
  
  void _selectStyle(int index) {
    HapticFeedback.selectionFeedback();
    setState(() {
      _selectedStyleIndex = index;
    });
  }
  
  void _toggleDarkMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }
  
  void _toggleGrid() {
    HapticFeedback.lightImpact();
    setState(() {
      _showGrid = !_showGrid;
    });
  }
  
  Future<void> _addToHomeScreen() async {
    HapticFeedback.heavyImpact();
    
    final size = _widgetSizes[_selectedSizeIndex];
    final style = _widgetStyles[_selectedStyleIndex];
    
    DynamicIslandService.showProgress('Adding widget...');
    
    // Simulate adding widget
    await Future.delayed(const Duration(seconds: 2));
    
    await HomeWidgetService.updateWidget(
      'widget_${DateTime.now().millisecondsSinceEpoch}',
      {
        ...widget.widgetData,
        'size': '${size.width}x${size.height}',
        'style': style.name,
        'darkMode': _isDarkMode,
      },
    );
    
    DynamicIslandService.showSuccess('Widget added to home screen!');
    Navigator.of(context).pop(true);
  }
  
  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isDarkMode
        ? CupertinoColors.black
        : iOS18Theme.primaryBackground.resolveFrom(context);
    
    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: backgroundColor.withOpacity(0.8),
        border: null,
        middle: Text(
          'Widget Preview',
          style: TextStyle(
            color: _isDarkMode ? CupertinoColors.white : iOS18Theme.label.resolveFrom(context),
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(
            CupertinoIcons.back,
            color: _isDarkMode ? CupertinoColors.white : iOS18Theme.label.resolveFrom(context),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _toggleGrid,
              child: Icon(
                _showGrid ? CupertinoIcons.square_grid_2x2 : CupertinoIcons.square,
                color: _isDarkMode ? CupertinoColors.white : iOS18Theme.label.resolveFrom(context),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _toggleDarkMode,
              child: Icon(
                _isDarkMode ? CupertinoIcons.sun_max : CupertinoIcons.moon,
                color: _isDarkMode ? CupertinoColors.white : iOS18Theme.label.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Preview area
            Expanded(
              child: _buildPreviewArea(),
            ),
            
            // Controls
            _buildControls(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPreviewArea() {
    final size = _widgetSizes[_selectedSizeIndex];
    
    return Container(
      color: _isDarkMode ? CupertinoColors.black : iOS18Theme.systemGray6.resolveFrom(context),
      child: Stack(
        children: [
          // Grid background
          if (_showGrid)
            CustomPaint(
              size: Size.infinite,
              painter: GridPainter(
                isDarkMode: _isDarkMode,
              ),
            ),
          
          // 3D rotation effect
          Center(
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_rotationAnimation.value * 0.1),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: _buildWidget(size),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWidget(WidgetSize size) {
    final widgetWidth = size.width * 60.0;
    final widgetHeight = size.height * 60.0;
    
    return Container(
      width: widgetWidth,
      height: widgetHeight,
      decoration: BoxDecoration(
        color: _isDarkMode
            ? iOS18Theme.secondarySystemGroupedBackground.darkColor
            : iOS18Theme.secondarySystemGroupedBackground.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Content
                  _buildWidgetContent(size),
                  
                  // Shimmer effect
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-1.0 + _shimmerAnimation.value, -0.3),
                          end: Alignment(1.0 + _shimmerAnimation.value, 0.3),
                          colors: [
                            Colors.transparent,
                            CupertinoColors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildWidgetContent(WidgetSize size) {
    final style = _widgetStyles[_selectedStyleIndex];
    final data = widget.widgetData;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                CupertinoIcons.graph_square_fill,
                color: _isDarkMode ? CupertinoColors.white : iOS18Theme.systemBlue,
                size: size.width > 2 ? 24 : 20,
              ),
              if (size.width > 2) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['name'] ?? 'AssetWorks',
                    style: TextStyle(
                      color: _isDarkMode ? CupertinoColors.white : iOS18Theme.label.color,
                      fontSize: size.width > 2 ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          
          const Spacer(),
          
          // Main content based on size and style
          if (size.height >= 2) ...[
            Text(
              data['value'] ?? '\$12,345.67',
              style: TextStyle(
                color: _isDarkMode ? CupertinoColors.white : iOS18Theme.label.color,
                fontSize: size.width > 2 ? 28 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  CupertinoIcons.arrow_up_right,
                  color: iOS18Theme.systemGreen,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  data['change'] ?? '+2.5%',
                  style: TextStyle(
                    color: iOS18Theme.systemGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          
          // Additional content for larger sizes
          if (size.height > 2 && style.name != 'Compact') ...[
            const Spacer(),
            _buildMiniChart(),
          ],
          
          // Extra content for extra large size
          if (size.height >= 4 && style.name == 'Detailed') ...[
            const Spacer(),
            _buildDetailedInfo(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildMiniChart() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            iOS18Theme.systemBlue.withOpacity(0.1),
            iOS18Theme.systemBlue.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
  
  Widget _buildDetailedInfo() {
    return Column(
      children: [
        _buildInfoRow('High', '\$12,500'),
        const SizedBox(height: 4),
        _buildInfoRow('Low', '\$12,100'),
        const SizedBox(height: 4),
        _buildInfoRow('Volume', '1.2M'),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: (_isDarkMode ? CupertinoColors.white : iOS18Theme.secondaryLabel.color)
                .withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: _isDarkMode ? CupertinoColors.white : iOS18Theme.label.color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _isDarkMode
            ? iOS18Theme.secondarySystemGroupedBackground.darkColor
            : iOS18Theme.secondarySystemGroupedBackground.color,
        border: Border(
          top: BorderSide(
            color: iOS18Theme.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Size selector
          _buildSizeSelector(),
          
          const SizedBox(height: 24),
          
          // Style selector
          _buildStyleSelector(),
          
          const SizedBox(height: 24),
          
          // Add button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: CupertinoButton(
              color: iOS18Theme.systemBlue,
              borderRadius: BorderRadius.circular(28),
              onPressed: _addToHomeScreen,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.add_circled,
                    color: CupertinoColors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Add to Home Screen',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Widget Size',
          style: TextStyle(
            color: _isDarkMode ? CupertinoColors.white : iOS18Theme.label.resolveFrom(context),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _widgetSizes.length,
            itemBuilder: (context, index) {
              final size = _widgetSizes[index];
              final isSelected = _selectedSizeIndex == index;
              
              return GestureDetector(
                onTap: () => _selectSize(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? iOS18Theme.systemBlue.withOpacity(0.2)
                        : (_isDarkMode
                            ? iOS18Theme.tertiarySystemGroupedBackground.darkColor
                            : iOS18Theme.tertiarySystemGroupedBackground.color),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? iOS18Theme.systemBlue
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        size.icon,
                        color: isSelected
                            ? iOS18Theme.systemBlue
                            : (_isDarkMode
                                ? CupertinoColors.white.withOpacity(0.6)
                                : iOS18Theme.tertiaryLabel.resolveFrom(context)),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        size.name,
                        style: TextStyle(
                          color: isSelected
                              ? iOS18Theme.systemBlue
                              : (_isDarkMode
                                  ? CupertinoColors.white.withOpacity(0.6)
                                  : iOS18Theme.secondaryLabel.resolveFrom(context)),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Widget Style',
          style: TextStyle(
            color: _isDarkMode ? CupertinoColors.white : iOS18Theme.label.resolveFrom(context),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_widgetStyles.length, (index) {
          final style = _widgetStyles[index];
          final isSelected = _selectedStyleIndex == index;
          
          return GestureDetector(
            onTap: () => _selectStyle(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? iOS18Theme.systemBlue.withOpacity(0.2)
                    : (_isDarkMode
                        ? iOS18Theme.tertiarySystemGroupedBackground.darkColor
                        : iOS18Theme.tertiarySystemGroupedBackground.color),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? iOS18Theme.systemBlue
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? iOS18Theme.systemBlue
                            : (_isDarkMode
                                ? CupertinoColors.white.withOpacity(0.3)
                                : iOS18Theme.tertiaryLabel.resolveFrom(context)),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: iOS18Theme.systemBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          style.name,
                          style: TextStyle(
                            color: _isDarkMode
                                ? CupertinoColors.white
                                : iOS18Theme.label.resolveFrom(context),
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        Text(
                          style.description,
                          style: TextStyle(
                            color: _isDarkMode
                                ? CupertinoColors.white.withOpacity(0.6)
                                : iOS18Theme.secondaryLabel.resolveFrom(context),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class WidgetSize {
  final String name;
  final int width;
  final int height;
  final IconData icon;
  
  WidgetSize(this.name, this.width, this.height, this.icon);
}

class WidgetStyle {
  final String name;
  final String description;
  
  WidgetStyle(this.name, this.description);
}

class GridPainter extends CustomPainter {
  final bool isDarkMode;
  
  GridPainter({required this.isDarkMode});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDarkMode ? CupertinoColors.white : CupertinoColors.black)
          .withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    const spacing = 40.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}