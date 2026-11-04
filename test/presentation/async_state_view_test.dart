import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_financeira/src/modules/shared/widgets/async_state_widget.dart';

void main() {
  testWidgets('exibe loading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AsyncStateWidget(
            isLoading: true,
            hasError: false,
            isEmpty: false,
            onRetry: _noop,
            child: const Text('ok'),
          ),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('exibe erro com retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AsyncStateWidget(
            isLoading: false,
            hasError: true,
            isEmpty: false,
            errorMessage: 'Falha de rede',
            onRetry: () => retried = true,
            child: const Text('ok'),
          ),
        ),
      ),
    );

    expect(find.text('Falha de rede'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    expect(retried, isTrue);
  });

  testWidgets('exibe vazio', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AsyncStateWidget(
            isLoading: false,
            hasError: false,
            isEmpty: true,
            onRetry: _noop,
            child: Text('ok'),
          ),
        ),
      ),
    );
    expect(find.text('Nenhuma movimentação encontrada.'), findsOneWidget);
  });
}

void _noop() {}
