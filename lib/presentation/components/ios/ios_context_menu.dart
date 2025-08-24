import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../core/theme/ios18_theme.dart';

class iOSContextMenu extends StatelessWidget {
  final Widget child;
  final List<ContextMenuItem> actions;
  final Widget? previewBuilder;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  
  const iOSContextMenu({
    super.key,
    required this.child,
    required this.actions,
    this.previewBuilder,
    this.onOpen,
    this.onClose,
  });
  
  @override
  Widget build(BuildContext context) {
    return CupertinoContextMenu(
      enableHapticFeedback: true,
      actions: actions.map((action) => _buildAction(context, action)).toList(),
      previewBuilder: (context, animation, child) {
        if (previewBuilder != null) {
          return previewBuilder!;
        }
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20 * animation.value,
              sigmaY: 20 * animation.value,
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
  
  Widget _buildAction(BuildContext context, ContextMenuItem action) {
    return CupertinoContextMenuAction(
      isDestructiveAction: action.isDestructive,
      isDefaultAction: action.isDefault,
      trailingIcon: action.icon,
      onPressed: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).pop();
        action.onPressed();
      },
      child: Text(action.title),
    );
  }
}

class ContextMenuItem {
  final String title;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isDestructive;
  final bool isDefault;
  
  ContextMenuItem({
    required this.title,
    this.icon,
    required this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });
}

// Advanced context menu with sections
class iOSContextMenuAdvanced extends StatefulWidget {
  final Widget child;
  final List<ContextMenuSection> sections;
  final Widget Function(BuildContext, Animation<double>)? previewBuilder;
  
  const iOSContextMenuAdvanced({
    super.key,
    required this.child,
    required this.sections,
    this.previewBuilder,
  });
  
  @override
  State<iOSContextMenuAdvanced> createState() => _iOSContextMenuAdvancedState();
}

class _iOSContextMenuAdvancedState extends State<iOSContextMenuAdvanced>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isMenuOpen = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
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
  
  void _showContextMenu() {
    HapticFeedback.heavyImpact();
    _controller.forward();
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return _ContextMenuModal(
          sections: widget.sections,
          onDismiss: () {
            _controller.reverse();
            Navigator.of(context).pop();
          },
        );
      },
    ).then((_) {
      _controller.reverse();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showContextMenu,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _ContextMenuModal extends StatelessWidget {
  final List<ContextMenuSection> sections;
  final VoidCallback onDismiss;
  
  const _ContextMenuModal({
    required this.sections,
    required this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: CupertinoColors.black.withOpacity(0.4),
        child: Center(
          child: Container(
            width: 280,
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildSections(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  List<Widget> _buildSections(BuildContext context) {
    final widgets = <Widget>[];
    
    for (int i = 0; i < sections.length; i++) {
      final section = sections[i];
      
      if (section.title != null) {
        widgets.add(_buildSectionHeader(context, section.title!));
      }
      
      for (int j = 0; j < section.items.length; j++) {
        final item = section.items[j];
        final isLast = j == section.items.length - 1;
        widgets.add(_buildMenuItem(context, item, !isLast));
      }
      
      if (i < sections.length - 1) {
        widgets.add(_buildDivider(context));
      }
    }
    
    return widgets;
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: iOS18Theme.secondaryLabel.resolveFrom(context),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildMenuItem(BuildContext context, ContextMenuItem item, bool showDivider) {
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.lightImpact();
            onDismiss();
            item.onPressed();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: 22,
                    color: item.isDestructive
                        ? iOS18Theme.systemRed
                        : iOS18Theme.systemBlue,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: item.isDestructive
                          ? iOS18Theme.systemRed
                          : iOS18Theme.label.resolveFrom(context),
                      fontSize: 17,
                      fontWeight: item.isDefault ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: 0.5,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: iOS18Theme.separator.resolveFrom(context),
          ),
      ],
    );
  }
  
  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 8,
      color: iOS18Theme.separator.resolveFrom(context).withOpacity(0.2),
    );
  }
}

class ContextMenuSection {
  final String? title;
  final List<ContextMenuItem> items;
  
  ContextMenuSection({
    this.title,
    required this.items,
  });
}

// Context menu with preview
class iOSContextMenuWithPreview extends StatelessWidget {
  final Widget child;
  final Widget preview;
  final List<ContextMenuItem> actions;
  final double previewScale;
  
  const iOSContextMenuWithPreview({
    super.key,
    required this.child,
    required this.preview,
    required this.actions,
    this.previewScale = 1.2,
  });
  
  @override
  Widget build(BuildContext context) {
    return CupertinoContextMenu(
      enableHapticFeedback: true,
      actions: actions.map((action) {
        return CupertinoContextMenuAction(
          isDestructiveAction: action.isDestructive,
          isDefaultAction: action.isDefault,
          trailingIcon: action.icon,
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop();
            action.onPressed();
          },
          child: Text(action.title),
        );
      }).toList(),
      previewBuilder: (context, animation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 1.0,
              end: previewScale,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            )),
            child: Container(
              decoration: BoxDecoration(
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
                child: preview,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}