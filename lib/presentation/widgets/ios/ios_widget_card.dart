import 'package:flutter/cupertino.dart';
import '../../../core/theme/ios_theme.dart';

class iOSWidgetCard extends StatelessWidget {
  final dynamic widget;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isCompact;

  const iOSWidgetCard({
    Key? key,
    required this.widget,
    this.onTap,
    this.onLongPress,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.all(isCompact ? iOS18Theme.spacing12 : iOS18Theme.spacing16),
        decoration: BoxDecoration(
          color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iOS18Theme.systemBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
                  ),
                  child: Icon(
                    CupertinoIcons.chart_bar_fill,
                    size: 20,
                    color: iOS18Theme.systemBlue,
                  ),
                ),
                const SizedBox(width: iOS18Theme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title ?? 'Widget',
                        style: iOS18Theme.headline.copyWith(
                          color: iOS18Theme.label.resolveFrom(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.type ?? 'Chart',
                        style: iOS18Theme.caption1.copyWith(
                          color: iOS18Theme.secondaryLabel.resolveFrom(context),
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
            if (!isCompact) ...[
              const SizedBox(height: iOS18Theme.spacing12),
              Text(
                widget.description ?? 'Investment tracking widget',
                style: iOS18Theme.footnote.copyWith(
                  color: iOS18Theme.secondaryLabel.resolveFrom(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}