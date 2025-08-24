import 'package:flutter/cupertino.dart';

class IOSSegmentedControl extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int?>? onChanged;
  
  const IOSSegmentedControl({
    Key? key,
    required this.options,
    required this.selectedIndex,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<int>(
      groupValue: selectedIndex,
      children: Map.fromIterables(
        List.generate(options.length, (index) => index),
        options.map((option) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(option),
        )).toList(),
      ),
      onValueChanged: (value) => onChanged?.call(value),
    );
  }
}