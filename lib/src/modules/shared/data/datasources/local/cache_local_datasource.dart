import 'dart:convert';

import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_type_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedLedger {
  const CachedLedger({
    required this.transactions,
    required this.cachedAtUtc,
    required this.openingBalance,
  });

  final List<Transaction> transactions;
  final DateTime cachedAtUtc;
  final Money openingBalance;
}

abstract class CacheLocalDataSource {
  Future<CachedLedger?> readLedger();
  Future<void> writeLedger(CachedLedger ledger);
  Future<void> clear();
}

class CacheLocalDataSourceImpl implements CacheLocalDataSource {
  CacheLocalDataSourceImpl(this._prefs);

  static const _key = 'ledger_cache_v1';

  final SharedPreferences _prefs;

  @override
  Future<CachedLedger?> readLedger() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final txs = (map['transactions'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(_txFromJson)
          .toList();
      return CachedLedger(
        transactions: txs,
        cachedAtUtc: DateTime.parse(map['cached_at'] as String).toUtc(),
        openingBalance: Money(map['opening_cents'] as int),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> writeLedger(CachedLedger ledger) async {
    final payload = {
      'cached_at': ledger.cachedAtUtc.toIso8601String(),
      'opening_cents': ledger.openingBalance.cents,
      'transactions': ledger.transactions.map(_txToJson).toList(),
    };
    await _prefs.setString(_key, jsonEncode(payload));
  }

  @override
  Future<void> clear() => _prefs.remove(_key);

  Map<String, dynamic> _txToJson(Transaction tx) => {
    'id': tx.id,
    'description': tx.description,
    'cents': tx.amount.cents,
    'date_utc': tx.dateUtc.toIso8601String(),
    'type': tx.type.name,
    'status': tx.status.name,
    'asset_symbol': tx.assetSymbol,
    'asset_name': tx.assetName,
    'metadata': tx.metadata,
  };

  Transaction _txFromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: Money(json['cents'] as int),
      dateUtc: DateTime.parse(json['date_utc'] as String).toUtc(),
      type: TransactionType.values.byName(json['type'] as String),
      status: TransactionStatus.values.byName(json['status'] as String),
      assetSymbol: json['asset_symbol'] as String?,
      assetName: json['asset_name'] as String?,
      metadata: Map<String, String>.from(
        (json['metadata'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}
