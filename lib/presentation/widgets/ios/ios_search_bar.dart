import 'package:flutter/cupertino.dart';

class IOSSearchBar extends StatelessWidget {
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  
  const IOSSearchBar({
    Key? key,
    this.placeholder = 'Search',
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      placeholder: placeholder,
      onChanged: onChanged,
      onSubmitted: (_) => onSubmitted?.call(),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}