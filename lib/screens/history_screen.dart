import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../utils/string_extensions.dart';

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

  // Parse hex to Color
  Color _fromHex(String? hexString) {
    if (hexString == null) return Colors.grey;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Get icon from string
  IconData _getIconData(String? iconString) {
    switch (iconString) {
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'restaurant':
        return Icons.restaurant;
      case 'receipt':
        return Icons.receipt;
      case 'attach_money':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Sort transactions by date descending so grouping works
    final sortedTransactions = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: AppStyles.screenPadding,
      itemCount: sortedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = sortedTransactions[index];
        final category = _getCategory(transaction.categoryId);
        final color = _fromHex(category.colorHex);

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
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Icon(
                        _getIconData(category.iconString),
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.title.cased(context),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '${DateFormat.jm().format(transaction.date).cased(context)} • ${category.name.cased(context)}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
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
              ),
            ), // End of Container
          ],
        );
      },
    );
  }
}
