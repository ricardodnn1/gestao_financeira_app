import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestao_financeira/src/core/routes/app_router.dart';
import 'package:gestao_financeira/src/core/theme/app_theme.dart';
import 'package:gestao_financeira/src/modules/dashboard/presentation/viewmodel/dashboard_viewmodel.dart';
import 'package:gestao_financeira/src/modules/dashboard/presentation/widgets/balance_card.dart';
import 'package:gestao_financeira/src/modules/dashboard/presentation/widgets/period_summary_section.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/view_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/widgets/async_state_widget.dart';
import 'package:gestao_financeira/src/modules/shared/widgets/transaction_tile_widget.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);
    final vm = ref.read(dashboardViewModelProvider.notifier);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F2ED), AppColors.sand],
          ),
        ),
        child: SafeArea(
          child: AsyncStateWidget(
            isLoading:
                state.status == ViewStatus.loading ||
                state.status == ViewStatus.initial,
            hasError: state.status == ViewStatus.error,
            isEmpty: state.status == ViewStatus.empty,
            fromCache: state.fromCache,
            errorMessage: state.errorMessage,
            onRetry: vm.refresh,
            child: RefreshIndicator(
              onRefresh: vm.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestão Financeira',
                            style: Theme.of(
                              context,
                            ).textTheme.displaySmall?.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Extrato e saldo com base na Cotação CoinGecko',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          if (state.balance != null)
                            BalanceCard(
                              balance: state.balance!,
                              visible: state.balanceVisible,
                              onToggleVisibility: vm.toggleBalanceVisibility,
                            ),
                          if (state.status == ViewStatus.refreshing)
                            const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: LinearProgressIndicator(),
                            ),
                          const SizedBox(height: 28),
                          if (state.summary != null)
                            PeriodSummarySection(
                              summary: state.summary!,
                              selectedPeriod: state.filter.period,
                              onPeriodChanged: vm.setPeriod,
                            ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Text(
                                'Recentes',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontSize: 20),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () =>
                                    context.push(AppRoutes.statement),
                                child: const Text('Ver extrato'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: state.recent.length,
                    itemBuilder: (context, index) {
                      final tx = state.recent[index];
                      return TransactionTile(
                        transaction: tx,
                        onTap: () => context.push(
                          AppRoutes.transactionDetailPath(tx.id),
                        ),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
