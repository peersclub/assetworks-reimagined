# Mobile App Design Libraries for Claude Code

## 🎨 Flutter Design Libraries (Currently Using)

### 1. **Material Design 3 (Material You)** ✅ Already Installed
```yaml
dependencies:
  flutter:
    sdk: flutter
```
- Built into Flutter
- Google's design system
- Adaptive components
- Dynamic theming

### 2. **Cupertino (iOS Design)** ✅ Already Installed
```yaml
import 'package:flutter/cupertino.dart';
```
- Apple's design language
- iOS-native look and feel
- Platform-adaptive widgets

### 3. **Flutter Awesome UI Libraries**

#### 📦 Complete UI Kits

**GetWidget** - 1000+ pre-built widgets
```bash
flutter pub add getwidget
```
```dart
import 'package:getwidget/getwidget.dart';

// Example usage
GFButton(
  onPressed: () {},
  text: "Primary Button",
  icon: Icon(Icons.share),
  shape: GFButtonShape.pills,
)
```

**Flutter UI Kit**
```bash
flutter pub add flutter_ui_kit
```

**Velocity X** - Tailwind-inspired
```bash
flutter pub add velocity_x
```
```dart
"Hello".text.xl4.bold.red600.make()
Box().height(100).width(100).rounded.red500.make()
```

#### 🎯 Specialized Components

**Animations & Effects**
```bash
# Lottie animations
flutter pub add lottie

# Rive animations
flutter pub add rive

# Shimmer effects (already have)
flutter pub add shimmer

# Animated text
flutter pub add animated_text_kit
```

**Charts & Data Viz**
```bash
# FL Chart - Beautiful charts
flutter pub add fl_chart

# Syncfusion charts
flutter pub add syncfusion_flutter_charts

# Charts Flutter
flutter pub add charts_flutter
```

**Modern UI Components**
```bash
# Glass morphism
flutter pub add glass_kit

# Neumorphic design
flutter pub add flutter_neumorphic

# Liquid swipe
flutter pub add liquid_swipe

# Flutter Staggered Grid
flutter pub add flutter_staggered_grid_view
```

### 4. **Icon Libraries** 

```bash
# Already installed
flutter pub add lucide_icons  ✅
flutter pub add font_awesome_flutter  ✅

# Additional options
flutter pub add fluentui_system_icons
flutter pub add ionicons
flutter pub add eva_icons_flutter
flutter pub add feather_icons
flutter pub add material_design_icons_flutter
```

### 5. **Design System Templates**

**Flutter Native Splash** - Splash screens
```bash
flutter pub add flutter_native_splash
```

**Flutter Launcher Icons** - App icons
```bash
flutter pub add flutter_launcher_icons
```

**Onboarding Screens**
```bash
flutter pub add introduction_screen
flutter pub add smooth_page_indicator
```

## 🚀 Quick Installation Guide

### Install a Complete UI Kit:
```bash
# For a comprehensive solution
flutter pub add getwidget
flutter pub add velocity_x
flutter pub add glass_kit
flutter pub add fl_chart
flutter pub add lottie
```

### Add to pubspec.yaml:
```yaml
dependencies:
  # UI Libraries
  getwidget: ^4.0.0
  velocity_x: ^4.1.1
  glass_kit: ^3.0.0
  
  # Animations
  lottie: ^3.1.0
  animated_text_kit: ^4.2.2
  
  # Charts
  fl_chart: ^0.66.0
  
  # Effects
  flutter_neumorphic: ^3.2.0
  shimmer: ^3.0.0
  
  # Icons (already have)
  lucide_icons: ^0.435.0
  font_awesome_flutter: ^10.7.0
```

## 📱 Platform-Specific Libraries

### iOS-Specific Design
```dart
import 'package:flutter/cupertino.dart';

CupertinoPageScaffold(
  navigationBar: CupertinoNavigationBar(
    middle: Text('iOS Style'),
  ),
  child: CupertinoButton(
    child: Text('iOS Button'),
    onPressed: () {},
  ),
)
```

### Android Material You
```dart
import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
```

## 🎯 For AssetWorks Mobile

Based on your current app, I recommend:

### 1. **Keep Current Setup** ✅
- Material Design 3
- Lucide Icons
- Custom widgets

### 2. **Add for Enhancement**:
```bash
# Beautiful charts for financial data
flutter pub add fl_chart

# Smooth animations
flutter pub add lottie
flutter pub add animated_text_kit

# Glass morphism for premium feel
flutter pub add glass_kit

# Better grids for discovery
flutter pub add flutter_staggered_grid_view
```

### 3. **Example Implementation**:

**Glass Card for Widgets**:
```dart
import 'package:glass_kit/glass_kit.dart';

GlassContainer(
  height: 200,
  width: 350,
  gradient: LinearGradient(
    colors: [
      Colors.white.withOpacity(0.40),
      Colors.white.withOpacity(0.10)
    ],
  ),
  borderGradient: LinearGradient(
    colors: [
      Colors.white.withOpacity(0.60),
      Colors.white.withOpacity(0.0)
    ],
  ),
  blur: 15,
  borderRadius: BorderRadius.circular(20),
  child: Center(
    child: Text('Premium Widget'),
  ),
)
```

**Animated Chart**:
```dart
import 'package:fl_chart/fl_chart.dart';

LineChart(
  LineChartData(
    gridData: FlGridData(show: false),
    titlesData: FlTitlesData(show: false),
    borderData: FlBorderData(show: false),
    lineBarsData: [
      LineChartBarData(
        spots: [
          FlSpot(0, 3),
          FlSpot(1, 1),
          FlSpot(2, 4),
          FlSpot(3, 2),
        ],
        isCurved: true,
        colors: [Colors.blue],
        barWidth: 3,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          colors: [Colors.blue.withOpacity(0.3)],
        ),
      ),
    ],
  ),
)
```

## 🛠 React Native Libraries (Alternative)

If using React Native:
```bash
# NativeBase
npm install native-base

# React Native Elements
npm install react-native-elements

# React Native Paper (Material Design)
npm install react-native-paper

# React Native UI Kitten
npm install @ui-kitten/components

# Shoutem UI
npm install @shoutem/ui
```

## 📚 Design Resources

### Figma UI Kits:
- [Flutter Material 3 Kit](https://www.figma.com/community/file/1035203688168086460)
- [iOS 17 UI Kit](https://www.figma.com/community/file/1248375255495415511)
- [Flutter Components](https://www.figma.com/community/file/1121065701252736567)

### Online Builders:
- [FlutterFlow](https://flutterflow.io) - Visual builder
- [BuilderX](https://builderx.io) - Design to code
- [Supernova](https://supernova.io) - Design system management

## ✨ Quick Start Commands

```bash
# Install recommended libraries for AssetWorks
flutter pub add fl_chart
flutter pub add lottie
flutter pub add glass_kit
flutter pub add animated_text_kit
flutter pub add flutter_staggered_grid_view

# Get all dependencies
flutter pub get

# Run the app
flutter run
```

## 🎨 Color Palette Generators
- [Coolors.co](https://coolors.co)
- [Material Theme Builder](https://m3.material.io/theme-builder)
- [ColorHunt](https://colorhunt.co)

These libraries will give you professional, polished UI components that work seamlessly with Claude Code!