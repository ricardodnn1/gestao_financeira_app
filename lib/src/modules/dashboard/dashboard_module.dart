import 'package:gestao_financeira/src/core/modules/app_module.dart';
import 'package:gestao_financeira/src/modules/dashboard/presentation/view/dashboard_page.dart';
import 'package:go_router/go_router.dart';

final class DashboardModule extends BaseAppModule {
  @override
  String get name => 'dashboard';

  @override
  List<RouteBase> get routes => [
    GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
  ];
}
