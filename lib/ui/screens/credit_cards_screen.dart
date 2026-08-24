import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/models/credit_card.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/screens/credit_card_details_screen.dart';
import 'package:expense_tracker_mobile/ui/widgets/credit_card_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/credit_card_provider.dart';

class CreditCardsScreen extends StatefulWidget {
  const CreditCardsScreen({super.key});

  @override
  State<CreditCardsScreen> createState() => _CreditCardsScreenState();
}

class _CreditCardsScreenState extends State<CreditCardsScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _showAddEditDialog([CreditCard? card]) {
    SlideUpModal.showCustom(
      context: context,
      builder: (context) => CreditCardModal(card: card),
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
                await context.read<CreditCardProvider>().deleteCreditCard(card.id!);
                if (context.mounted) {
                  Navigator.pop(context);
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
    final creditCardProvider = context.watch<CreditCardProvider>();

    if (creditCardProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Credit Cards'.cased(context))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final creditCards = creditCardProvider.creditCards;

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
        body: creditCards.isEmpty
            ? Center(
                child: Text(
                  'No credit cards added.'.cased(context),
                  style: const TextStyle(color: AppColors.grey, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: creditCards.length,
                itemBuilder: (context, index) {
                  final card = creditCards[index];
                  return Card(
                    color: AppColors.surface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.1)),
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
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.15),
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
              ),
      ),
    );
  }
}
