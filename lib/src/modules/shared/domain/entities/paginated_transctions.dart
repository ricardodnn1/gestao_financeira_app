import 'package:equatable/equatable.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';

class PaginatedTransactions extends Equatable {
  const PaginatedTransactions({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.hasMore,
    this.totalCount,
    this.fromCache = false,
  });

  final List<Transaction> items;
  final int page;
  final int pageSize;
  final bool hasMore;
  final int? totalCount;
  final bool fromCache;

  @override
  List<Object?> get props => [
    items,
    page,
    pageSize,
    hasMore,
    totalCount,
    fromCache,
  ];
}
