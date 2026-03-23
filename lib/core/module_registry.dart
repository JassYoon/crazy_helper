import 'package:flutter/foundation.dart';
import '../models/app_module.dart';

class ModuleRegistry extends ChangeNotifier {
  final List<String> _menuModuleIds = [];

  List<String> get menuModuleIds => List.unmodifiable(_menuModuleIds);

  List<AppModule> get menuModules {
    return _menuModuleIds
        .map((id) => allModules.firstWhere((m) => m.id == id))
        .toList();
  }

  bool isInMenu(String moduleId) => _menuModuleIds.contains(moduleId);

  void addToMenu(String moduleId) {
    if (!_menuModuleIds.contains(moduleId)) {
      _menuModuleIds.add(moduleId);
      notifyListeners();
    }
  }

  void removeFromMenu(String moduleId) {
    if (_menuModuleIds.remove(moduleId)) {
      notifyListeners();
    }
  }
}
