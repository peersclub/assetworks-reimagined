import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DynamicTypeService {
  static final DynamicTypeService _instance = DynamicTypeService._internal();
  factory DynamicTypeService() => _instance;
  DynamicTypeService._internal();

  // iOS Dynamic Type categories mapped to scale factors
  static const Map<String, double> _textScaleFactors = {
    'xSmall': 0.8,
    'Small': 0.85,
    'Medium': 1.0,
    'Large': 1.1,
    'xLarge': 1.2,
    'xxLarge': 1.35,
    'xxxLarge': 1.5,
    // Accessibility sizes
    'AX1': 1.6,
    'AX2': 1.9,
    'AX3': 2.35,
    'AX4': 2.75,
    'AX5': 3.1,
  };

  // Get current text scale factor
  double getTextScaleFactor(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.textScaleFactor.clamp(0.8, 3.1);
  }

  // Get adjusted font size based on Dynamic Type
  double getScaledFontSize(BuildContext context, double baseSize) {
    final scaleFactor = getTextScaleFactor(context);
    return baseSize * scaleFactor;
  }

  // iOS text styles with Dynamic Type support
  TextStyle getLargeTitle(BuildContext context) {
    return TextStyle(
      fontSize: getScaledFontSize(context, 34),
      fontWeight: FontWeight.bold,
      letterSpacing: 0.41,
    );
  }

  TextStyle getTitle1(BuildContext context) {
    return TextStyle(
      fontSize: getScaledFontSize(context, 28),
      fontWeight: FontWeight.w400,
      letterSpacing: 0.36,
    );
  }

  TextStyle getTitle2(BuildContext context) {
    return TextStyle(
      fontSize: getScaledFontSize(context, 22),
      fontWeight: FontWeight.w400,
      letterSpacing: 0.35,
    );
  }

  TextStyle getTitle3(BuildContext context) {
    return TextStyle(
      fontSize: getScaledFontSize(context, 20),
      fontWeight: FontWeight.w400,
      letterSpacing: 0.38,
    );
  }

  TextStyle getHeadline(BuildContext context) {
    return TextStyle(
      fontSize: getScaledFontSize(context, 17),
      fontWeight: FontWeight.w600,
      letterSpacing: -0.41,
    );
  }

  TextStyle getBody(BuildContext context) {
    return TextStyle(
      fontSize: getScaledFontSize(context, 17),
      fontWeight: FontWeight.w400,
      letterSpacing: -0.41,
    );
  }

  TextStyle getCallout(BuildContext context) {
    return TextStyle(
      fontSize: getScaledFontSize(context, 16),
      fontWeight: FontWeight.w400,
      letterSpacing: -0.32,
    );
  }

  TextStyle getSubheadline(BuildContext context) {
    return TextStyle(
      fontSize: getScaledFontSize(context, 15),
      fontWeight: FontWeight.w400,
      letterSpacing: -0.24,
    );
  }

  TextStyle getFootnote(BuildContext context) {
    return TextStyle(
      fontSize: getScaledFontSize(context, 13),
      fontWeight: FontWeight.w400,
      letterSpacing: -0.08,
    );
  }

  TextStyle getCaption1(BuildContext context) {
    return TextStyle(
      fontSize: getScaledFontSize(context, 12),
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    );
  }

  TextStyle getCaption2(BuildContext context) {
    return TextStyle(
      fontSize: getScaledFontSize(context, 11),
      fontWeight: FontWeight.w400,
      letterSpacing: 0.07,
    );
  }

  // Get appropriate icon size based on text scale
  double getIconSize(BuildContext context, {double baseSize = 24}) {
    final scaleFactor = getTextScaleFactor(context);
    if (scaleFactor > 2.0) {
      return baseSize * 1.5; // Cap icon scaling at 1.5x
    }
    return baseSize * scaleFactor.clamp(0.8, 1.5);
  }

  // Get appropriate spacing based on text scale
  double getSpacing(BuildContext context, double baseSpacing) {
    final scaleFactor = getTextScaleFactor(context);
    if (scaleFactor > 1.5) {
      return baseSpacing * 1.2; // Increase spacing for larger text
    }
    return baseSpacing;
  }

  // Check if using accessibility sizes
  bool isUsingAccessibilitySize(BuildContext context) {
    final scaleFactor = getTextScaleFactor(context);
    return scaleFactor > 1.5;
  }

  // Get line height multiplier
  double getLineHeightMultiplier(BuildContext context) {
    final scaleFactor = getTextScaleFactor(context);
    if (scaleFactor > 2.0) {
      return 1.5; // Increased line height for very large text
    } else if (scaleFactor > 1.5) {
      return 1.3;
    }
    return 1.2;
  }

  // Create responsive container constraints
  BoxConstraints getResponsiveConstraints(BuildContext context, {
    double? maxWidth,
    double? maxHeight,
  }) {
    final scaleFactor = getTextScaleFactor(context);
    
    return BoxConstraints(
      maxWidth: maxWidth ?? double.infinity,
      maxHeight: maxHeight != null && scaleFactor > 1.5 
        ? maxHeight * scaleFactor.clamp(1.0, 1.5)
        : maxHeight ?? double.infinity,
    );
  }
}

// Dynamic Type aware text widget
class DynamicText extends StatelessWidget {
  final String text;
  final TextStyle Function(BuildContext)? styleBuilder;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;
  
  const DynamicText(
    this.text, {
    Key? key,
    this.styleBuilder,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : super(key: key);
  
  // Convenience constructors for iOS text styles
  DynamicText.largeTitle(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : styleBuilder = ((context) => DynamicTypeService().getLargeTitle(context)),
       super(key: key);
  
  DynamicText.title1(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : styleBuilder = ((context) => DynamicTypeService().getTitle1(context)),
       super(key: key);
  
  DynamicText.title2(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : styleBuilder = ((context) => DynamicTypeService().getTitle2(context)),
       super(key: key);
  
  DynamicText.title3(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : styleBuilder = ((context) => DynamicTypeService().getTitle3(context)),
       super(key: key);
  
  DynamicText.headline(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : styleBuilder = ((context) => DynamicTypeService().getHeadline(context)),
       super(key: key);
  
  DynamicText.body(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : styleBuilder = ((context) => DynamicTypeService().getBody(context)),
       super(key: key);
  
  DynamicText.callout(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : styleBuilder = ((context) => DynamicTypeService().getCallout(context)),
       super(key: key);
  
  DynamicText.subheadline(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : styleBuilder = ((context) => DynamicTypeService().getSubheadline(context)),
       super(key: key);
  
  DynamicText.footnote(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : styleBuilder = ((context) => DynamicTypeService().getFootnote(context)),
       super(key: key);
  
  DynamicText.caption1(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : styleBuilder = ((context) => DynamicTypeService().getCaption1(context)),
       super(key: key);
  
  DynamicText.caption2(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : styleBuilder = ((context) => DynamicTypeService().getCaption2(context)),
       super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final style = styleBuilder?.call(context) ?? DynamicTypeService().getBody(context);
    
    return Semantics(
      label: semanticsLabel ?? text,
      excludeSemantics: semanticsLabel != null,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

// Dynamic Type aware icon widget
class DynamicIcon extends StatelessWidget {
  final IconData icon;
  final double? baseSize;
  final Color? color;
  final String? semanticLabel;
  
  const DynamicIcon(
    this.icon, {
    Key? key,
    this.baseSize,
    this.color,
    this.semanticLabel,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final size = DynamicTypeService().getIconSize(
      context,
      baseSize: baseSize ?? 24,
    );
    
    return Semantics(
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: Icon(
        icon,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      ),
    );
  }
}