# AssetWorks - Refactored Project Structure

## 📁 Architecture Overview

The application follows a **Clean Architecture** pattern with **GetX** state management, organized into modular features for better maintainability and scalability.

```
lib/
├── app/                    # Application Layer
│   ├── config/            # App Configuration
│   │   ├── app_config.dart
│   │   ├── app_bindings.dart
│   │   ├── app_routes.dart
│   │   └── app_theme.dart
│   │
│   ├── modules/           # Feature Modules (MVVM pattern)
│   │   ├── auth/
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   ├── views/
│   │   │   └── widgets/
│   │   │
│   │   ├── dashboard/
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   ├── views/
│   │   │   └── widgets/
│   │   │
│   │   ├── widgets/       # Widget Creation Module
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   ├── views/
│   │   │   └── widgets/
│   │   │
│   │   └── [other_modules]/
│   │
│   └── shared/            # Shared Components
│       ├── components/    # Reusable UI components
│       ├── utils/        # Utility functions
│       └── extensions/   # Dart extensions
│
├── data/                  # Data Layer
│   ├── models/           # Data Models
│   ├── providers/        # API/Database Providers
│   ├── repositories/     # Repository Pattern
│   └── services/         # Business Services
│
├── domain/               # Domain Layer (Optional)
│   ├── entities/        # Business Entities
│   ├── repositories/    # Repository Interfaces
│   └── use_cases/       # Business Use Cases
│
└── main.dart            # Application Entry Point
```

## 🏗️ Key Design Principles

### 1. **Separation of Concerns**
- Each module is self-contained with its own MVC/MVVM structure
- Clear separation between UI, Business Logic, and Data

### 2. **Dependency Injection**
- All dependencies managed through GetX bindings
- Lazy loading for better performance
- Singleton services for app-wide features

### 3. **State Management**
- GetX reactive state management
- Observable variables with `.obs`
- Controllers extend `GetxController`

### 4. **Routing**
- Centralized route management
- Named routes for navigation
- Route-specific bindings

## 📦 Module Structure

Each feature module follows this structure:

```
module_name/
├── bindings/
│   └── module_binding.dart    # Dependency injection
├── controllers/
│   └── module_controller.dart # Business logic & state
├── views/
│   └── module_view.dart      # Main UI screen
├── widgets/
│   └── custom_widgets.dart   # Module-specific widgets
└── models/                   # Module-specific models (optional)
```

## 🔄 Data Flow

```
View → Controller → Repository → Service/Provider → API/Database
     ←            ←            ←                  ←
```

## 🎯 Benefits

1. **Scalability**: Easy to add new features without affecting existing code
2. **Testability**: Each layer can be tested independently
3. **Maintainability**: Clear structure makes code easy to understand
4. **Reusability**: Shared components and services
5. **Performance**: Lazy loading and proper state management

## 📝 Coding Standards

### File Naming
- Use `snake_case` for file names
- Suffix with type: `_view.dart`, `_controller.dart`, `_binding.dart`

### Class Naming
- Use `PascalCase` for classes
- Controllers end with `Controller`
- Views end with `View`
- Bindings end with `Binding`

### Variable Naming
- Use `camelCase` for variables
- Prefix private variables with `_`
- Use descriptive names

### GetX Conventions
- Observable variables: `final RxType variable = initialValue.obs`
- Controllers: `extends GetxController`
- Views: `extends GetView<ControllerType>`

## 🚀 Quick Start

1. **Creating a New Module**
```bash
# Create folder structure
mkdir -p lib/app/modules/new_feature/{bindings,controllers,views,widgets}
```

2. **Add Route**
```dart
// In app_routes.dart
static const String newFeature = '/new-feature';

GetPage(
  name: newFeature,
  page: () => const NewFeatureView(),
  binding: NewFeatureBinding(),
),
```

3. **Create Controller**
```dart
class NewFeatureController extends GetxController {
  // Add your state and logic
}
```

4. **Create View**
```dart
class NewFeatureView extends GetView<NewFeatureController> {
  // Build your UI
}
```

5. **Create Binding**
```dart
class NewFeatureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewFeatureController>(() => NewFeatureController());
  }
}
```

## 🔧 Utilities

### API Service
- Centralized API handling
- Error handling
- Request/Response interceptors

### Storage Service
- Local storage management
- Secure storage for sensitive data
- Cache management

### Theme Controller
- Dynamic theme switching
- Persistent theme preference
- System theme detection

## 📱 Features Implemented

✅ **Dashboard with Tabs**
- My Analysis tab
- Saved Analysis tab
- Real-time data updates

✅ **Widget Creation**
- AI-powered widget generation
- 30+ templates per category
- Multiple AI providers

✅ **Theme Support**
- Light/Dark mode
- iOS-native design
- Smooth transitions

✅ **Navigation**
- Bottom tab navigation
- Named routing
- Deep linking support

## 🔐 Security

- API token management
- Secure storage for credentials
- Input validation
- Error handling

## 📊 Performance Optimizations

- Lazy loading of modules
- Image caching
- API response caching
- Debounced search
- Virtual scrolling for large lists

## 🧪 Testing Strategy

```
test/
├── unit/           # Unit tests
├── widget/         # Widget tests
├── integration/    # Integration tests
└── fixtures/       # Test data
```

## 📚 Dependencies

Key packages used:
- `get`: State management & navigation
- `dio`: HTTP client
- `get_storage`: Local storage
- `flutter_dotenv`: Environment variables
- `cached_network_image`: Image caching

## 🎨 Design System

- iOS-native components
- Consistent spacing (8, 16, 24, 32)
- Consistent border radius (12px)
- Color palette from CupertinoColors
- SF Pro font family

---

This refactored structure ensures the app is:
- **Maintainable**: Clear organization and separation
- **Scalable**: Easy to add new features
- **Testable**: Each component can be tested in isolation
- **Performant**: Optimized loading and state management
- **Professional**: Following industry best practices