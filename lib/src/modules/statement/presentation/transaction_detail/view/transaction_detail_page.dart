import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestao_financeira/src/core/theme/app_theme.dart';
import 'package:gestao_financeira/src/core/utils/date_formatters.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/view_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/widgets/async_state_widget.dart';
import 'package:gestao_financeira/src/modules/statement/presentation/transaction_detail/viewmodel/transaction_detail_viewmodel.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailPage extends ConsumerWidget {
  const TransactionDetailPage({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionDetailViewModelProvider(transactionId));
    final vm = ref.read(
      transactionDetailViewModelProvider(transactionId).notifier,
    );
    final tx = state.transaction;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F2ED), AppColors.sand],
          ),
        ),
        child: AsyncStateWidget(
          isLoading: state.status == ViewStatus.loading,
          hasError: state.status == ViewStatus.error,
          isEmpty: false,
          errorMessage: state.errorMessage,
          onRetry: vm.load,
          child: tx == null
              ? const SizedBox.shrink()
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      tx.description,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${tx.typeSymbol} ${tx.amount.formatAbsolute()}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 30,
                        color: tx.isIncome
                            ? AppColors.income
                            : AppColors.expense,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _DetailRow(label: 'Tipo', value: tx.typeLabel),
                    _DetailRow(label: 'Status', value: tx.statusLabel),
                    _DetailRow(
                      label: 'Data e hora',
                      value: DateFormatters.dateTime(tx.dateUtc),
                    ),
                    if (tx.assetName != null)
                      _DetailRow(label: 'Ativo', value: tx.assetName!),
                    if (tx.assetSymbol != null)
                      _DetailRow(label: 'Símbolo', value: tx.assetSymbol!),
                    const SizedBox(height: 8),
                    _DetailRow(
                      label: 'Identificador',
                      value: tx.id,
                      trailing: IconButton(
                        tooltip: 'Copiar identificador',
                        icon: const Icon(Icons.copy_outlined, size: 20),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: tx.id));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Identificador copiado'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    if (tx.metadata.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Metadados',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      for (final entry in tx.metadata.entries)
                        _DetailRow(label: entry.key, value: entry.value),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
