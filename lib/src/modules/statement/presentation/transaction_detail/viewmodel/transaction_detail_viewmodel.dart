import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/view_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/get_transcation_by_id_usecase.dart';
import 'package:get_it/get_it.dart';

class TransactionDetailState extends Equatable {
  const TransactionDetailState({
    this.status = ViewStatus.loading,
    this.transaction,
    this.errorMessage,
  });

  final ViewStatus status;
  final Transaction? transaction;
  final String? errorMessage;

  TransactionDetailState copyWith({
    ViewStatus? status,
    Transaction? transaction,
    String? errorMessage,
  }) {
    return TransactionDetailState(
      status: status ?? this.status,
      transaction: transaction ?? this.transaction,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transaction, errorMessage];
}

final transactionDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<TransactionDetailViewModel, TransactionDetailState, String>(
      (ref, id) => TransactionDetailViewModel(
        id: id,
        getById: GetIt.instance.get<GetTransactionById>(),
      )..load(),
    );

class TransactionDetailViewModel extends StateNotifier<TransactionDetailState> {
  TransactionDetailViewModel({required this.id, required this.getById})
    : super(const TransactionDetailState());

  final String id;
  final GetTransactionById getById;

  Future<void> load() async {
    state = state.copyWith(status: ViewStatus.loading);
    final result = await getById(id);
    result.fold(
      onFailure: (f) => state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: f.message,
      ),
      onSuccess: (tx) =>
          state = state.copyWith(status: ViewStatus.success, transaction: tx),
    );
  }
}
