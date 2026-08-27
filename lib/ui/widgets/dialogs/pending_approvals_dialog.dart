import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/models/transaction.dart';
import 'package:expense_tracker_mobile/services/recurring_processing_service.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/recurring_transaction_provider.dart';

class PendingApprovalsDialog extends StatefulWidget {
  final List<Transaction> initialPending;

  static Future<void> show(BuildContext context, List<Transaction> pending) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PendingApprovalsDialog(initialPending: pending);
      },
    );

    if (context.mounted) {
      context.read<TransactionProvider>().fetchTransactions();
      context.read<RecurringTransactionProvider>().fetchRecurringTransactions();
    }
  }

  const PendingApprovalsDialog({super.key, required this.initialPending});

  @override
  State<PendingApprovalsDialog> createState() => _PendingApprovalsDialogState();
}

class _PendingApprovalsDialogState extends State<PendingApprovalsDialog> {
  late List<Transaction> _pending;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _pending = List.from(widget.initialPending);
  }

  Future<void> _handleAction(Transaction tx, bool approve) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      if (approve) {
        await RecurringProcessingService.approveTransaction(tx);
      } else {
        await RecurringProcessingService.rejectTransaction(tx);
      }

      if (mounted) {
        setState(() {
          _pending.remove(tx);
          _isProcessing = false;
        });

        if (_pending.isEmpty) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedPending = <int, List<Transaction>>{};
    for (final tx in _pending) {
      if (tx.recurringId != null) {
        groupedPending.putIfAbsent(tx.recurringId!, () => []).add(tx);
      }
    }
    final groupedKeys = groupedPending.keys.toList();

    return AlertDialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 24.0,
      ),
      title: Text('Pending Approvals'.cased(context)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.8,
        child: _pending.isEmpty
            ? Center(child: Text('All caught up!'.cased(context)))
            : ListView.builder(
                itemCount: groupedKeys.length,
                itemBuilder: (context, index) {
                  final group = groupedPending[groupedKeys[index]]!;
                  final firstTx = group.first;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    elevation: 0,
                    color: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.divider),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  firstTx.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Text(
                                '\$${firstTx.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...group.map((tx) {
                            final isOldest = tx == group.first;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat(
                                            'MMM dd, yyyy',
                                          ).format(tx.date).cased(context),
                                          style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.close),
                                              iconSize: 20,
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints.tightFor(
                                                    width: 32,
                                                    height: 32,
                                                  ),
                                              style: IconButton.styleFrom(
                                                foregroundColor: AppTheme
                                                    .lightTheme
                                                    .primaryColor,
                                                backgroundColor: AppTheme
                                                    .lightTheme
                                                    .primaryColor
                                                    .withValues(alpha: 0.1),
                                                disabledForegroundColor:
                                                    AppColors.grey,
                                                disabledBackgroundColor: AppColors
                                                    .grey
                                                    .withValues(alpha: 0.1),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                ),
                                              ),
                                              onPressed:
                                                  _isProcessing || !isOldest
                                                  ? null
                                                  : () => _handleAction(
                                                      tx,
                                                      false,
                                                    ),
                                              tooltip: 'Skip',
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.check),
                                              iconSize: 20,
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints.tightFor(
                                                    width: 32,
                                                    height: 32,
                                                  ),
                                              style: IconButton.styleFrom(
                                                foregroundColor: AppTheme
                                                    .lightTheme
                                                    .primaryColor,
                                                backgroundColor: AppTheme
                                                    .lightTheme
                                                    .primaryColor
                                                    .withValues(alpha: 0.1),
                                                disabledForegroundColor:
                                                    AppColors.grey,
                                                disabledBackgroundColor: AppColors
                                                    .grey
                                                    .withValues(alpha: 0.1),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                ),
                                              ),
                                              onPressed:
                                                  _isProcessing || !isOldest
                                                  ? null
                                                  : () =>
                                                        _handleAction(tx, true),
                                              tooltip: 'Approve',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (!isOldest)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: Text(
                                          'Settle earlier dates first'.cased(
                                            context,
                                          ),
                                          style: const TextStyle(
                                            color: AppColors.expense,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      actions: [
        if (_pending.isNotEmpty)
          TextButton(
            onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
            child: Text('Close'.cased(context)),
          ),
      ],
    );
  }
}
