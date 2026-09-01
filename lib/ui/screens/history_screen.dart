import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_list.dart';
import 'package:expense_tracker_mobile/ui/widgets/notification_button.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    if (transactionProvider.isLoading || categoryProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('History'.cased(context)),
          actions: const [NotificationButton()],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('History'.cased(context)),
        actions: const [NotificationButton()],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: transactionProvider.transactions.isEmpty
            ? TransactionList(transactions: transactionProvider.transactions)
            : SingleChildScrollView(
                padding: AppStyles.screenPadding,
                child: TransactionList(
                  transactions: transactionProvider.transactions,
                ),
              ),
      ),
    );
  }
}
