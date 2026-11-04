import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:gestao_financeira/src/modules/dashboard/presentation/viewmodel/dashboard_state.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/period_preset_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/view_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/get_balance_usecase.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/get_period_summary_usecase.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/get_recent_transaction_usecase.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/toggle_balance_visibility_usecase.dart';
import 'package:get_it/get_it.dart';

final dashboardViewModelProvider =
    StateNotifierProvider.autoDispose<DashboardViewModel, DashboardState>(
  (ref) => DashboardViewModel(
    getBalance: GetIt.instance.get<GetBalance>(),
    getPeriodSummary: GetIt.instance.get<GetPeriodSummary>(),
    getRecent: GetIt.instance.get<GetRecentTransactions>(),
    getVisibility: GetIt.instance.get<GetBalanceVisibility>(),
    setVisibility: GetIt.instance.get<SetBalanceVisibility>(),
  )..load(),
);

class DashboardViewModel extends StateNotifier<DashboardState> {
  DashboardViewModel({
    required this.getBalance,
    required this.getPeriodSummary,
    required this.getRecent,
    required this.getVisibility,
    required this.setVisibility,
  }) : super(const DashboardState());

  final GetBalance getBalance;
  final GetPeriodSummary getPeriodSummary;
  final GetRecentTransactions getRecent;
  final GetBalanceVisibility getVisibility;
  final SetBalanceVisibility setVisibility;

  Future<void> load({bool forceRefresh = false}) async {
    final refreshing = state.status == ViewStatus.success;
    state = state.copyWith(
      status: refreshing ? ViewStatus.refreshing : ViewStatus.loading,
      clearError: true,
    );

    final visible = await getVisibility();
    final balanceResult = await getBalance(forceRefresh: forceRefresh);
    final summaryResult = await getPeriodSummary(
      filter: state.filter,
      forceRefresh: false,
    );
    final recentResult = await getRecent(limit: 5);

    if (balanceResult.isFailure) {
      state = state.copyWith(
        status: ViewStatus.error,
        balanceVisible: visible,
        errorMessage: balanceResult.failureOrNull?.message,
      );
      return;
    }

    final balance = balanceResult.valueOrNull!;
    final summary = summaryResult.valueOrNull;
    final recent = recentResult.valueOrNull ?? const [];

    state = state.copyWith(
      status: recent.isEmpty && summary == null
          ? ViewStatus.empty
          : ViewStatus.success,
      balance: balance,
      summary: summary,
      recent: recent,
      balanceVisible: visible,
      fromCache: balance.fromCache || (summary?.fromCache ?? false),
    );
  }

  Future<void> refresh() => load(forceRefresh: true);

  Future<void> toggleBalanceVisibility() async {
    final next = !state.balanceVisible;
    await setVisibility(next);
    state = state.copyWith(balanceVisible: next);
  }

  Future<void> setPeriod(PeriodPreset period) async {
    state = state.copyWith(
      filter: state.filter.copyWith(period: period, clearDates: true),
    );
    final summaryResult = await getPeriodSummary(filter: state.filter);
    summaryResult.fold(
      onFailure: (f) => state = state.copyWith(errorMessage: f.message),
      onSuccess: (s) =>
          state = state.copyWith(summary: s, fromCache: s.fromCache),
    );
  }
}
