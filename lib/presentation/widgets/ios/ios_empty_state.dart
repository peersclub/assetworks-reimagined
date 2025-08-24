import 'package:flutter/cupertino.dart';
import '../../../core/theme/ios_theme.dart';

class iOSEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionTitle;
  final VoidCallback? onAction;

  const iOSEmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionTitle,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(iOS18Theme.spacing32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: iOS18Theme.systemGray6.resolveFrom(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 50,
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing24),
          Text(
            title,
            style: iOS18Theme.title2.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: iOS18Theme.spacing8),
          Text(
            message,
            style: iOS18Theme.body.copyWith(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
            ),
            textAlign: TextAlign.center,
          ),
          if (actionTitle != null && onAction != null) ...[
            const SizedBox(height: iOS18Theme.spacing24),
            CupertinoButton.filled(
              onPressed: onAction,
              child: Text(actionTitle!),
            ),
          ],
        ],
      ),
    );
  }
}