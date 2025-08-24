import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/ios18_theme.dart';

class iOSStepper extends StatefulWidget {
  final double value;
  final double minimumValue;
  final double maximumValue;
  final double stepValue;
  final Function(double) onChanged;
  final bool wraps;
  
  const iOSStepper({
    super.key,
    required this.value,
    this.minimumValue = 0,
    this.maximumValue = 100,
    this.stepValue = 1,
    required this.onChanged,
    this.wraps = false,
  });
  
  @override
  State<iOSStepper> createState() => _iOSStepperState();
}

class _iOSStepperState extends State<iOSStepper> {
  late double _currentValue;
  
  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }
  
  @override
  void didUpdateWidget(iOSStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }
  
  void _increment() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_currentValue + widget.stepValue <= widget.maximumValue) {
        _currentValue += widget.stepValue;
      } else if (widget.wraps) {
        _currentValue = widget.minimumValue;
      }
    });
    widget.onChanged(_currentValue);
  }
  
  void _decrement() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_currentValue - widget.stepValue >= widget.minimumValue) {
        _currentValue -= widget.stepValue;
      } else if (widget.wraps) {
        _currentValue = widget.maximumValue;
      }
    });
    widget.onChanged(_currentValue);
  }
  
  @override
  Widget build(BuildContext context) {
    final canIncrement = widget.wraps || _currentValue < widget.maximumValue;
    final canDecrement = widget.wraps || _currentValue > widget.minimumValue;
    
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: iOS18Theme.tertiarySystemFill.resolveFrom(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: iOS18Theme.separator.resolveFrom(context),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minSize: 32,
            onPressed: canDecrement ? _decrement : null,
            child: Icon(
              CupertinoIcons.minus,
              size: 16,
              color: canDecrement
                  ? iOS18Theme.systemBlue
                  : iOS18Theme.quaternaryLabel.resolveFrom(context),
            ),
          ),
          Container(
            width: 0.5,
            height: 20,
            color: iOS18Theme.separator.resolveFrom(context),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minSize: 32,
            onPressed: canIncrement ? _increment : null,
            child: Icon(
              CupertinoIcons.plus,
              size: 16,
              color: canIncrement
                  ? iOS18Theme.systemBlue
                  : iOS18Theme.quaternaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}

// Stepper with value display
class iOSStepperWithValue extends StatefulWidget {
  final double value;
  final double minimumValue;
  final double maximumValue;
  final double stepValue;
  final Function(double) onChanged;
  final String? prefix;
  final String? suffix;
  final int decimals;
  
  const iOSStepperWithValue({
    super.key,
    required this.value,
    this.minimumValue = 0,
    this.maximumValue = 100,
    this.stepValue = 1,
    required this.onChanged,
    this.prefix,
    this.suffix,
    this.decimals = 0,
  });
  
  @override
  State<iOSStepperWithValue> createState() => _iOSStepperWithValueState();
}

class _iOSStepperWithValueState extends State<iOSStepperWithValue> {
  late double _currentValue;
  
  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }
  
  String _formatValue(double value) {
    final formatted = value.toStringAsFixed(widget.decimals);
    final prefix = widget.prefix ?? '';
    final suffix = widget.suffix ?? '';
    return '$prefix$formatted$suffix';
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _formatValue(_currentValue),
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        iOSStepper(
          value: _currentValue,
          minimumValue: widget.minimumValue,
          maximumValue: widget.maximumValue,
          stepValue: widget.stepValue,
          onChanged: (value) {
            setState(() {
              _currentValue = value;
            });
            widget.onChanged(value);
          },
        ),
      ],
    );
  }
}

// Stepper field with label
class iOSStepperField extends StatefulWidget {
  final String label;
  final double value;
  final double minimumValue;
  final double maximumValue;
  final double stepValue;
  final Function(double) onChanged;
  final String? prefix;
  final String? suffix;
  final String? helperText;
  final IconData? icon;
  
  const iOSStepperField({
    super.key,
    required this.label,
    required this.value,
    this.minimumValue = 0,
    this.maximumValue = 100,
    this.stepValue = 1,
    required this.onChanged,
    this.prefix,
    this.suffix,
    this.helperText,
    this.icon,
  });
  
  @override
  State<iOSStepperField> createState() => _iOSStepperFieldState();
}

class _iOSStepperFieldState extends State<iOSStepperField>
    with SingleTickerProviderStateMixin {
  late double _currentValue;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  String _formatValue(double value) {
    final intValue = value.toInt();
    final prefix = widget.prefix ?? '';
    final suffix = widget.suffix ?? '';
    return '$prefix$intValue$suffix';
  }
  
  void _handleChange(double value) {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    setState(() {
      _currentValue = value;
    });
    widget.onChanged(value);
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: iOS18Theme.systemBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: iOS18Theme.label.resolveFrom(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatValue(_currentValue),
                      style: TextStyle(
                        color: iOS18Theme.systemBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: iOSStepper(
                    value: _currentValue,
                    minimumValue: widget.minimumValue,
                    maximumValue: widget.maximumValue,
                    stepValue: widget.stepValue,
                    onChanged: _handleChange,
                  ),
                ),
                if (widget.helperText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.helperText!,
                    style: TextStyle(
                      color: iOS18Theme.secondaryLabel.resolveFrom(context),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// Compact stepper for inline use
class iOSCompactStepper extends StatefulWidget {
  final int value;
  final int minimumValue;
  final int maximumValue;
  final Function(int) onChanged;
  
  const iOSCompactStepper({
    super.key,
    required this.value,
    this.minimumValue = 0,
    this.maximumValue = 10,
    required this.onChanged,
  });
  
  @override
  State<iOSCompactStepper> createState() => _iOSCompactStepperState();
}

class _iOSCompactStepperState extends State<iOSCompactStepper> {
  late int _currentValue;
  
  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }
  
  void _increment() {
    if (_currentValue < widget.maximumValue) {
      HapticFeedback.selectionFeedback();
      setState(() {
        _currentValue++;
      });
      widget.onChanged(_currentValue);
    }
  }
  
  void _decrement() {
    if (_currentValue > widget.minimumValue) {
      HapticFeedback.selectionFeedback();
      setState(() {
        _currentValue--;
      });
      widget.onChanged(_currentValue);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: iOS18Theme.tertiarySystemFill.resolveFrom(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _decrement,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _currentValue > widget.minimumValue
                    ? iOS18Theme.systemBlue.withOpacity(0.2)
                    : CupertinoColors.clear,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              ),
              child: Icon(
                CupertinoIcons.minus,
                size: 14,
                color: _currentValue > widget.minimumValue
                    ? iOS18Theme.systemBlue
                    : iOS18Theme.quaternaryLabel.resolveFrom(context),
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _currentValue.toString(),
              style: TextStyle(
                color: iOS18Theme.label.resolveFrom(context),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTap: _increment,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _currentValue < widget.maximumValue
                    ? iOS18Theme.systemBlue.withOpacity(0.2)
                    : CupertinoColors.clear,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
              ),
              child: Icon(
                CupertinoIcons.plus,
                size: 14,
                color: _currentValue < widget.maximumValue
                    ? iOS18Theme.systemBlue
                    : iOS18Theme.quaternaryLabel.resolveFrom(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}