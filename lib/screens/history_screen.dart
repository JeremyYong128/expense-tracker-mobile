import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../utils/category_appearance.dart';
import '../utils/string_extensions.dart';
import '../widgets/edit_transaction_modal.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Category> _categories = [];
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await DataService.getCategories();
    final transactions = await DataService.getTransactions();
    setState(() {
      _categories = categories;
      _transactions = transactions;
      _isLoading = false;
    });
  }

  Category _getCategory(int id) {
    return _categories.firstWhere(
      (cat) => cat.id == id,
      orElse: () =>
          _categories.isNotEmpty ? _categories[0] : Category(name: 'unknown'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Sort transactions by date descending so grouping works
    final sortedTransactions = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(title: Text('History'.cased(context))),
      body: ListView.builder(
        padding: AppStyles.screenPadding,
        itemCount: sortedTransactions.length,
        itemBuilder: (context, index) {
        final transaction = sortedTransactions[index];
        final category = _getCategory(transaction.categoryId);
        final color = category.color;

        bool showDateHeader = false;
        if (index == 0) {
          showDateHeader = true;
        } else {
          final previousTransaction = sortedTransactions[index - 1];
          if (transaction.date.year != previousTransaction.date.year ||
              transaction.date.month != previousTransaction.date.month ||
              transaction.date.day != previousTransaction.date.day) {
            showDateHeader = true;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader)
              Padding(
                padding: EdgeInsets.only(
                  top: index == 0 ? 0.0 : 8.0,
                  bottom: 12.0,
                  left: 4.0,
                ),
                child: Text(
                  DateFormat(
                    'EEEE, d MMMM yyyy',
                  ).format(transaction.date).cased(context),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: 0.04,
                    ), // soft shadow using primary color
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24.0),
                  onTap: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          EditTransactionModal(transaction: transaction),
                    );
                    _loadData();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Icon(
                                  category.iconData,
                                  color: color,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                '${DateFormat.jm().format(transaction.date).cased(context)} • ${category.name}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (transaction.note != null &&
                                  transaction.note!.trim().isNotEmpty) ...[
                                const SizedBox(height: 4.0),
                                Text(
                                  transaction.note!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              transaction.isIncome
                                  ? '+\$${transaction.amount.toStringAsFixed(2)}'
                                  : '-\$${transaction.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: transaction.isIncome
                                    ? AppColors.income
                                    : AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
    ),
    );
  }
}
