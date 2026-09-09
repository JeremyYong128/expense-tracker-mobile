import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/providers/analytics_provider.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_list.dart';
import 'package:expense_tracker_mobile/ui/widgets/notification_button.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/widgets/month_selector_toggle.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

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

    final analyticsProvider = context.watch<AnalyticsProvider>();
    final filteredTransactions = analyticsProvider.getTransactionsForMonth(_selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: Text('History'.cased(context)),
        actions: const [NotificationButton()],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppStyles.screenPadding.left,
            right: AppStyles.screenPadding.right,
            top: AppStyles.screenPadding.top,
          ),
          child: Column(
            children: [
              MonthSelectorToggle(
                selectedMonth: _selectedMonth,
                transactions: transactionProvider.transactions,
                onMonthChanged: (newMonth) {
                  setState(() {
                    _selectedMonth = newMonth;
                  });
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Padding(
                        padding: EdgeInsets.only(
                          top: 8.0,
                          bottom: AppStyles.screenPadding.bottom,
                        ),
                        child: TransactionList(transactions: filteredTransactions),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: 8.0,
                          bottom: AppStyles.screenPadding.bottom,
                        ),
                        child: TransactionList(
                          transactions: filteredTransactions,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
