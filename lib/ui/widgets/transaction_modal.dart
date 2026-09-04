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
import 'package:expense_tracker_mobile/ui/widgets/dialogs/confirmation_dialog.dart';

class TransactionModal extends StatefulWidget {
  final t.Transaction? transaction;
  final RecurringTransaction? recurringTransaction;
  final bool initialIsRecurring;

  const TransactionModal({
    super.key,
    this.transaction,
    this.recurringTransaction,
    this.initialIsRecurring = false,
  });

  @override
  State<TransactionModal> createState() => _TransactionModalState();
}

class _TransactionModalState extends State<TransactionModal> {
  final GlobalKey<TransactionFormState> _formKey =
      GlobalKey<TransactionFormState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction(TransactionFormData data) async {
    final isAdd =
        widget.transaction == null && widget.recurringTransaction == null;
    final isRec = widget.recurringTransaction != null;

    if (isAdd) {
      await context.read<TransactionProvider>().addTransaction(
        amountText: data.amount.toString(),
        title: data.title,
        date: data.date,
        categoryId: data.categoryId,
        isIncome: data.isIncome,
        isRecurring: data.isRecurring,
        recurringIntervalText: data.recurringInterval.toString(),
        recurringPeriod: data.recurringPeriod,
        note: data.note ?? '',
        creditCardId: data.creditCardId,
        recurringId: data.recurringId,
        rewardAmount: data.rewardAmount,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction added successfully!'.cased(context)),
          ),
        );
        if (data.isRecurring) {
          context
              .read<RecurringTransactionProvider>()
              .fetchRecurringTransactions();
        }
      }
    } else if (isRec) {
      ConfirmationDialog.show(
        context: context,
        title: 'Save Changes?',
        content:
            'Existing transactions linked to this recurring transaction will not be affected.',
        confirmText: 'Save',
        onConfirm: () async {
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
          if (mounted) Navigator.of(context).pop();
        },
      );
      return; // Don't pop immediately, wait for confirmation
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
              initialIsRecurring: widget.initialIsRecurring,
              showSaveButton: false,
              scrollController: _scrollController,
              onSave: _saveTransaction,
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}
