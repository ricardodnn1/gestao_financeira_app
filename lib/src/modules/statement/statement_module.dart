import 'package:gestao_financeira/src/core/modules/app_module.dart';
import 'package:gestao_financeira/src/core/routes/app_router.dart';
import 'package:gestao_financeira/src/modules/statement/presentation/statement/view/statement_page.dart';
import 'package:gestao_financeira/src/modules/statement/presentation/transaction_detail/view/transaction_detail_page.dart';
import 'package:go_router/go_router.dart';

final class StatementModule extends BaseAppModule {
  @override
  String get name => 'statement';

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutes.statement,
      builder: (context, state) => const StatementPage(),
    ),
    GoRoute(
      path: AppRoutes.transactionDetail,
      builder: (context, state) =>
          TransactionDetailPage(transactionId: state.pathParameters['id']!),
    ),
  ];
}
