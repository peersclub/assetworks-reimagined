import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class KeyboardNavigationService {
  static final KeyboardNavigationService _instance = KeyboardNavigationService._internal();
  factory KeyboardNavigationService() => _instance;
  KeyboardNavigationService._internal();

  // Focus nodes management
  final Map<String, FocusNode> _focusNodes = {};
  FocusNode? _currentFocus;

  // Register a focus node
  void registerFocusNode(String id, FocusNode node) {
    _focusNodes[id] = node;
  }

  // Unregister a focus node
  void unregisterFocusNode(String id) {
    _focusNodes[id]?.dispose();
    _focusNodes.remove(id);
  }

  // Get focus node by ID
  FocusNode? getFocusNode(String id) {
    return _focusNodes[id];
  }

  // Move focus to specific node
  void moveFocusTo(String id) {
    final node = _focusNodes[id];
    if (node != null) {
      node.requestFocus();
      _currentFocus = node;
    }
  }

  // Move focus in direction
  void moveFocus(BuildContext context, TraversalDirection direction) {
    FocusScope.of(context).focusInDirection(direction);
  }

  // Move to next focus
  void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  // Move to previous focus
  void previousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  // Clear all focus
  void clearFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  // Dispose all focus nodes
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    _focusNodes.clear();
  }
}

// Keyboard shortcut handler
class KeyboardShortcutHandler extends StatefulWidget {
  final Widget child;
  final Map<ShortcutActivator, VoidCallback> shortcuts;

  const KeyboardShortcutHandler({
    Key? key,
    required this.child,
    required this.shortcuts,
  }) : super(key: key);

  @override
  State<KeyboardShortcutHandler> createState() => _KeyboardShortcutHandlerState();
}

class _KeyboardShortcutHandlerState extends State<KeyboardShortcutHandler> {
  late Map<ShortcutActivator, Intent> _shortcuts;
  late Map<Type, Action<Intent>> _actions;

  @override
  void initState() {
    super.initState();
    _buildShortcuts();
  }

  void _buildShortcuts() {
    _shortcuts = {};
    _actions = {};

    int index = 0;
    for (final entry in widget.shortcuts.entries) {
      final intentType = _createIntentType(index);
      _shortcuts[entry.key] = intentType;
      _actions[intentType.runtimeType] = CallbackAction<Intent>(
        onInvoke: (Intent intent) => entry.value(),
      );
      index++;
    }
  }

  Intent _createIntentType(int index) {
    return _CustomIntent(index);
  }

  @override
  void didUpdateWidget(KeyboardShortcutHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shortcuts != widget.shortcuts) {
      _buildShortcuts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: _actions,
        child: widget.child,
      ),
    );
  }
}

class _CustomIntent extends Intent {
  final int id;
  const _CustomIntent(this.id);
}

// iOS-style keyboard navigation wrapper
class IOSKeyboardNavigator extends StatelessWidget {
  final Widget child;
  final bool enableArrowNavigation;
  final bool enableTabNavigation;
  final bool enableEscapeToClose;
  final VoidCallback? onEscape;

  const IOSKeyboardNavigator({
    Key? key,
    required this.child,
    this.enableArrowNavigation = true,
    this.enableTabNavigation = true,
    this.enableEscapeToClose = true,
    this.onEscape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shortcuts = <ShortcutActivator, VoidCallback>{};

    if (enableTabNavigation) {
      shortcuts[const SingleActivator(LogicalKeyboardKey.tab)] = () {
        KeyboardNavigationService().nextFocus(context);
      };
      shortcuts[const SingleActivator(LogicalKeyboardKey.tab, shift: true)] = () {
        KeyboardNavigationService().previousFocus(context);
      };
    }

    if (enableArrowNavigation) {
      shortcuts[const SingleActivator(LogicalKeyboardKey.arrowUp)] = () {
        KeyboardNavigationService().moveFocus(context, TraversalDirection.up);
      };
      shortcuts[const SingleActivator(LogicalKeyboardKey.arrowDown)] = () {
        KeyboardNavigationService().moveFocus(context, TraversalDirection.down);
      };
      shortcuts[const SingleActivator(LogicalKeyboardKey.arrowLeft)] = () {
        KeyboardNavigationService().moveFocus(context, TraversalDirection.left);
      };
      shortcuts[const SingleActivator(LogicalKeyboardKey.arrowRight)] = () {
        KeyboardNavigationService().moveFocus(context, TraversalDirection.right);
      };
    }

    if (enableEscapeToClose) {
      shortcuts[const SingleActivator(LogicalKeyboardKey.escape)] = () {
        if (onEscape != null) {
          onEscape!();
        } else {
          Navigator.of(context).maybePop();
        }
      };
    }

    // Common iOS shortcuts
    shortcuts[const SingleActivator(LogicalKeyboardKey.enter)] = () {
      // Activate focused element
      final primaryFocus = FocusManager.instance.primaryFocus;
      if (primaryFocus != null && primaryFocus.context != null) {
        Actions.invoke(primaryFocus.context!, const ActivateIntent());
      }
    };

    shortcuts[const SingleActivator(LogicalKeyboardKey.space)] = () {
      // Also activate focused element (for buttons)
      final primaryFocus = FocusManager.instance.primaryFocus;
      if (primaryFocus != null && primaryFocus.context != null) {
        Actions.invoke(primaryFocus.context!, const ActivateIntent());
      }
    };

    return KeyboardShortcutHandler(
      shortcuts: shortcuts,
      child: child,
    );
  }
}

// Focusable widget wrapper
class FocusableWidget extends StatefulWidget {
  final Widget child;
  final String? focusId;
  final VoidCallback? onFocus;
  final VoidCallback? onUnfocus;
  final VoidCallback? onActivate;
  final bool autofocus;
  final bool canRequestFocus;
  final FocusNode? focusNode;
  final Color? focusColor;
  final double focusBorderWidth;

  const FocusableWidget({
    Key? key,
    required this.child,
    this.focusId,
    this.onFocus,
    this.onUnfocus,
    this.onActivate,
    this.autofocus = false,
    this.canRequestFocus = true,
    this.focusNode,
    this.focusColor,
    this.focusBorderWidth = 2.0,
  }) : super(key: key);

  @override
  State<FocusableWidget> createState() => _FocusableWidgetState();
}

class _FocusableWidgetState extends State<FocusableWidget> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    
    if (widget.focusId != null) {
      KeyboardNavigationService().registerFocusNode(widget.focusId!, _focusNode);
    }

    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_focusNode.hasFocus) {
      widget.onFocus?.call();
    } else {
      widget.onUnfocus?.call();
    }
  }

  @override
  void dispose() {
    if (widget.focusId != null) {
      KeyboardNavigationService().unregisterFocusNode(widget.focusId!);
    }
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      canRequestFocus: widget.canRequestFocus,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            widget.onActivate?.call();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        decoration: _isFocused
            ? BoxDecoration(
                border: Border.all(
                  color: widget.focusColor ?? CupertinoColors.activeBlue,
                  width: widget.focusBorderWidth,
                ),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: widget.child,
      ),
    );
  }
}

// Keyboard navigation helper for lists
class KeyboardNavigableList extends StatefulWidget {
  final List<Widget> children;
  final Axis scrollDirection;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;

  const KeyboardNavigableList({
    Key? key,
    required this.children,
    this.scrollDirection = Axis.vertical,
    this.scrollController,
    this.padding,
  }) : super(key: key);

  @override
  State<KeyboardNavigableList> createState() => _KeyboardNavigableListState();
}

class _KeyboardNavigableListState extends State<KeyboardNavigableList> {
  late ScrollController _scrollController;
  int _focusedIndex = 0;
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    
    // Create focus nodes for each child
    for (int i = 0; i < widget.children.length; i++) {
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _moveFocus(int newIndex) {
    if (newIndex >= 0 && newIndex < widget.children.length) {
      setState(() {
        _focusedIndex = newIndex;
      });
      _focusNodes[newIndex].requestFocus();
      _ensureVisible(newIndex);
    }
  }

  void _ensureVisible(int index) {
    // Calculate position and scroll if needed
    final itemHeight = 60.0; // Approximate item height
    final position = index * itemHeight;
    
    if (position < _scrollController.offset) {
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else if (position > _scrollController.offset + _scrollController.position.viewportDimension - itemHeight) {
      _scrollController.animateTo(
        position - _scrollController.position.viewportDimension + itemHeight,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          if (widget.scrollDirection == Axis.vertical) {
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _moveFocus(_focusedIndex + 1);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _moveFocus(_focusedIndex - 1);
            }
          } else {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _moveFocus(_focusedIndex + 1);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _moveFocus(_focusedIndex - 1);
            }
          }
        }
      },
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: widget.scrollDirection,
        padding: widget.padding,
        itemCount: widget.children.length,
        itemBuilder: (context, index) {
          return Focus(
            focusNode: _focusNodes[index],
            child: widget.children[index],
          );
        },
      ),
    );
  }
}