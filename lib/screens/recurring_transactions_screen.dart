import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recurring_transaction.dart';
import '../models/category.dart';
import '../services/data_service.dart';
import '../utils/category_appearance.dart';
import '../theme/app_theme.dart';
import '../utils/string_extensions.dart';
import '../widgets/edit_transaction_modal.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() =>
      _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState
    extends State<RecurringTransactionsScreen> {
  List<RecurringTransaction> _recurringTransactions = [];
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await DataService.getRecurringTransactions();
    final categories = await DataService.getCategories();
    setState(() {
      _recurringTransactions = transactions;
      _categories = categories;
      _isLoading = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _recurringTransactions.isEmpty
          ? Center(
              child: Text(
                'No recurring transactions found.'.cased(context),
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: AppStyles.screenPadding,
              itemCount: _recurringTransactions.length,
              itemBuilder: (context, index) {
                final tx = _recurringTransactions[index];
                final category = _categories.firstWhere(
                  (c) => c.id == tx.categoryId,
                  orElse: () => Category(name: 'Unknown', colorHex: null, iconString: null, isActive: true),
                );
                final color = category.color;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 0,
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.0),
                    onTap: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => EditTransactionModal(
                          recurringTransaction: tx,
                        ),
                      );
                      _loadData();
                    },
                    child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            category.iconData,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Every ${tx.interval} ${tx.period}'
                                    .cased(context),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Due: ${DateFormat('d MMMM y').format(tx.nextDueDate).cased(context)}'
                                    .cased(context),
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '-\$${tx.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                );
              },
            ),
    );
  }
}
