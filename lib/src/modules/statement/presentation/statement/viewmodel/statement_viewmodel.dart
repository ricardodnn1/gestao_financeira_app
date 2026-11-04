import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestao_financeira/src/core/utils/debounce.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction_filter.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/period_preset_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_type_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/view_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/get_transactions_usecase.dart';
import 'package:gestao_financeira/src/modules/statement/presentation/statement/viewmodel/statement_state.dart';
import 'package:get_it/get_it.dart';

final statementViewModelProvider =
    StateNotifierProvider.autoDispose<StatementViewModel, StatementState>(
      (ref) =>
          StatementViewModel(
            getTransactions: GetIt.instance.get<GetTransactions>(),
          )..load(),
    );

class StatementViewModel extends StateNotifier<StatementState> {
  StatementViewModel({required this.getTransactions})
    : super(const StatementState());

  final GetTransactions getTransactions;
  final Debouncer _searchDebouncer = Debouncer();
  static const _pageSize = 20;

  Future<void> load({bool forceRefresh = false}) async {
    state = state.copyWith(
      status: ViewStatus.loading,
      page: 1,
      clearError: true,
    );

    final result = await getTransactions(
      filter: state.filter,
      page: 1,
      pageSize: _pageSize,
      forceRefresh: forceRefresh,
    );

    result.fold(
      onFailure: (f) => state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: f.message,
      ),
      onSuccess: (page) => state = state.copyWith(
        status: page.items.isEmpty ? ViewStatus.empty : ViewStatus.success,
        items: page.items,
        page: 1,
        hasMore: page.hasMore,
        fromCache: page.fromCache,
      ),
    );
  }

  Future<void> refresh() => load(forceRefresh: true);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;

    final result = await getTransactions(
      filter: state.filter,
      page: nextPage,
      pageSize: _pageSize,
    );

    result.fold(
      onFailure: (f) =>
          state = state.copyWith(isLoadingMore: false, errorMessage: f.message),
      onSuccess: (page) => state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...page.items],
        page: nextPage,
        hasMore: page.hasMore,
        fromCache: page.fromCache,
      ),
    );
  }

  void updateQuery(String query) {
    state = state.copyWith(filter: state.filter.copyWith(query: query));
    _searchDebouncer.run(load);
  }

  Future<void> applyFilter(TransactionFilter filter) async {
    state = state.copyWith(filter: filter);
    await load();
  }

  void toggleType(TransactionType type) {
    final types = Set<TransactionType>.from(state.filter.types);
    if (!types.add(type)) types.remove(type);
    state = state.copyWith(filter: state.filter.copyWith(types: types));
    load();
  }

  void toggleStatus(TransactionStatus status) {
    final statuses = Set<TransactionStatus>.from(state.filter.statuses);
    if (!statuses.add(status)) statuses.remove(status);
    state = state.copyWith(filter: state.filter.copyWith(statuses: statuses));
    load();
  }

  void setPeriod(PeriodPreset period) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        period: period,
        clearDates: period != PeriodPreset.custom,
      ),
    );
    load();
  }

  void setCustomPeriod(DateTime startLocal, DateTime endLocal) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        period: PeriodPreset.custom,
        startUtc: DateTime(
          startLocal.year,
          startLocal.month,
          startLocal.day,
        ).toUtc(),
        endUtc: DateTime(
          endLocal.year,
          endLocal.month,
          endLocal.day,
          23,
          59,
          59,
        ).toUtc(),
      ),
    );
    load();
  }

  void saveScrollOffset(double offset) {
    state = state.copyWith(scrollOffset: offset);
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }
}
