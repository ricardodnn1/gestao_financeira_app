import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestao_financeira/src/core/routes/app_router.dart';
import 'package:gestao_financeira/src/core/theme/app_theme.dart';
import 'package:gestao_financeira/src/core/utils/date_formatters.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/view_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/widgets/async_state_widget.dart';
import 'package:gestao_financeira/src/modules/shared/widgets/transaction_tile_widget.dart';
import 'package:gestao_financeira/src/modules/statement/presentation/statement/viewmodel/statement_viewmodel.dart';
import 'package:gestao_financeira/src/modules/statement/presentation/statement/widgets/statement_filters.dart';
import 'package:go_router/go_router.dart';


class StatementPage extends ConsumerStatefulWidget {
  const StatementPage({super.key});

  @override
  ConsumerState<StatementPage> createState() => _StatementPageState();
}

class _StatementPageState extends ConsumerState<StatementPage> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offset = ref.read(statementViewModelProvider).scrollOffset;
      if (offset > 0 && _controller.hasClients) {
        _controller.jumpTo(offset);
      }
    });
  }

  void _onScroll() {
    final vm = ref.read(statementViewModelProvider.notifier);
    vm.saveScrollOffset(_controller.offset);
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 200) {
      vm.loadMore();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statementViewModelProvider);
    final vm = ref.read(statementViewModelProvider.notifier);
    final groups = _groupByDay(state.items);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extrato'),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: StatementFilters(
                filter: state.filter,
                onQueryChanged: vm.updateQuery,
                onToggleType: vm.toggleType,
                onToggleStatus: vm.toggleStatus,
                onPeriodChanged: vm.setPeriod,
                onCustomPeriod: vm.setCustomPeriod,
              ),
            ),
            Expanded(
              child: AsyncStateWidget(
                isLoading: state.status == ViewStatus.loading ||
                    state.status == ViewStatus.initial,
                hasError: state.status == ViewStatus.error,
                isEmpty: state.status == ViewStatus.empty,
                fromCache: state.fromCache,
                errorMessage: state.errorMessage,
                onRetry: vm.refresh,
                child: RefreshIndicator(
                  onRefresh: vm.refresh,
                  child: ListView.builder(
                    controller: _controller,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: groups.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= groups.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final group = groups[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                            child: Text(
                              DateFormatters.dayHeader(group.date),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          for (final tx in group.items)
                            TransactionTile(
                              transaction: tx,
                              onTap: () => context.push(
                                AppRoutes.transactionDetailPath(tx.id),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_DayGroup> _groupByDay(List<Transaction> items) {
    final map = <String, _DayGroup>{};
    for (final tx in items) {
      final key = DateFormatters.dayKey(tx.dateUtc);
      map.putIfAbsent(
        key,
        () => _DayGroup(date: tx.dateUtc, items: []),
      );
      map[key]!.items.add(tx);
    }
    return map.values.toList();
  }
}

class _DayGroup {
  _DayGroup({required this.date, required this.items});

  final DateTime date;
  final List<Transaction> items;
}