import 'package:gestao_financeira/src/core/modules/app_module.dart';
import 'package:gestao_financeira/src/modules/home/presentation/view/home_view.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final class HomeModule extends BaseAppModule {
  HomeModule(this.injector);
  final GetIt injector;

  @override
  String get name => 'home';

  @override
  void registerDependencies() {}

  @override
  List<RouteBase> get routes => [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeView(),
        ),
      ];
}