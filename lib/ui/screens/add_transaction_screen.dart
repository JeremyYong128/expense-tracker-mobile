import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_form.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveTransaction(TransactionFormData data) async {
    await DataService.addTransaction(
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
    );

    // Show success and reset form
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction added successfully!'.cased(context)),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Unique key to completely reset the form upon success
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(title: Text('Add Transaction'.cased(context))),
        body: SingleChildScrollView(
          padding: AppStyles.screenPadding,
          child: TransactionForm(key: UniqueKey(), onSave: _saveTransaction),
        ),
      ),
    );
  }
}
