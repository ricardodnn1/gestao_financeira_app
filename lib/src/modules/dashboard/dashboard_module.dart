import 'package:gestao_financeira/src/core/modules/app_module.dart';
import 'package:gestao_financeira/src/core/network/http_client.dart';
import 'package:gestao_financeira/src/core/network/http_client_impl.dart';
import 'package:gestao_financeira/src/modules/dashboard/presentation/view/dashboard_page.dart';
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

final class DashboardModule extends BaseAppModule {
  DashboardModule(this.getIt);
  final GetIt getIt;

  @override
  String get name => 'dashboard';

  @override
  void registerDependencies() async {
    if (getIt.isRegistered<AppHttpClient>()) return;

    final prefs = await SharedPreferences.getInstance();

    getIt
      ..registerLazySingleton<AppHttpClient>(HttpClientImpl.new)
      ..registerLazySingleton<SharedPreferences>(() => prefs);

    getIt
      ..registerLazySingleton<CoinGeckoRemoteDataSource>(
        () => CoinGeckoRemoteDataSourceImpl(getIt()),
      )
      ..registerLazySingleton<CacheLocalDataSource>(
        () => CacheLocalDataSourceImpl(getIt()),
      )
      ..registerLazySingleton<PreferencesLocalDataSource>(
        () => PreferencesLocalDataSourceImpl(getIt()),
      )
      ..registerLazySingleton<TransactionMapper>(TransactionMapper.new);

    getIt.registerLazySingleton<LedgerStore>(
      () => LedgerStore(remote: getIt(), cache: getIt(), mapper: getIt()),
    );

    getIt
      ..registerLazySingleton<AccountRepository>(
        () => AccountRepositoryImpl(ledgerStore: getIt<LedgerStore>()),
      )
      ..registerLazySingleton<TransactionRepository>(
        () => TransactionRepositoryImpl(getIt()),
      )
      ..registerLazySingleton<PreferencesRepository>(
        () => PreferencesRepositoryImpl(getIt()),
      );

    getIt
      ..registerLazySingleton<CalculatePeriodTotals>(CalculatePeriodTotals.new)
      ..registerLazySingleton<GetBalance>(() => GetBalance(getIt()))
      ..registerLazySingleton<GetPeriodSummary>(() => GetPeriodSummary(getIt()))
      ..registerLazySingleton<GetTransactions>(() => GetTransactions(getIt()))
      ..registerLazySingleton<GetTransactionById>(
        () => GetTransactionById(getIt()),
      )
      ..registerLazySingleton<GetRecentTransactions>(
        () => GetRecentTransactions(getIt()),
      )
      ..registerLazySingleton<GetBalanceVisibility>(
        () => GetBalanceVisibility(getIt()),
      )
      ..registerLazySingleton<SetBalanceVisibility>(
        () => SetBalanceVisibility(getIt()),
      );
  }

  @override
  List<RouteBase> get routes => [
    GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
  ];
}
