import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/models/transaction.dart';
import 'package:expense_tracker_mobile/ui/widgets/shared_filter_toggle.dart';

class MonthSelectorToggle extends StatefulWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final List<Transaction> transactions;

  const MonthSelectorToggle({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
    required this.transactions,
  });

  static List<DateTime> getAvailableMonths(List<Transaction> txs) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    if (txs.isEmpty) {
      return [currentMonth];
    }

    DateTime earliest = txs
        .map((t) => t.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    DateTime latest = txs
        .map((t) => t.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
        
    DateTime earliestMonth = DateTime(earliest.year, earliest.month);
    DateTime latestMonth = DateTime(latest.year, latest.month);
    
    if (currentMonth.isBefore(earliestMonth)) {
      earliestMonth = currentMonth;
    }
    if (currentMonth.isAfter(latestMonth)) {
      latestMonth = currentMonth;
    }

    List<DateTime> months = [];
    DateTime iter = earliestMonth;
    while (iter.isBefore(latestMonth) ||
        iter.isAtSameMomentAs(latestMonth)) {
      months.add(iter);
      iter = DateTime(
        iter.year,
        iter.month + 1,
      ); // handles year wrapping correctly
    }
    return months;
  }

  @override
  State<MonthSelectorToggle> createState() => _MonthSelectorToggleState();
}

class _MonthSelectorToggleState extends State<MonthSelectorToggle> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final months = MonthSelectorToggle.getAvailableMonths(widget.transactions);

    return SharedFilterToggle<DateTime>(
      items: months,
      selectedItem: months.firstWhere(
        (m) => m.year == widget.selectedMonth.year && m.month == widget.selectedMonth.month,
        orElse: () => widget.selectedMonth,
      ),
      labelBuilder: (month) => DateFormat('MMM yyyy').format(month),
      onSelected: widget.onMonthChanged,
      showCheckIcon: false,
      scrollController: _scrollController,
    );
  }
}
