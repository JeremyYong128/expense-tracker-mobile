import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/providers/analytics_provider.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_list.dart';
import 'package:expense_tracker_mobile/ui/widgets/layout_widgets.dart';
import 'package:expense_tracker_mobile/utils/business_logic.dart';
import 'package:expense_tracker_mobile/ui/widgets/month_navigator.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_app_bar.dart';

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

    Widget bodyContent;

    if (transactionProvider.isLoading || categoryProvider.isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else {
      final analyticsProvider = context.watch<AnalyticsProvider>();
      final filteredTransactions = analyticsProvider.getTransactionsForMonth(
        _selectedMonth,
      );

      final availableMonths = BusinessLogic.getAvailableMonths(
        transactionProvider.transactions,
      );
      final earliestMonth = availableMonths.first;
      final latestMonth = availableMonths.last;


      bodyContent = SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          padding: AppStyles.screenPadding,
          child: Column(
            children: [
              MonthNavigator(
                currentMonth: _selectedMonth,
                minMonth: earliestMonth,
                maxMonth: latestMonth,
                onMonthSelected: (month) {
                  setState(() {
                    _selectedMonth = month;
                  });
                },
                onPrevious: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month - 1,
                    );
                  });
                },
                onNext: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              if (filteredTransactions.isEmpty)
                ContentCard(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No transactions for this month.'.cased(context),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                ContentCard(
                  child: TransactionList(transactions: filteredTransactions),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: Text('History'.cased(context))),
      body: bodyContent,
    );
  }
}
