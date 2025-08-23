import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';

class CreativeLoadingDialog extends StatefulWidget {
  final String title;
  final VoidCallback? onNotify;
  
  const CreativeLoadingDialog({
    Key? key,
    required this.title,
    this.onNotify,
  }) : super(key: key);
  
  static void show(BuildContext context, {
    required String title,
    VoidCallback? onNotify,
  }) {
    Get.dialog(
      CreativeLoadingDialog(
        title: title,
        onNotify: onNotify,
      ),
      barrierDismissible: false,
    );
  }
  
  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
  
  @override
  State<CreativeLoadingDialog> createState() => _CreativeLoadingDialogState();
}

class _CreativeLoadingDialogState extends State<CreativeLoadingDialog> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  int _messageIndex = 0;
  Timer? _messageTimer;
  Timer? _notifyTimer;
  bool _showNotifyOption = false;
  int _secondsElapsed = 0;
  
  final List<Map<String, dynamic>> _loadingMessages = [
    {'icon': LucideIcons.brain, 'text': 'Analyzing your requirements...'},
    {'icon': LucideIcons.barChart3, 'text': 'Gathering market data...'},
    {'icon': LucideIcons.palette, 'text': 'Designing the perfect layout...'},
    {'icon': LucideIcons.zap, 'text': 'Optimizing performance...'},
    {'icon': LucideIcons.search, 'text': 'Adding interactive features...'},
    {'icon': LucideIcons.sparkles, 'text': 'Applying final touches...'},
    {'icon': LucideIcons.rocket, 'text': 'Almost ready...'},
  ];
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Change message every 3 seconds
    _messageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
        });
      }
    });
    
    // Show notify option after 15 seconds
    _notifyTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _showNotifyOption = true;
        });
      }
    });
    
    // Track elapsed time
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _messageTimer?.cancel();
    _notifyTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon container
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.sparkles,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Animated message with icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Row(
                  key: ValueKey(_messageIndex),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _loadingMessages[_messageIndex]['icon'] as IconData,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _loadingMessages[_messageIndex]['text'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Progress bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.neutral800 : AppColors.neutral200,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          width: constraints.maxWidth * 
                              ((_messageIndex + 1) / _loadingMessages.length),
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              
              // Time elapsed
              Text(
                'Time elapsed: ${_secondsElapsed}s',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.neutral500 : AppColors.neutral400,
                ),
              ),
              
              // Notify option (appears after 15 seconds)
              if (_showNotifyOption) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This is taking longer than expected',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Wait',
                              icon: LucideIcons.clock,
                              type: AppButtonType.outline,
                              size: AppButtonSize.small,
                              onPressed: () {
                                setState(() {
                                  _showNotifyOption = false;
                                });
                                // Reset timer for another 15 seconds
                                _notifyTimer?.cancel();
                                _notifyTimer = Timer(const Duration(seconds: 15), () {
                                  if (mounted) {
                                    setState(() {
                                      _showNotifyOption = true;
                                    });
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppButton(
                              text: 'Notify Me',
                              icon: LucideIcons.bell,
                              size: AppButtonSize.small,
                              onPressed: () {
                                if (widget.onNotify != null) {
                                  widget.onNotify!();
                                }
                                Get.back();
                                Get.snackbar(
                                  'Notification Set',
                                  'We\'ll notify you when your analysis is ready',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: AppColors.success,
                                  colorText: Colors.white,
                                  icon: const Icon(
                                    LucideIcons.bell,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}