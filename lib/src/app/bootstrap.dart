import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestao_financeira/src/app/app.dart';
import 'package:gestao_financeira/src/core/modules/app_module_manager.dart';
import 'package:gestao_financeira/src/core/network/http_client.dart';
import 'package:gestao_financeira/src/core/network/http_client_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class AppBootstrap {
  final GetIt _injector = GetIt.instance;

  late final AppModuleManager _moduleManager;

  Future<GoRouter> initialize() async {
    _registerCoreDependencies();

    _moduleManager = AppModuleManager(
      modules: [
        
      ],
    );

    await _moduleManager.initialize();
    return GoRouter(
      initialLocation: '/',
      routes: _moduleManager.routes,
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Navegação')),
        body: Center(child: Text('Rota não encontrada: ${state.uri}')),
      ),
    );
  }

  void _registerCoreDependencies() {
    if (!_injector.isRegistered<AppHttpClient>()) {
      _injector.registerLazySingleton<AppHttpClient>(
        () => HttpClientImpl(),
      );
    }
  }
 
  Widget buildApp(GoRouter router) {
    return ProviderScope(
      child: ModularExampleApp(router: router),
    );
  }

  Future<void> dispose() async {
    await _moduleManager.dispose();
    await _injector.reset();
  }
}
