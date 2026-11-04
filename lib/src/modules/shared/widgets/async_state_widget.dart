import 'package:flutter/material.dart';
import 'package:gestao_financeira/src/core/theme/app_theme.dart';

class AsyncStateWidget extends StatelessWidget {
  const AsyncStateWidget({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.isEmpty,
    required this.onRetry,
    required this.child,
    this.errorMessage,
    this.emptyMessage = 'Nenhuma movimentação encontrada.',
    this.fromCache = false,
  });

  final bool isLoading;
  final bool hasError;
  final bool isEmpty;
  final VoidCallback onRetry;
  final Widget child;
  final String? errorMessage;
  final String emptyMessage;
  final bool fromCache;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: AppColors.softInk,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage ?? 'Não foi possível carregar os dados.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 48,
                color: AppColors.softInk,
              ),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    if (!fromCache) return child;

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppColors.pending.withValues(alpha: 0.15),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.history, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Exibindo dados em cache (podem estar desatualizados).',
                ),
              ),
              TextButton(onPressed: onRetry, child: const Text('Atualizar')),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
