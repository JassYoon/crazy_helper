import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(420, 680),
    minimumSize: Size(56, 56),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.normal,
    title: '제정신 지킴이',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const CrazyHelperApp());
}
