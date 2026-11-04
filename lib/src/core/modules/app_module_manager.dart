import 'package:gestao_financeira/src/core/modules/app_module.dart';
import 'package:go_router/go_router.dart';

class AppModuleManager {
  AppModuleManager({required List<AppModule> modules})
    : _modules = List.unmodifiable(modules);

  final List<AppModule> _modules;
  bool _initialized = false;

  List<RouteBase> get routes => [
    for (final module in _modules) ...module.routes,
  ];

  Future<void> initialize() async {
    if (_initialized) {
      throw StateError('Os módulos já foram inicializados.');
    }

    _validateUniqueNames();
    for (final module in _modules) {
      await module.registerDependencies();
    }
    for (final module in _modules) {
      await module.initialize();
    }
    _initialized = true;
  }

  void _validateUniqueNames() {
    final names = <String>{};
    for (final module in _modules) {
      if (!names.add(module.name)) {
        throw StateError('Nome de módulo duplicado: ${module.name}');
      }
    }
  }

  Future<void> dispose() async {
    for (final module in _modules.reversed) {
      await module.dispose();
    }
    _initialized = false;
  }
}
