import 'package:equatable/equatable.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction_filter.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/period_preset_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/view_status_enum.dart';

class StatementState extends Equatable {
  const StatementState({
    this.status = ViewStatus.initial,
    this.items = const [],
    this.filter = const TransactionFilter(period: PeriodPreset.last30Days),
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.errorMessage,
    this.fromCache = false,
    this.scrollOffset = 0,
  });

  final ViewStatus status;
  final List<Transaction> items;
  final TransactionFilter filter;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool fromCache;
  final double scrollOffset;

  StatementState copyWith({
    ViewStatus? status,
    List<Transaction>? items,
    TransactionFilter? filter,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
    bool? fromCache,
    double? scrollOffset,
    bool clearError = false,
  }) {
    return StatementState(
      status: status ?? this.status,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      fromCache: fromCache ?? this.fromCache,
      scrollOffset: scrollOffset ?? this.scrollOffset,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    filter,
    page,
    hasMore,
    isLoadingMore,
    errorMessage,
    fromCache,
    scrollOffset,
  ];
}
