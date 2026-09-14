import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/providers/analytics_provider.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_list.dart';
import 'package:expense_tracker_mobile/ui/widgets/page_content_card.dart';
import 'package:expense_tracker_mobile/ui/widgets/notification_button.dart';
import 'package:expense_tracker_mobile/ui/widgets/month_selector_toggle.dart';
import 'package:expense_tracker_mobile/ui/widgets/month_navigator.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';

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
    final filteredTransactions = analyticsProvider.getTransactionsForMonth(
      _selectedMonth,
    );

    final availableMonths = MonthSelectorToggle.getAvailableMonths(
      transactionProvider.transactions,
    );
    final earliestMonth = availableMonths.first;
    final latestMonth = availableMonths.last;

    final canGoBack = _selectedMonth.isAfter(earliestMonth);
    final canGoForward = _selectedMonth.isBefore(latestMonth);

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
              MonthNavigator(
                currentMonth: _selectedMonth,
                canGoBack: canGoBack,
                canGoForward: canGoForward,
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
              const SizedBox(height: 8),
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Padding(
                        padding: EdgeInsets.only(
                          top: 8.0,
                          bottom: AppStyles.screenPadding.bottom,
                        ),
                        child: PageContentCard(
                          child: Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  'No transactions found.'.cased(context),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: 8.0,
                          bottom: AppStyles.screenPadding.bottom,
                        ),
                        child: PageContentCard(
                          child: TransactionList(
                            transactions: filteredTransactions,
                          ),
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
