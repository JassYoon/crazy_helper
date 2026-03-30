import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme.dart';
import 'core/module_registry.dart';
import 'screens/home_screen.dart';
import 'widgets/floating_widget.dart';

enum AppMode { home, widget }

class CrazyHelperApp extends StatefulWidget {
  const CrazyHelperApp({super.key});

  @override
  State<CrazyHelperApp> createState() => _CrazyHelperAppState();
}

class _CrazyHelperAppState extends State<CrazyHelperApp> with WindowListener {
  AppMode _mode = AppMode.home;
  final ModuleRegistry _registry = ModuleRegistry();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _setupHomeWindow();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _registry.dispose();
    super.dispose();
  }

  Future<void> _setupHomeWindow() async {
    await windowManager.setSize(const Size(420, 680));
    await windowManager.center();
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.show();
  }

  Future<void> _switchToWidgetMode() async {
    setState(() => _mode = AppMode.widget);
    await windowManager.setSize(
      const Size(AppFloatingChrome.widgetSize, AppFloatingChrome.widgetSize),
    );
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setSkipTaskbar(true);
    await windowManager.setBackgroundColor(Colors.transparent);
  }

  Future<void> _switchToHomeMode() async {
    setState(() => _mode = AppMode.home);
    await _setupHomeWindow();
  }

  @override
  void onWindowClose() async {
    if (_mode == AppMode.home) {
      // Instead of closing, switch to widget mode
      await _switchToWidgetMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '제정신 지킴이',
      debugShowCheckedModeBanner: false,
      theme: _mode == AppMode.widget
          ? appTheme().copyWith(
              scaffoldBackgroundColor: Colors.transparent,
            )
          : appTheme(),
      builder: (context, child) {
        if (_mode == AppMode.widget) {
          return ColoredBox(
            color: Colors.transparent,
            child: child,
          );
        }
        return child ?? const SizedBox.shrink();
      },
      home: _mode == AppMode.home
          ? HomeScreen(
              onModuleDragToMenu: (moduleId) {
                _registry.addToMenu(moduleId);
              },
              onSwitchToWidget: _switchToWidgetMode,
            )
          : FloatingWidgetScreen(
              registry: _registry,
              onOpenHome: _switchToHomeMode,
            ),
    );
  }
}
