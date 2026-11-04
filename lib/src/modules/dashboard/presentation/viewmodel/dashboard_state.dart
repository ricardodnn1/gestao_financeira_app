import 'package:equatable/equatable.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/account_balance.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/period_summary.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction_filter.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/period_preset_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/view_status_enum.dart';

class DashboardState extends Equatable {
  const DashboardState({
    this.status = ViewStatus.initial,
    this.balance,
    this.summary,
    this.recent = const [],
    this.balanceVisible = true,
    this.filter = const TransactionFilter(period: PeriodPreset.last30Days),
    this.errorMessage,
    this.fromCache = false,
  });

  final ViewStatus status;
  final AccountBalance? balance;
  final PeriodSummary? summary;
  final List<Transaction> recent;
  final bool balanceVisible;
  final TransactionFilter filter;
  final String? errorMessage;
  final bool fromCache;

  DashboardState copyWith({
    ViewStatus? status,
    AccountBalance? balance,
    PeriodSummary? summary,
    List<Transaction>? recent,
    bool? balanceVisible,
    TransactionFilter? filter,
    String? errorMessage,
    bool? fromCache,
    bool clearError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      summary: summary ?? this.summary,
      recent: recent ?? this.recent,
      balanceVisible: balanceVisible ?? this.balanceVisible,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      fromCache: fromCache ?? this.fromCache,
    );
  }

  @override
  List<Object?> get props => [
    status,
    balance,
    summary,
    recent,
    balanceVisible,
    filter,
    errorMessage,
    fromCache,
  ];
}
