import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/models/transaction.dart' as t;
import 'package:expense_tracker_mobile/models/recurring_transaction.dart';

import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_form.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';

class EditTransactionModal extends StatefulWidget {
  final t.Transaction? transaction;
  final RecurringTransaction? recurringTransaction;

  const EditTransactionModal({
    super.key,
    this.transaction,
    this.recurringTransaction,
  }) : assert(
         transaction != null || recurringTransaction != null,
         'Must provide a transaction to edit',
       );

  @override
  State<EditTransactionModal> createState() => _EditTransactionModalState();
}

class _EditTransactionModalState extends State<EditTransactionModal> {
  final GlobalKey<TransactionFormState> _formKey =
      GlobalKey<TransactionFormState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction(TransactionFormData data) async {
    final isRec = widget.recurringTransaction != null;

    if (isRec) {
      final updated = RecurringTransaction(
        id: widget.recurringTransaction!.id,
        amount: data.amount,
        title: data.title,
        categoryId: data.categoryId,
        isIncome: data.isIncome,
        interval: data.recurringInterval,
        period: data.recurringPeriod,
        startDate: data.date,
        nextDueDate: widget.recurringTransaction!.nextDueDate,
        note: data.note,
        creditCardId: data.creditCardId,
        rewardAmount: data.rewardAmount,
      );
      await context
          .read<RecurringTransactionProvider>()
          .updateRecurringTransaction(updated);
    } else {
      final updated = t.Transaction(
        id: widget.transaction!.id,
        amount: data.amount,
        title: data.title,
        categoryId: data.categoryId,
        date: data.date,
        isIncome: data.isIncome,
        recurringId: data.recurringId,
        note: data.note,
        creditCardId: data.creditCardId,
        rewardAmount: data.rewardAmount,
      );
      await context.read<TransactionProvider>().updateTransaction(updated);
    }

    if (mounted) Navigator.of(context).pop();
  }

  void _deleteTransaction() async {
    try {
      if (widget.recurringTransaction != null) {
        await context
            .read<RecurringTransactionProvider>()
            .deleteRecurringTransaction(widget.recurringTransaction!.id!);

        // Immediately refresh transactions
        if (mounted) {
          await context.read<TransactionProvider>().fetchTransactions();
        }
      } else {
        await context.read<TransactionProvider>().deleteTransaction(
          widget.transaction!.id!,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete transaction'.cased(context)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideUpModal(
      leftButtonTitle: 'Cancel'.cased(context),
      onLeftButtonPressed: () => Navigator.of(context).pop(),
      rightButtonTitle: 'Save'.cased(context),
      onRightButtonPressed: () {
        _formKey.currentState?.submit();
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TransactionForm(
              key: _formKey,
              transaction: widget.transaction,
              recurringTransaction: widget.recurringTransaction,
              showSaveButton: false,
              scrollController: _scrollController,
              onSave: _saveTransaction,
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              height: 56.0,
              child: ElevatedButton(
                onPressed: _deleteTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  foregroundColor: AppColors.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: Text(
                  'Delete Transaction'.cased(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}
