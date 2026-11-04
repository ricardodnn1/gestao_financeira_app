import 'package:equatable/equatable.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/period_preset_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_type_enum.dart';

base class TransactionFilter extends Equatable {
  const TransactionFilter({
    this.types = const {},
    this.statuses = const {},
    this.period = PeriodPreset.last30Days,
    this.startUtc,
    this.endUtc,
    this.query = '',
  });

  final Set<TransactionType> types;
  final Set<TransactionStatus> statuses;
  final PeriodPreset period;
  final DateTime? startUtc;
  final DateTime? endUtc;
  final String query;

  static const empty = TransactionFilter();

  TransactionFilter copyWith({
    Set<TransactionType>? types,
    Set<TransactionStatus>? statuses,
    PeriodPreset? period,
    DateTime? startUtc,
    DateTime? endUtc,
    String? query,
    bool clearDates = false,
  }) {
    return TransactionFilter(
      types: types ?? this.types,
      statuses: statuses ?? this.statuses,
      period: period ?? this.period,
      startUtc: clearDates ? null : (startUtc ?? this.startUtc),
      endUtc: clearDates ? null : (endUtc ?? this.endUtc),
      query: query ?? this.query,
    );
  }

  (DateTime? start, DateTime? end) resolveRange({DateTime? nowUtc}) {
    final now = nowUtc ?? DateTime.now().toUtc();
    return switch (period) {
      PeriodPreset.today => (DateTime.utc(now.year, now.month, now.day), now),
      PeriodPreset.last7Days => (now.subtract(const Duration(days: 7)), now),
      PeriodPreset.last30Days => (now.subtract(const Duration(days: 30)), now),
      PeriodPreset.custom => (startUtc, endUtc),
      PeriodPreset.all => (null, null),
    };
  }

  bool matches(Transaction tx, {DateTime? nowUtc}) {
    if (types.isNotEmpty && !types.contains(tx.type)) return false;
    if (statuses.isNotEmpty && !statuses.contains(tx.status)) return false;

    final q = query.trim().toLowerCase();
    if (q.isNotEmpty && !tx.description.toLowerCase().contains(q)) {
      return false;
    }

    final (start, end) = resolveRange(nowUtc: nowUtc);
    if (start != null && tx.dateUtc.isBefore(start)) return false;
    if (end != null && tx.dateUtc.isAfter(end)) return false;

    return true;
  }

  @override
  List<Object?> get props => [types, statuses, period, startUtc, endUtc, query];
}
