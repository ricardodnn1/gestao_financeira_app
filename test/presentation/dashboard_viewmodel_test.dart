import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_financeira/src/core/errors/failure.dart';
import 'package:gestao_financeira/src/core/errors/result.dart';
import 'package:gestao_financeira/src/modules/dashboard/presentation/viewmodel/dashboard_viewmodel.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/account_balance.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/period_summary.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction_filter.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_type_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/view_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/repositories/account_repository.dart';
import 'package:gestao_financeira/src/modules/shared/domain/repositories/preferences_repository.dart';
import 'package:gestao_financeira/src/modules/shared/domain/repositories/transaction_repository.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/get_balance_usecase.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/get_period_summary_usecase.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/get_recent_transaction_usecase.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/toggle_balance_visibility_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAccountRepo extends Mock implements AccountRepository {}

class _MockTxRepo extends Mock implements TransactionRepository {}

class _MockPrefsRepo extends Mock implements PreferencesRepository {}

void main() {
  late _MockAccountRepo accountRepo;
  late _MockTxRepo txRepo;
  late _MockPrefsRepo prefsRepo;
  late DashboardViewModel vm;

  setUpAll(() {
    registerFallbackValue(TransactionFilter.empty);
  });

  setUp(() {
    accountRepo = _MockAccountRepo();
    txRepo = _MockTxRepo();
    prefsRepo = _MockPrefsRepo();

    when(() => prefsRepo.isBalanceVisible()).thenAnswer((_) async => true);
    when(() => prefsRepo.setBalanceVisible(any())).thenAnswer((_) async {});

    vm = DashboardViewModel(
      getBalance: GetBalance(accountRepo),
      getPeriodSummary: GetPeriodSummary(accountRepo),
      getRecent: GetRecentTransactions(txRepo),
      getVisibility: GetBalanceVisibility(prefsRepo),
      setVisibility: SetBalanceVisibility(prefsRepo),
    );
  });

  test('load preenche estado de sucesso', () async {
    when(
      () => accountRepo.getBalance(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer(
      (_) async => Success(
        AccountBalance(
          available: const Money(10000),
          updatedAtUtc: DateTime.utc(2026, 11, 2),
        ),
      ),
    );
    when(
      () => accountRepo.getPeriodSummary(
        filter: any(named: 'filter'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Success(
        PeriodSummary(
          totalIncome: const Money(500),
          totalExpense: const Money(200),
          startUtc: DateTime.utc(2026, 10, 1),
          endUtc: DateTime.utc(2026, 11, 2),
        ),
      ),
    );
    when(() => txRepo.getRecent(limit: any(named: 'limit'))).thenAnswer(
      (_) async => Success([
        Transaction(
          id: '1',
          description: 'Teste',
          amount: const Money(100),
          dateUtc: DateTime.utc(2026, 11, 1),
          type: TransactionType.income,
          status: TransactionStatus.completed,
        ),
      ]),
    );

    await vm.load();

    expect(vm.state.status, ViewStatus.success);
    expect(vm.state.balance?.available.cents, 10000);
    expect(vm.state.recent, hasLength(1));
  });

  test('load em erro tipado', () async {
    when(
      () => accountRepo.getBalance(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => const Error(NetworkFailure()));
    when(
      () => accountRepo.getPeriodSummary(
        filter: any(named: 'filter'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => const Error(NetworkFailure()));
    when(
      () => txRepo.getRecent(limit: any(named: 'limit')),
    ).thenAnswer((_) async => const Error(NetworkFailure()));

    await vm.load();

    expect(vm.state.status, ViewStatus.error);
    expect(vm.state.errorMessage, isNotNull);
  });

  test('toggleBalanceVisibility persiste preferência', () async {
    when(
      () => accountRepo.getBalance(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer(
      (_) async => Success(
        AccountBalance(
          available: const Money(1),
          updatedAtUtc: DateTime.utc(2026, 11, 2),
        ),
      ),
    );
    when(
      () => accountRepo.getPeriodSummary(
        filter: any(named: 'filter'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Success(
        PeriodSummary(
          totalIncome: Money.zero(),
          totalExpense: Money.zero(),
          startUtc: DateTime.utc(2026, 11, 1),
          endUtc: DateTime.utc(2026, 11, 2),
        ),
      ),
    );
    when(
      () => txRepo.getRecent(limit: any(named: 'limit')),
    ).thenAnswer((_) async => const Success([]));

    await vm.load();
    await vm.toggleBalanceVisibility();

    expect(vm.state.balanceVisible, isFalse);
    verify(() => prefsRepo.setBalanceVisible(false)).called(1);
  });
}
