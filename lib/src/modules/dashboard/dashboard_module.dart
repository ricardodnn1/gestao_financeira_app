import 'package:gestao_financeira/src/core/modules/app_module.dart';
import 'package:gestao_financeira/src/modules/dashboard/presentation/view/dashboard_view.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final class DashboardModule extends BaseAppModule {
  DashboardModule(this.injector);
  final GetIt injector;

  @override
  String get name => 'dashboard';

  @override
  void registerDependencies() {}

  @override
  List<RouteBase> get routes => [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardView(),
        ),
      ];
}