import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/data_service.dart';
import '../utils/string_extensions.dart';
import '../widgets/transaction_form.dart';

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

  void _saveTransaction(TransactionFormData data) async {
    try {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.expense,
          ),
        );
      }
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
