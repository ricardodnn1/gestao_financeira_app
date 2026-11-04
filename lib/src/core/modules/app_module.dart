import 'package:go_router/go_router.dart';

abstract interface class AppModule {
  String get name;

  Future<void> registerDependencies();

  List<RouteBase> get routes;

  Future<void> initialize();

  Future<void> dispose();
}

abstract base class BaseAppModule implements AppModule {
  @override
  Future<void> registerDependencies() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}
}
