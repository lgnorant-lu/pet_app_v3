# Pet App V3 API Documentation

## 概述
Pet App V3 完整API文档，涵盖应用生命周期、模块通信、UI框架、导航系统和用户界面组件。

## Phase 4 用户界面API

### 首页仪表板 (Phase 4.1)

#### HomeProvider
```dart
class HomeProvider extends StateNotifier<HomeData> {
  Future<void> refresh();
  void updateModuleStatus(String moduleId, ModuleStatus status);
  void addRecentProject(String projectName);
  void unlockAchievement(String achievementId);
}

// 使用方式
final homeData = ref.watch(homeProvider);
final homeNotifier = ref.read(homeProvider.notifier);
```

#### HomeData
```dart
class HomeData {
  final List<ModuleInfo> modules;
  final Map<String, dynamic> userStats;
  final List<String> recentProjects;
  final List<String> achievements;
  final bool isLoading;

  HomeData copyWith({...});
}
```

#### ModuleInfo
```dart
class ModuleInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final ModuleStatus status;
  final String route;

  ModuleInfo copyWith({...});
}
```

### 设置系统 (Phase 4.2)

#### SettingsProvider
```dart
class SettingsProvider extends StateNotifier<SettingsData> {
  Future<void> updateGeneralSettings(GeneralSettings settings);
  Future<void> updateAppearanceSettings(AppearanceSettings settings);
  Future<void> updateNotificationSettings(NotificationSettings settings);
  Future<void> updatePrivacySettings(PrivacySettings settings);
  Future<void> updateAdvancedSettings(AdvancedSettings settings);
  Future<void> resetToDefaults();
  Future<void> exportSettings();
  Future<void> importSettings(Map<String, dynamic> data);
}
```

#### SettingsData
```dart
class SettingsData {
  final GeneralSettings general;
  final AppearanceSettings appearance;
  final NotificationSettings notifications;
  final PrivacySettings privacy;
  final AdvancedSettings advanced;

  SettingsData copyWith({...});
}
```

#### GeneralSettings
```dart
class GeneralSettings {
  final String language;
  final String region;
  final bool autoSave;
  final bool startOnBoot;
  final bool checkUpdates;

  GeneralSettings copyWith({...});
}
```

## Phase 3 核心API

### 应用生命周期管理 (Phase 3.1)

#### AppLifecycleManager
```dart
class AppLifecycleManager {
  static AppLifecycleManager get instance;
  Future<void> initialize();
  Future<void> startApplication();
  Future<void> pauseApplication();
  Future<void> resumeApplication();
  Future<void> stopApplication();
  AppLifecycleState get currentState;
  Stream<AppLifecycleState> get stateStream;
}
```

#### StateManager
```dart
class StateManager {
  static StateManager get instance;
  Future<void> saveState(String key, dynamic value);
  Future<T?> loadState<T>(String key);
  Future<void> clearState(String key);
  Future<void> clearAllStates();
}
```

#### ModuleLoader
```dart
class ModuleLoader {
  static ModuleLoader get instance;
  Future<void> loadModule(String moduleId);
  Future<void> unloadModule(String moduleId);
  bool isModuleLoaded(String moduleId);
  List<String> get loadedModules;
}
```

### 模块间通信协调 (Phase 3.2)

#### UnifiedMessageBus
```dart
class UnifiedMessageBus {
  static UnifiedMessageBus get instance;
  MessageSubscription subscribe(MessageHandler handler, {MessageFilter? filter});
  Future<UnifiedMessage?> publishEvent(String sender, String action, Map<String, dynamic> data);
  Future<UnifiedMessage?> sendRequest(String sender, String action, Map<String, dynamic> data);
  void dispose();
}
```

#### EventRoutingRule
```dart
class EventRoutingRule {
  EventRoutingRule({
    required String id,
    required String targetModule,
    MessageFilter? filter,
    int priority = 0,
  });
  bool matches(UnifiedMessage message);
}
```

#### DataSyncManager
```dart
class DataSyncManager {
  static DataSyncManager get instance;
  Future<void> syncData(String dataType, dynamic data, {SyncStrategy? strategy});
  Future<void> registerSyncConfig(SyncConfig config);
  Stream<DataChange> get changeStream;
}
```

### 基础UI集成 (Phase 3.3)

#### MainAppFramework
```dart
class MainAppFramework extends StatefulWidget {
  const MainAppFramework({
    Key? key,
    required this.initialModule,
    this.statusBarConfig,
    this.quickActionConfig,
  });
}
```

#### NavigationManager
```dart
class NavigationManager {
  static NavigationManager get instance;
  Future<void> navigateTo(String route, {Map<String, dynamic>? parameters});
  Future<void> navigateBack();
  Future<void> navigateForward();
  void registerRoute(String route, RouteBuilder builder);
  String? get currentRoute;
}
```

#### KeyboardShortcutManager
```dart
class KeyboardShortcutManager {
  static KeyboardShortcutManager get instance;
  void registerShortcut(ShortcutEntry shortcut);
  void unregisterShortcut(String shortcutId);
  Future<bool> handleKeyDown(LogicalKeyboardKey key);
  void setEnabled(bool enabled);
}
```

#### AccessibilityNavigationManager
```dart
class AccessibilityNavigationManager {
  static AccessibilityNavigationManager get instance;
  void enableFeature(AccessibilityFeature feature);
  void announceNavigation(NavigationHint hint);
  void nextFocus();
  void previousFocus();
  void setFontScale(double scale);
}
```

## 插件系统API (Phase 1-2)

### PluginInterface
基础插件接口，所有插件必须实现。

### PluginRegistry
插件注册中心，管理插件的注册和发现。

### CreativeWorkshopPlugin
创意工坊插件基类。

## 使用示例

### 应用启动
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化应用生命周期
  await AppLifecycleManager.instance.initialize();
  
  // 启动应用
  await AppLifecycleManager.instance.startApplication();
  
  runApp(const MainAppFramework(initialModule: 'home'));
}
```

### 模块通信
```dart
// 发送事件
UnifiedMessageBus.instance.publishEvent(
  'workshop_module',
  'project_created',
  {'projectId': 'proj_123', 'name': 'My Project'},
);

// 订阅事件
final subscription = UnifiedMessageBus.instance.subscribe(
  (message) async {
    print('Received: ${message.action}');
    return null;
  },
  filter: (message) => message.action == 'project_created',
);
```

### 导航操作
```dart
// 导航到指定页面
await NavigationManager.instance.navigateTo(
  '/workshop',
  parameters: {'mode': 'edit', 'projectId': 'proj_123'},
);

// 注册快捷键
KeyboardShortcutManager.instance.registerShortcut(
  ShortcutEntry(
    id: 'go_home',
    combination: ShortcutCombination.simple(
      key: LogicalKeyboardKey.keyH,
      ctrl: true,
    ),
    action: () async {
      await NavigationManager.instance.navigateTo('/');
      return true;
    },
  ),
);
```

## 版本历史
- v2.9.3: 完善插件系统和创意工坊功能
- v3.1.0: 实现应用生命周期管理
- v3.2.0: 实现模块间通信协调
- v3.3.0: 实现基础UI集成和导航系统
