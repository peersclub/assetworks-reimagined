import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/ios18_theme.dart';

class iOSCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? checkColor;
  final double size;
  final bool tristate;
  final bool? tristateValue;
  
  const iOSCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.checkColor,
    this.size = 24,
    this.tristate = false,
    this.tristateValue,
  });
  
  @override
  State<iOSCheckbox> createState() => _iOSCheckboxState();
}

class _iOSCheckboxState extends State<iOSCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  
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
    
    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    if (widget.value || (widget.tristate && widget.tristateValue != null)) {
      _controller.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(iOSCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || 
        oldWidget.tristateValue != widget.tristateValue) {
      if (widget.value || (widget.tristate && widget.tristateValue != null)) {
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
    
    if (widget.tristate) {
      // null -> false -> true -> null
      if (widget.tristateValue == null) {
        widget.onChanged(false);
      } else if (!widget.value) {
        widget.onChanged(true);
      } else {
        widget.onChanged(false); // Will be handled as null by parent
      }
    } else {
      widget.onChanged(!widget.value);
    }
    
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? iOS18Theme.systemBlue;
    final checkColor = widget.checkColor ?? CupertinoColors.white;
    
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
                color: widget.value || (widget.tristate && widget.tristateValue != null)
                    ? activeColor
                    : CupertinoColors.clear,
                borderRadius: BorderRadius.circular(widget.size / 4),
                border: Border.all(
                  color: widget.value || (widget.tristate && widget.tristateValue != null)
                      ? activeColor
                      : iOS18Theme.separator.resolveFrom(context),
                  width: widget.value || (widget.tristate && widget.tristateValue != null) ? 0 : 2,
                ),
              ),
              child: widget.tristate && widget.tristateValue == null && widget.value
                  ? Icon(
                      CupertinoIcons.minus,
                      color: checkColor,
                      size: widget.size * 0.6,
                    )
                  : widget.value
                      ? ScaleTransition(
                          scale: _checkAnimation,
                          child: Icon(
                            CupertinoIcons.checkmark,
                            color: checkColor,
                            size: widget.size * 0.6,
                          ),
                        )
                      : null,
            ),
          );
        },
      ),
    );
  }
}

// Checkbox with label
class iOSCheckboxListTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Color? activeColor;
  final EdgeInsets? contentPadding;
  final bool enabled;
  
  const iOSCheckboxListTile({
    super.key,
    required this.value,
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
    return GestureDetector(
      onTap: enabled ? () => onChanged(!value) : null,
      child: Container(
        padding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
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
                      fontWeight: FontWeight.w500,
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
            iOSCheckbox(
              value: value,
              onChanged: enabled ? onChanged : (_) {},
              activeColor: activeColor,
            ),
          ],
        ),
      ),
    );
  }
}

// Circular checkbox (iOS style)
class iOSCircularCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? checkColor;
  final double size;
  
  const iOSCircularCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.checkColor,
    this.size = 24,
  });
  
  @override
  State<iOSCircularCheckbox> createState() => _iOSCircularCheckboxState();
}

class _iOSCircularCheckboxState extends State<iOSCircularCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    if (widget.value) {
      _controller.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(iOSCircularCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
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
  
  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? iOS18Theme.systemBlue;
    final checkColor = widget.checkColor ?? CupertinoColors.white;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onChanged(!widget.value);
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.value ? activeColor : iOS18Theme.separator.resolveFrom(context),
            width: 2,
          ),
        ),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.value ? activeColor : CupertinoColors.clear,
                ),
                child: widget.value
                    ? Icon(
                        CupertinoIcons.checkmark,
                        color: checkColor,
                        size: widget.size * 0.5,
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

// Checkbox group
class iOSCheckboxGroup extends StatelessWidget {
  final List<CheckboxItem> items;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final String? title;
  final Color? activeColor;
  final EdgeInsets? padding;
  
  const iOSCheckboxGroup({
    super.key,
    required this.items,
    required this.selectedValues,
    required this.onChanged,
    this.title,
    this.activeColor,
    this.padding,
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
            final isSelected = selectedValues.contains(item.value);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: item.enabled ? () {
                  final newValues = List<String>.from(selectedValues);
                  if (isSelected) {
                    newValues.remove(item.value);
                  } else {
                    newValues.add(item.value);
                  }
                  onChanged(newValues);
                } : null,
                child: Row(
                  children: [
                    iOSCheckbox(
                      value: isSelected,
                      onChanged: item.enabled ? (value) {
                        final newValues = List<String>.from(selectedValues);
                        if (value) {
                          newValues.add(item.value);
                        } else {
                          newValues.remove(item.value);
                        }
                        onChanged(newValues);
                      } : (_) {},
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
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class CheckboxItem {
  final String value;
  final String label;
  final String? subtitle;
  final bool enabled;
  
  CheckboxItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.enabled = true,
  });
}