import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../core/theme/ios_theme.dart';
import '../../../../core/services/dynamic_island_service.dart';
import '../../../controllers/create_widget_controller.dart';

class iOSCreateWidgetScreen extends StatefulWidget {
  const iOSCreateWidgetScreen({Key? key}) : super(key: key);

  @override
  State<iOSCreateWidgetScreen> createState() => _iOSCreateWidgetScreenState();
}

class _iOSCreateWidgetScreenState extends State<iOSCreateWidgetScreen>
    with TickerProviderStateMixin {
  final CreateWidgetController _controller = Get.find<CreateWidgetController>();
  final DynamicIslandService _dynamicIsland = DynamicIslandService.to;
  
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();
  
  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _progressAnimation;
  
  // Widget configuration
  String _selectedType = 'chart';
  String _selectedTimeframe = '1D';
  String _selectedStyle = 'line';
  bool _showVolume = true;
  bool _showIndicators = false;
  bool _isPublic = true;
  double _refreshInterval = 5.0; // minutes
  
  // Steps
  int _currentStep = 0;
  final List<String> _steps = [
    'Basic Info',
    'Data Source',
    'Appearance',
    'Settings',
    'Review',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: iOS18Theme.springCurve,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      iOS18Theme.lightImpact();
      setState(() => _currentStep++);
      _animationController.reset();
      _animationController.forward();
      _progressAnimationController.forward();
      
      // Update Dynamic Island
      _dynamicIsland.startWidgetCreation(
        widgetTitle: _titleController.text.isEmpty ? 'New Widget' : _titleController.text,
        widgetType: _selectedType,
      );
    } else {
      _createWidget();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      iOS18Theme.lightImpact();
      setState(() => _currentStep--);
      _animationController.reset();
      _animationController.forward();
      _progressAnimationController.reverse();
    }
  }

  Future<void> _createWidget() async {
    iOS18Theme.mediumImpact();
    
    // Show loading in Dynamic Island
    _dynamicIsland.startWidgetCreation(
      widgetTitle: _titleController.text,
      widgetType: _selectedType,
    );
    
    try {
      final success = await _controller.createWidget(
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        symbol: _symbolController.text,
        timeframe: _selectedTimeframe,
        style: _selectedStyle,
        showVolume: _showVolume,
        showIndicators: _showIndicators,
        isPublic: _isPublic,
        refreshInterval: _refreshInterval.toInt(),
      );
      
      if (success) {
        iOS18Theme.successImpact();
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorDialog('Failed to create widget');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.systemBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: iOS18Theme.systemBackground.resolveFrom(context).withOpacity(0.94),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            iOS18Theme.lightImpact();
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        middle: Text(_steps[_currentStep]),
        trailing: _currentStep == _steps.length - 1
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _createWidget,
                child: const Text(
                  'Create',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              )
            : null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            
            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: _buildStepContent(),
                ),
              ),
            ),
            
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing16),
      child: Row(
        children: List.generate(_steps.length, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          final isLast = index == _steps.length - 1;
          
          return Expanded(
            child: Row(
              children: [
                // Step circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isCurrent
                        ? iOS18Theme.systemBlue
                        : iOS18Theme.systemGray5.resolveFrom(context),
                    border: Border.all(
                      color: isCompleted || isCurrent
                          ? iOS18Theme.systemBlue
                          : iOS18Theme.systemGray4.resolveFrom(context),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            CupertinoIcons.checkmark,
                            size: 16,
                            color: CupertinoColors.white,
                          )
                        : Text(
                            '${index + 1}',
                            style: iOS18Theme.caption1.copyWith(
                              color: isCurrent
                                  ? CupertinoColors.white
                                  : iOS18Theme.secondaryLabel.resolveFrom(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                // Line connector
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? iOS18Theme.systemBlue
                            : iOS18Theme.systemGray5.resolveFrom(context),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildDataSourceStep();
      case 2:
        return _buildAppearanceStep();
      case 3:
        return _buildSettingsStep();
      case 4:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Widget preview
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iOS18Theme.systemBlue.withOpacity(0.3),
                  iOS18Theme.systemPurple.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.chart_line,
                    size: 60,
                    color: iOS18Theme.systemBlue,
                  ),
                  const SizedBox(height: iOS18Theme.spacing12),
                  Text(
                    _titleController.text.isEmpty ? 'Your Widget' : _titleController.text,
                    style: iOS18Theme.title2.copyWith(
                      color: iOS18Theme.label.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: iOS18Theme.spacing24),
          
          // Title field
          Text(
            'Widget Name',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing8),
          CupertinoTextField(
            controller: _titleController,
            placeholder: 'e.g., My Portfolio Tracker',
            padding: const EdgeInsets.all(iOS18Theme.spacing12),
            decoration: BoxDecoration(
              color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
            ),
            style: iOS18Theme.body.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          
          const SizedBox(height: iOS18Theme.spacing20),
          
          // Description field
          Text(
            'Description',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing8),
          CupertinoTextField(
            controller: _descriptionController,
            placeholder: 'Describe what your widget does...',
            maxLines: 4,
            padding: const EdgeInsets.all(iOS18Theme.spacing12),
            decoration: BoxDecoration(
              color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
            ),
            style: iOS18Theme.body.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          
          const SizedBox(height: iOS18Theme.spacing20),
          
          // Widget type selector
          Text(
            'Widget Type',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          _buildTypeSelector(),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    final types = [
      {'id': 'chart', 'name': 'Chart', 'icon': CupertinoIcons.chart_line},
      {'id': 'list', 'name': 'List', 'icon': CupertinoIcons.list_bullet},
      {'id': 'card', 'name': 'Card', 'icon': CupertinoIcons.square_grid_2x2},
      {'id': 'gauge', 'name': 'Gauge', 'icon': CupertinoIcons.gauge},
    ];
    
    return Wrap(
      spacing: iOS18Theme.spacing12,
      runSpacing: iOS18Theme.spacing12,
      children: types.map((type) {
        final isSelected = _selectedType == type['id'];
        return GestureDetector(
          onTap: () {
            iOS18Theme.lightImpact();
            setState(() => _selectedType = type['id'] as String);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isSelected
                  ? iOS18Theme.systemBlue.withOpacity(0.1)
                  : iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
              border: Border.all(
                color: isSelected
                    ? iOS18Theme.systemBlue
                    : iOS18Theme.separator.resolveFrom(context),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type['icon'] as IconData,
                  size: 30,
                  color: isSelected
                      ? iOS18Theme.systemBlue
                      : iOS18Theme.secondaryLabel.resolveFrom(context),
                ),
                const SizedBox(height: iOS18Theme.spacing4),
                Text(
                  type['name'] as String,
                  style: iOS18Theme.caption1.copyWith(
                    color: isSelected
                        ? iOS18Theme.systemBlue
                        : iOS18Theme.label.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDataSourceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Symbol input
          Text(
            'Symbol/Ticker',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing8),
          CupertinoTextField(
            controller: _symbolController,
            placeholder: 'e.g., AAPL, BTC-USD',
            padding: const EdgeInsets.all(iOS18Theme.spacing12),
            decoration: BoxDecoration(
              color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
            ),
            style: iOS18Theme.body.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          
          const SizedBox(height: iOS18Theme.spacing20),
          
          // Timeframe selector
          Text(
            'Timeframe',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          _buildTimeframeSelector(),
          
          const SizedBox(height: iOS18Theme.spacing20),
          
          // Data provider
          Text(
            'Data Provider',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          _buildDataProviderList(),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    final timeframes = ['1D', '1W', '1M', '3M', '6M', '1Y', 'All'];
    
    return Container(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: timeframes.length,
        itemBuilder: (context, index) {
          final timeframe = timeframes[index];
          final isSelected = _selectedTimeframe == timeframe;
          
          return Padding(
            padding: const EdgeInsets.only(right: iOS18Theme.spacing8),
            child: GestureDetector(
              onTap: () {
                iOS18Theme.lightImpact();
                setState(() => _selectedTimeframe = timeframe);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: iOS18Theme.spacing16,
                  vertical: iOS18Theme.spacing8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? iOS18Theme.systemBlue
                      : iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
                  border: Border.all(
                    color: isSelected
                        ? iOS18Theme.systemBlue
                        : iOS18Theme.separator.resolveFrom(context),
                  ),
                ),
                child: Center(
                  child: Text(
                    timeframe,
                    style: iOS18Theme.footnote.copyWith(
                      color: isSelected
                          ? CupertinoColors.white
                          : iOS18Theme.label.resolveFrom(context),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataProviderList() {
    final providers = [
      {'name': 'Yahoo Finance', 'status': 'Connected', 'icon': CupertinoIcons.globe},
      {'name': 'Alpha Vantage', 'status': 'API Key Required', 'icon': CupertinoIcons.chart_bar},
      {'name': 'CoinGecko', 'status': 'Connected', 'icon': CupertinoIcons.bitcoin},
    ];
    
    return Column(
      children: providers.map((provider) {
        final isConnected = provider['status'] == 'Connected';
        return Container(
          margin: const EdgeInsets.only(bottom: iOS18Theme.spacing8),
          padding: const EdgeInsets.all(iOS18Theme.spacing12),
          decoration: BoxDecoration(
            color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
          ),
          child: Row(
            children: [
              Icon(
                provider['icon'] as IconData,
                size: 24,
                color: isConnected ? iOS18Theme.systemGreen : iOS18Theme.systemOrange,
              ),
              const SizedBox(width: iOS18Theme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider['name'] as String,
                      style: iOS18Theme.body.copyWith(
                        color: iOS18Theme.label.resolveFrom(context),
                      ),
                    ),
                    Text(
                      provider['status'] as String,
                      style: iOS18Theme.caption1.copyWith(
                        color: isConnected
                            ? iOS18Theme.systemGreen
                            : iOS18Theme.systemOrange,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAppearanceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart style
          Text(
            'Chart Style',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          _buildChartStyleSelector(),
          
          const SizedBox(height: iOS18Theme.spacing20),
          
          // Color theme
          Text(
            'Color Theme',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          _buildColorThemeSelector(),
          
          const SizedBox(height: iOS18Theme.spacing20),
          
          // Additional options
          Text(
            'Display Options',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          _buildDisplayOptions(),
        ],
      ),
    );
  }

  Widget _buildChartStyleSelector() {
    final styles = [
      {'id': 'line', 'name': 'Line'},
      {'id': 'candle', 'name': 'Candle'},
      {'id': 'bar', 'name': 'Bar'},
      {'id': 'area', 'name': 'Area'},
    ];
    
    return Wrap(
      spacing: iOS18Theme.spacing8,
      children: styles.map((style) {
        final isSelected = _selectedStyle == style['id'];
        return GestureDetector(
          onTap: () {
            iOS18Theme.lightImpact();
            setState(() => _selectedStyle = style['id'] as String);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: iOS18Theme.spacing16,
              vertical: iOS18Theme.spacing8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? iOS18Theme.systemBlue
                  : iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
              border: Border.all(
                color: isSelected
                    ? iOS18Theme.systemBlue
                    : iOS18Theme.separator.resolveFrom(context),
              ),
            ),
            child: Text(
              style['name'] as String,
              style: iOS18Theme.footnote.copyWith(
                color: isSelected
                    ? CupertinoColors.white
                    : iOS18Theme.label.resolveFrom(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorThemeSelector() {
    final colors = [
      iOS18Theme.systemBlue,
      iOS18Theme.systemGreen,
      iOS18Theme.systemPurple,
      iOS18Theme.systemOrange,
      iOS18Theme.systemPink,
      iOS18Theme.systemRed,
    ];
    
    return Row(
      children: colors.map((color) {
        return Padding(
          padding: const EdgeInsets.only(right: iOS18Theme.spacing12),
          child: GestureDetector(
            onTap: () {
              iOS18Theme.lightImpact();
              // Handle color selection
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: iOS18Theme.separator.resolveFrom(context),
                  width: 2,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDisplayOptions() {
    return Column(
      children: [
        _buildSwitchOption('Show Volume', _showVolume, (value) {
          setState(() => _showVolume = value);
        }),
        _buildSwitchOption('Show Indicators', _showIndicators, (value) {
          setState(() => _showIndicators = value);
        }),
      ],
    );
  }

  Widget _buildSettingsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Privacy settings
          Text(
            'Privacy',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          _buildSwitchOption('Make Public', _isPublic, (value) {
            setState(() => _isPublic = value);
          }),
          
          const SizedBox(height: iOS18Theme.spacing20),
          
          // Refresh settings
          Text(
            'Auto Refresh',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          Text(
            'Update every ${_refreshInterval.toInt()} minutes',
            style: iOS18Theme.body.copyWith(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
            ),
          ),
          CupertinoSlider(
            value: _refreshInterval,
            min: 1,
            max: 60,
            divisions: 59,
            onChanged: (value) {
              setState(() => _refreshInterval = value);
            },
          ),
          
          const SizedBox(height: iOS18Theme.spacing20),
          
          // Notifications
          Text(
            'Notifications',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          _buildNotificationOptions(),
        ],
      ),
    );
  }

  Widget _buildNotificationOptions() {
    return Column(
      children: [
        _buildSwitchOption('Price Alerts', true, (value) {}),
        _buildSwitchOption('Volume Spikes', false, (value) {}),
        _buildSwitchOption('Technical Indicators', false, (value) {}),
      ],
    );
  }

  Widget _buildSwitchOption(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: iOS18Theme.spacing8),
      padding: const EdgeInsets.all(iOS18Theme.spacing12),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: iOS18Theme.body.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: iOS18Theme.systemBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview card
          Container(
            padding: const EdgeInsets.all(iOS18Theme.spacing16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iOS18Theme.systemBlue,
                  iOS18Theme.systemPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Widget Preview',
                  style: iOS18Theme.caption1.copyWith(
                    color: CupertinoColors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: iOS18Theme.spacing8),
                Text(
                  _titleController.text.isEmpty ? 'Untitled Widget' : _titleController.text,
                  style: iOS18Theme.title1.copyWith(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: iOS18Theme.spacing4),
                Text(
                  _descriptionController.text.isEmpty 
                      ? 'No description' 
                      : _descriptionController.text,
                  style: iOS18Theme.footnote.copyWith(
                    color: CupertinoColors.white.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: iOS18Theme.spacing24),
          
          // Summary
          Text(
            'Summary',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          _buildSummaryItem('Type', _selectedType),
          _buildSummaryItem('Symbol', _symbolController.text.isEmpty ? 'Not set' : _symbolController.text),
          _buildSummaryItem('Timeframe', _selectedTimeframe),
          _buildSummaryItem('Style', _selectedStyle),
          _buildSummaryItem('Visibility', _isPublic ? 'Public' : 'Private'),
          _buildSummaryItem('Auto Refresh', '${_refreshInterval.toInt()} min'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: iOS18Theme.spacing8),
      padding: const EdgeInsets.all(iOS18Theme.spacing12),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: iOS18Theme.body.copyWith(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
            ),
          ),
          Text(
            value,
            style: iOS18Theme.body.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      decoration: BoxDecoration(
        color: iOS18Theme.systemBackground.resolveFrom(context),
        border: Border(
          top: BorderSide(
            color: iOS18Theme.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            CupertinoButton(
              onPressed: _previousStep,
              child: const Text('Back'),
            ),
          const Spacer(),
          CupertinoButton.filled(
            onPressed: _nextStep,
            child: Text(
              _currentStep == _steps.length - 1 ? 'Create Widget' : 'Continue',
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success!'),
        content: const Text('Your widget has been created successfully.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('View Widget'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Get.toNamed('/widget/${_controller.createdWidgetId}');
            },
          ),
          CupertinoDialogAction(
            child: const Text('Create Another'),
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _currentStep = 0;
      _titleController.clear();
      _descriptionController.clear();
      _symbolController.clear();
      _selectedType = 'chart';
      _selectedTimeframe = '1D';
      _selectedStyle = 'line';
      _showVolume = true;
      _showIndicators = false;
      _isPublic = true;
      _refreshInterval = 5.0;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _symbolController.dispose();
    _animationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }
}