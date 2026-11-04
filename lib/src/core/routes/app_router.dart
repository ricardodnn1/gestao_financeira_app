import 'package:flutter/material.dart';
import 'package:gestao_financeira/src/modules/dashboard/presentation/view/dashboard_page.dart';
import 'package:gestao_financeira/src/modules/statement/presentation/statement/view/statement_page.dart';
import 'package:gestao_financeira/src/modules/statement/presentation/transaction_detail/view/transaction_detail_page.dart';
import 'package:go_router/go_router.dart';

abstract class AppRoutes {
  static const dashboard = '/';
  static const statement = '/extrato';
  static const transactionDetail = '/transacao/:id';

  static String transactionDetailPath(String id) =>
      '/transacao/${Uri.encodeComponent(id)}';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.statement,
      name: 'extrato',
      builder: (context, state) => const StatementPage(),
    ),
    GoRoute(
      path: AppRoutes.transactionDetail,
      name: 'transacao',
      builder: (context, state) {
        final id = Uri.decodeComponent(state.pathParameters['id'] ?? '');
        return TransactionDetailPage(transactionId: id);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Rota não encontrada: ${state.uri}'),
    ),
  ),
);
