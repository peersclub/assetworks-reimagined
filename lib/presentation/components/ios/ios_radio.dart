import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/ios18_theme.dart';

class iOSRadioButton<T> extends StatefulWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;
  
  const iOSRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.size = 24,
  });
  
  @override
  State<iOSRadioButton<T>> createState() => _iOSRadioButtonState<T>();
}

class _iOSRadioButtonState<T> extends State<iOSRadioButton<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _innerCircleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _innerCircleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    if (widget.value == widget.groupValue) {
      _controller.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(iOSRadioButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupValue != widget.groupValue) {
      if (widget.value == widget.groupValue) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onChanged(widget.value);
  }
  
  @override
  Widget build(BuildContext context) {
    final isSelected = widget.value == widget.groupValue;
    final activeColor = widget.activeColor ?? iOS18Theme.systemBlue;
    final inactiveColor = widget.inactiveColor ?? iOS18Theme.separator.resolveFrom(context);
    
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_scaleAnimation.value - 1.0).abs(),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeColor : inactiveColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: ScaleTransition(
                  scale: _innerCircleAnimation,
                  child: Container(
                    width: widget.size * 0.5,
                    height: widget.size * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? activeColor : CupertinoColors.clear,
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
}

// Radio button with label
class iOSRadioListTile<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Color? activeColor;
  final EdgeInsets? contentPadding;
  final bool enabled;
  
  const iOSRadioListTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.leading,
    this.activeColor,
    this.contentPadding,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    
    return GestureDetector(
      onTap: enabled ? () => onChanged(value) : null,
      child: Container(
        padding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? iOS18Theme.systemBlue.withOpacity(0.1)
              : iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: iOS18Theme.systemBlue.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: enabled
                          ? iOS18Theme.label.resolveFrom(context)
                          : iOS18Theme.tertiaryLabel.resolveFrom(context),
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: enabled
                            ? iOS18Theme.secondaryLabel.resolveFrom(context)
                            : iOS18Theme.quaternaryLabel.resolveFrom(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            iOSRadioButton<T>(
              value: value,
              groupValue: groupValue,
              onChanged: enabled ? onChanged : (_) {},
              activeColor: activeColor,
            ),
          ],
        ),
      ),
    );
  }
}

// Radio group
class iOSRadioGroup<T> extends StatelessWidget {
  final List<RadioItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T?> onChanged;
  final String? title;
  final Color? activeColor;
  final EdgeInsets? padding;
  final double spacing;
  
  const iOSRadioGroup({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.title,
    this.activeColor,
    this.padding,
    this.spacing = 12,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                color: iOS18Theme.label.resolveFrom(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...items.map((item) {
            final isSelected = item.value == selectedValue;
            final index = items.indexOf(item);
            
            return Padding(
              padding: EdgeInsets.only(bottom: index < items.length - 1 ? spacing : 0),
              child: GestureDetector(
                onTap: item.enabled ? () => onChanged(item.value) : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor?.withOpacity(0.1) ?? iOS18Theme.systemBlue.withOpacity(0.1)
                        : CupertinoColors.clear,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(
                            color: activeColor?.withOpacity(0.3) ?? 
                                iOS18Theme.systemBlue.withOpacity(0.3),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      iOSRadioButton<T>(
                        value: item.value,
                        groupValue: selectedValue,
                        onChanged: item.enabled ? onChanged : (_) {},
                        activeColor: activeColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: TextStyle(
                                color: item.enabled
                                    ? iOS18Theme.label.resolveFrom(context)
                                    : iOS18Theme.tertiaryLabel.resolveFrom(context),
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            if (item.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle!,
                                style: TextStyle(
                                  color: item.enabled
                                      ? iOS18Theme.secondaryLabel.resolveFrom(context)
                                      : iOS18Theme.quaternaryLabel.resolveFrom(context),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (item.trailing != null) ...[
                        const SizedBox(width: 8),
                        item.trailing!,
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Segmented style radio group (iOS style)
class iOSSegmentedRadioGroup<T> extends StatefulWidget {
  final List<SegmentedRadioItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final Color? activeColor;
  final Color? backgroundColor;
  final double height;
  
  const iOSSegmentedRadioGroup({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.activeColor,
    this.backgroundColor,
    this.height = 44,
  });
  
  @override
  State<iOSSegmentedRadioGroup<T>> createState() => _iOSSegmentedRadioGroupState<T>();
}

class _iOSSegmentedRadioGroupState<T> extends State<iOSSegmentedRadioGroup<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentIndex = 0;
  int _previousIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _currentIndex = widget.items.indexWhere((item) => item.value == widget.selectedValue);
    if (_currentIndex == -1) _currentIndex = 0;
  }
  
  @override
  void didUpdateWidget(iOSSegmentedRadioGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = widget.items.indexWhere((item) => item.value == widget.selectedValue);
    if (newIndex != -1 && newIndex != _currentIndex) {
      _previousIndex = _currentIndex;
      _currentIndex = newIndex;
      _controller.forward(from: 0);
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? iOS18Theme.systemBlue;
    final backgroundColor = widget.backgroundColor ?? 
        iOS18Theme.tertiarySystemFill.resolveFrom(context);
    
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(widget.height / 2),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final itemWidth = MediaQuery.of(context).size.width / widget.items.length;
              final offset = _previousIndex * itemWidth +
                  (_currentIndex - _previousIndex) * itemWidth * _animation.value;
              
              return Positioned(
                left: offset,
                top: 2,
                bottom: 2,
                width: itemWidth - 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular((widget.height - 4) / 2),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Row(
            children: widget.items.map((item) {
              final index = widget.items.indexOf(item);
              final isSelected = item.value == widget.selectedValue;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onChanged(item.value);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.icon != null) ...[
                          Icon(
                            item.icon,
                            size: 18,
                            color: isSelected ? activeColor : iOS18Theme.label.resolveFrom(context),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected ? activeColor : iOS18Theme.label.resolveFrom(context),
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class RadioItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final bool enabled;
  
  RadioItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.trailing,
    this.enabled = true,
  });
}

class SegmentedRadioItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  
  SegmentedRadioItem({
    required this.value,
    required this.label,
    this.icon,
  });
}