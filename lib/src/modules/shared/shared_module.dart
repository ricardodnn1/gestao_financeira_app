import 'package:gestao_financeira/src/core/modules/app_module.dart';
import 'package:gestao_financeira/src/modules/shared/data/datasources/local/cache_local_datasource.dart';
import 'package:gestao_financeira/src/modules/shared/data/datasources/local/preferences_local_datasource.dart';
import 'package:gestao_financeira/src/modules/shared/data/datasources/remote/coingecko_remote_datasource.dart';
import 'package:gestao_financeira/src/modules/shared/data/mappers/transactioon_mapper.dart';
import 'package:gestao_financeira/src/modules/shared/data/repositories/account_repository_impl.dart';
import 'package:gestao_financeira/src/modules/shared/data/repositories/ledger_store.dart';
import 'package:gestao_financeira/src/modules/shared/data/repositories/preferences_repository_impl.dart';
import 'package:gestao_financeira/src/modules/shared/data/repositories/transaction_repository_impl.dart';
import 'package:gestao_financeira/src/modules/shared/domain/repositories/account_repository.dart';
import 'package:gestao_financeira/src/modules/shared/domain/repositories/preferences_repository.dart';
import 'package:gestao_financeira/src/modules/shared/domain/repositories/transaction_repository.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/calculate_period_totals_usecase.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/get_balance_usecase.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/get_period_summary_usecase.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/get_recent_transaction_usecase.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/get_transactions_usecase.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/get_transcation_by_id_usecase.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/toggle_balance_visibility_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:gestao_financeira/src/modules/shared/widgets/async_state_widget.dart'; 

final class SharedModule extends BaseAppModule {
  SharedModule(this.getIt);

  final GetIt getIt;

  @override
  String get name => 'shared';

  @override
  List<RouteBase> get routes => const [];

  @override
  Future<void> registerDependencies() async {
    if (!getIt.isRegistered<SharedPreferences>()) {
      final prefs = await SharedPreferences.getInstance();
      if (!getIt.isRegistered<SharedPreferences>()) {
        getIt.registerSingleton<SharedPreferences>(prefs);
      }
    }

    _registerLazySingletonIfAbsent<CoinGeckoRemoteDataSource>(
      () => CoinGeckoRemoteDataSourceImpl(getIt()),
    );
    _registerLazySingletonIfAbsent<CacheLocalDataSource>(
      () => CacheLocalDataSourceImpl(getIt()),
    );
    _registerLazySingletonIfAbsent<PreferencesLocalDataSource>(
      () => PreferencesLocalDataSourceImpl(getIt()),
    );
    _registerLazySingletonIfAbsent<TransactionMapper>(TransactionMapper.new);
    _registerLazySingletonIfAbsent<LedgerStore>(
      () => LedgerStore(remote: getIt(), cache: getIt(), mapper: getIt()),
    );
    _registerLazySingletonIfAbsent<AccountRepository>(
      () => AccountRepositoryImpl(ledgerStore: getIt<LedgerStore>()),
    );
    _registerLazySingletonIfAbsent<TransactionRepository>(
      () => TransactionRepositoryImpl(getIt()),
    );
    _registerLazySingletonIfAbsent<PreferencesRepository>(
      () => PreferencesRepositoryImpl(getIt()),
    );
    _registerLazySingletonIfAbsent<CalculatePeriodTotals>(
      CalculatePeriodTotals.new,
    );
    _registerLazySingletonIfAbsent<GetBalance>(() => GetBalance(getIt()));
    _registerLazySingletonIfAbsent<GetPeriodSummary>(
      () => GetPeriodSummary(getIt()),
    );
    _registerLazySingletonIfAbsent<GetTransactions>(
      () => GetTransactions(getIt()),
    );
    _registerLazySingletonIfAbsent<GetTransactionById>(
      () => GetTransactionById(getIt()),
    );
    _registerLazySingletonIfAbsent<GetRecentTransactions>(
      () => GetRecentTransactions(getIt()),
    );
    _registerLazySingletonIfAbsent<GetBalanceVisibility>(
      () => GetBalanceVisibility(getIt()),
    );
    _registerLazySingletonIfAbsent<SetBalanceVisibility>(
      () => SetBalanceVisibility(getIt()),
    );
  }

  void _registerLazySingletonIfAbsent<T extends Object>(T Function() factory) {
    if (!getIt.isRegistered<T>()) {
      getIt.registerLazySingleton<T>(factory);
    }
  }
}
