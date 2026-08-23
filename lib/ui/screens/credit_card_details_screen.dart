import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/models/credit_card.dart';
import 'package:expense_tracker_mobile/models/transaction.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/utils/category_appearance.dart';

class CreditCardDetailsScreen extends StatefulWidget {
  final CreditCard creditCard;

  const CreditCardDetailsScreen({super.key, required this.creditCard});

  @override
  State<CreditCardDetailsScreen> createState() =>
      _CreditCardDetailsScreenState();
}

class _CreditCardDetailsScreenState extends State<CreditCardDetailsScreen> {
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  double _totalRewards = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await DataService.getTransactionsForCard(
      widget.creditCard.id!,
    );
    final categories = await DataService.getCategories();

    // Calculate total rewards
    double totalSpent = 0;
    for (var tx in transactions) {
      if (!tx.isIncome) {
        totalSpent += tx.amount;
      }
    }

    double rewards = 0;
    if (widget.creditCard.rewardType == 'Cashback') {
      rewards = totalSpent * (widget.creditCard.rewardRate / 100);
    } else {
      rewards = totalSpent * widget.creditCard.rewardRate;
    }

    // Sort transactions by date descending
    transactions.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _transactions = transactions;
      _categories = categories;
      _totalRewards = rewards;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.creditCard.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildRewardsSummary(),
                const SizedBox(height: 16),
                Expanded(
                  child: _transactions.isEmpty
                      ? Center(
                          child: Text(
                            'No expenses tagged to this card.'.cased(context),
                            style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _transactions[index];
                            final category = _categories.firstWhere(
                              (c) => c.id == transaction.categoryId,
                              orElse: () => Category(
                                id: 0,
                                name: 'Unknown',
                                colorHex: '#9E9E9E',
                                iconString: 'help_outline',
                              ),
                            );

                            final color = CategoryAppearance.getColorFromHex(
                              category.colorHex,
                            );

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              child: Card(
                                color: AppColors.surface,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: BorderSide(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                  ),
                                ),
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
                                              padding: const EdgeInsets.all(
                                                10.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: color.withValues(
                                                  alpha: 0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              child: Icon(
                                                CategoryAppearance.getIconData(
                                                  category.iconString,
                                                ),
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
                                                '${DateFormat.yMMMd().format(transaction.date).cased(context)} • ${category.name}',
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
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
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                              '-\$${transaction.amount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: AppColors.expense,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildRewardsSummary() {
    final isCashback = widget.creditCard.rewardType == 'Cashback';
    final rewardText = isCashback
        ? '\$${_totalRewards.toStringAsFixed(2)}'
        : NumberFormat.decimalPattern().format(_totalRewards.toInt());

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF6C63FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars, color: Colors.white70, size: 24),
              const SizedBox(width: 8),
              Text(
                'Lifetime Rewards'.cased(context).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rewardText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total ${widget.creditCard.rewardType} earned'.cased(context),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
