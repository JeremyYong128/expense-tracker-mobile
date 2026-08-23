import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/category_appearance.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/edit_transaction_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<HistoryStats> _historyStatsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
    DataService.onDataChanged.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) {
      setState(() {
        _loadData();
      });
    }
  }

  @override
  void dispose() {
    DataService.onDataChanged.removeListener(_onDataChanged);
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _historyStatsFuture = DataService.getHistoryStats();
    });
  }

  Category _getCategory(List<Category> categories, int id) {
    return categories.firstWhere(
      (cat) => cat.id == id,
      orElse: () =>
          categories.isNotEmpty ? categories[0] : Category(name: 'unknown'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(title: Text('History'.cased(context))),
        body: FutureBuilder<HistoryStats>(
          future: _historyStatsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.expense),
                ),
              );
            }

            final stats = snapshot.data!;
            if (stats.groupedTransactions.isEmpty) {
              return Center(
                child: Text(
                  'No transactions yet.'.cased(context),
                  style: const TextStyle(color: AppColors.grey, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: AppStyles.screenPadding,
              itemCount: stats.groupedTransactions.length,
              itemBuilder: (context, index) {
                final entry = stats.groupedTransactions.entries.elementAt(
                  index,
                );
                final date = entry.key;
                final dayTransactions = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: index == 0 ? 0.0 : 8.0,
                        bottom: 12.0,
                        left: 4.0,
                      ),
                      child: Text(
                        DateFormat(
                          'EEEE, d MMMM yyyy',
                        ).format(date).cased(context),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...dayTransactions.map((transaction) {
                      final category = _getCategory(
                        stats.categories,
                        transaction.categoryId,
                      );
                      final color = category.color;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.04),
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
                              await SlideUpModal.showCustom(
                                context: context,
                                builder: (context) => EditTransactionModal(
                                  transaction: transaction,
                                ),
                              );
                              _loadData();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            color: color.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              transaction.note!
                                                  .trim()
                                                  .isNotEmpty) ...[
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                      );
                    }),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
