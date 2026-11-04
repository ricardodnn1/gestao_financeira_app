import 'package:gestao_financeira/src/core/errors/failure.dart';
import 'package:gestao_financeira/src/core/errors/result.dart';
import 'package:gestao_financeira/src/modules/shared/data/repositories/ledger_store.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/paginated_transctions.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction_filter.dart';
import 'package:gestao_financeira/src/modules/shared/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._ledger);

  final LedgerStore _ledger;

  @override
  Future<Result<PaginatedTransactions>> getTransactions({
    TransactionFilter filter = TransactionFilter.empty,
    int page = 1,
    int pageSize = 20,
    bool forceRefresh = false,
  }) async {
    final loaded = await _ledger.ensureLoaded(forceRefresh: forceRefresh);
    if (loaded.isFailure) {
      return Error(loaded.failureOrNull!);
    }

    final safePage = page < 1 ? 1 : page;
    final safeSize = pageSize.clamp(1, 100);

    final filtered = _ledger.transactions.where(filter.matches).toList()
      ..sort((a, b) => b.dateUtc.compareTo(a.dateUtc));

    final start = (safePage - 1) * safeSize;
    if (start >= filtered.length) {
      return Success(
        PaginatedTransactions(
          items: const [],
          page: safePage,
          pageSize: safeSize,
          hasMore: false,
          totalCount: filtered.length,
          fromCache: _ledger.fromCache,
        ),
      );
    }

    final end = (start + safeSize).clamp(0, filtered.length);
    final slice = filtered.sublist(start, end);

    return Success(
      PaginatedTransactions(
        items: slice,
        page: safePage,
        pageSize: safeSize,
        hasMore: end < filtered.length,
        totalCount: filtered.length,
        fromCache: _ledger.fromCache,
      ),
    );
  }

  @override
  Future<Result<Transaction>> getById(String id) async {
    final loaded = await _ledger.ensureLoaded();
    if (loaded.isFailure) {
      return Error(loaded.failureOrNull!);
    }

    final tx = _ledger.findById(id);
    if (tx == null) {
      return const Error(NotFoundFailure('Transação não encontrada.'));
    }
    return Success(tx);
  }

  @override
  Future<Result<List<Transaction>>> getRecent({int limit = 5}) async {
    final loaded = await _ledger.ensureLoaded();
    if (loaded.isFailure) {
      return Error(loaded.failureOrNull!);
    }

    final items = _ledger.transactions.take(limit).toList();
    return Success(items);
  }
}
