import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/models/credit_card.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/screens/credit_card_details_screen.dart';
import 'package:expense_tracker_mobile/ui/widgets/credit_card_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';

class CreditCardsScreen extends StatefulWidget {
  const CreditCardsScreen({super.key});

  @override
  State<CreditCardsScreen> createState() => _CreditCardsScreenState();
}

class _CreditCardsScreenState extends State<CreditCardsScreen> {
  late Future<List<CreditCard>> _creditCardsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _creditCardsFuture = DataService.getCreditCards();
    });
  }

  void _showAddEditDialog([CreditCard? card]) {
    SlideUpModal.showCustom(
      context: context,
      builder: (context) => CreditCardModal(card: card, onSaved: _loadData),
    );
  }

  void _confirmDelete(CreditCard card) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Delete Credit Card'.cased(context)),
          content: Text(
            'Are you sure you want to delete ${card.name}? Expenses tagged with this card will not be deleted, but they will lose their card association.'
                .cased(context),
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel'.cased(context),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                await DataService.deleteCreditCard(card.id!);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: Text(
                'Delete'.cased(context),
                style: const TextStyle(color: AppColors.expense),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Credit Cards'.cased(context)),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddEditDialog(),
            ),
          ],
        ),
        body: FutureBuilder<List<CreditCard>>(
          future: _creditCardsFuture,
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

            final creditCards = snapshot.data!;
            if (creditCards.isEmpty) {
              return Center(
                child: Text(
                  'No credit cards added.'.cased(context),
                  style: const TextStyle(color: AppColors.grey, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: creditCards.length,
              itemBuilder: (context, index) {
                final card = creditCards[index];
                return Card(
                  color: AppColors.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreditCardDetailsScreen(creditCard: card),
                        ),
                      ).then(
                        (_) => _loadData(),
                      ); // Refresh if any transactions changed (though they might not change here)
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.credit_card,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${card.rewardRate.toStringAsFixed(1)}${card.rewardType == 'Cashback' ? '%' : ''} ${card.rewardType.cased(context)}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () => _showAddEditDialog(card),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.expense,
                              size: 20,
                            ),
                            onPressed: () => _confirmDelete(card),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
