import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_form.dart';
import 'package:expense_tracker_mobile/ui/widgets/notification_button.dart';
import 'package:expense_tracker_mobile/main.dart';

class AddTransactionFormConfig {
  final bool initialIsRecurring;
  final Key formKey;

  AddTransactionFormConfig({this.initialIsRecurring = false})
    : formKey = UniqueKey();
}

final ValueNotifier<AddTransactionFormConfig> addTransactionFormState =
    ValueNotifier(AddTransactionFormConfig());

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
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

    // Show success and reset form
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction added successfully!'.cased(context)),
        ),
      );
      context.read<TransactionProvider>().fetchTransactions();
      if (data.isRecurring) {
        context
            .read<RecurringTransactionProvider>()
            .fetchRecurringTransactions();
        HomeScreen.navigateToRecurring(context);
      } else {
        HomeScreen.navigateToHistory(context);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Unique key to completely reset the form upon success
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Transaction'.cased(context)),
          actions: const [NotificationButton()],
        ),
        body: SafeArea(
          top: false,
          bottom: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: AppStyles.screenPadding,
            child: ValueListenableBuilder<AddTransactionFormConfig>(
              valueListenable: addTransactionFormState,
              builder: (context, config, child) {
                return TransactionForm(
                  key: config.formKey,
                  scrollController: _scrollController,
                  onSave: _saveTransaction,
                  initialIsRecurring: config.initialIsRecurring,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
