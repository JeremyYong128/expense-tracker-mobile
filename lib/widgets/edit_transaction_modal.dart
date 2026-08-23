import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart' as t;
import '../models/recurring_transaction.dart';

import '../utils/string_extensions.dart';
import '../services/data_service.dart';
import '../widgets/transaction_form.dart';
import '../widgets/slide_up_modal.dart';

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
  final GlobalKey<TransactionFormState> _formKey = GlobalKey<TransactionFormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _saveTransaction(TransactionFormData data) async {
    try {
      final isRec = widget.recurringTransaction != null;

      if (isRec) {
        final nextDueDate = DataService.calculateNextDueDate(
          data.date,
          data.recurringInterval,
          data.recurringPeriod,
        );

        final updated = widget.recurringTransaction!.copyWith(
          amount: data.amount,
          title: data.title,
          categoryId: data.categoryId,
          isIncome: data.isIncome,
          interval: data.recurringInterval,
          period: data.recurringPeriod,
          nextDueDate: nextDueDate,
          note: data.note,
          creditCardId: data.creditCardId,
        );
        await DataService.updateRecurringTransaction(updated);
      } else {
        final updated = widget.transaction!.copyWith(
          amount: data.amount,
          title: data.title,
          categoryId: data.categoryId,
          date: data.date,
          isIncome: data.isIncome,
          note: data.note,
          creditCardId: data.creditCardId,
        );
        await DataService.updateTransaction(updated);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
            ),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  void _deleteTransaction() async {
    try {
      if (widget.recurringTransaction != null) {
        await DataService.deleteRecurringTransaction(
          widget.recurringTransaction!.id!,
        );
      } else {
        await DataService.deleteTransaction(widget.transaction!.id!);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete transaction'.cased(context)),
            backgroundColor: AppColors.expense,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TransactionForm(
              key: _formKey,
              transaction: widget.transaction,
              recurringTransaction: widget.recurringTransaction,
              showSaveButton: false,
              onSave: _saveTransaction,
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              height: 56.0,
              child: ElevatedButton(
                onPressed: _deleteTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  foregroundColor: Colors.red,
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
