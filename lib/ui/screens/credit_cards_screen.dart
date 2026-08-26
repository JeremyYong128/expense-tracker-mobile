import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/models/credit_card.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/screens/credit_card_details_screen.dart';
import 'package:expense_tracker_mobile/ui/widgets/credit_card_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/credit_card_provider.dart';
import 'package:expense_tracker_mobile/core/exceptions.dart';

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

  IconData _getIconForRewardType(String rewardType) {
    switch (rewardType.toLowerCase()) {
      case 'cashback':
        return Icons.attach_money;
      case 'miles':
        return Icons.flight_takeoff;
      case 'points':
        return Icons.stars;
      case 'none':
      default:
        return Icons.credit_card;
    }
  }

  String _getRewardSubtitle(BuildContext context, CreditCard card) {
    final type = card.rewardType.toLowerCase();

    if (type == 'none') {
      return 'No rewards'.cased(context);
    }

    final rateStr = card.rewardRate == card.rewardRate.toInt()
        ? card.rewardRate.toInt().toString()
        : card.rewardRate.toStringAsFixed(1);

    if (type == 'cashback') {
      return '$rateStr% Cashback'.cased(context);
    } else if (type == 'miles') {
      return '$rateStr Miles per \$'.cased(context);
    } else if (type == 'points') {
      return '$rateStr Points per \$'.cased(context);
    }

    return '$rateStr ${card.rewardType.cased(context)}';
  }

  void _showAddEditDialog([CreditCard? card]) {
    SlideUpModal.showCustom(
      context: context,
      builder: (context) => CreditCardModal(card: card),
    );
  }

  void _showRestoreDialog(CreditCard card) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Restore Credit Card'.cased(context)),
          content: Text(
            'Would you like to restore ${card.name} to your active wallet?'
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
                try {
                  await context.read<CreditCardProvider>().updateCreditCard(
                    card.copyWith(isActive: true),
                  );
                  if (context.mounted) Navigator.pop(context);
                } on DatabaseValidationException catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.message)));
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('An unexpected error occurred.'),
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Restore'.cased(context),
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardItem(CreditCard card, bool isArchived) {
    return Opacity(
      opacity: isArchived ? 0.6 : 1.0,
      child: Container(
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
            onTap: () {
              if (isArchived) {
                _showRestoreDialog(card);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreditCardDetailsScreen(creditCard: card),
                  ),
                );
              }
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
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Icon(
                            _getIconForRewardType(card.rewardType),
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            card.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            _getRewardSubtitle(context, card),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
    final activeCards = creditCards.where((c) => c.isActive).toList();
    final archivedCards = creditCards.where((c) => !c.isActive).toList();

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
            : ListView(
                padding: AppStyles.screenPadding,
                children: [
                  if (activeCards.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                      child: Text(
                        'Active'.cased(context),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...activeCards.map((c) => _buildCardItem(c, false)),
                    const SizedBox(height: 16),
                  ],
                  if (archivedCards.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                      child: Text(
                        'Archived'.cased(context),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...archivedCards.map((c) => _buildCardItem(c, true)),
                  ],
                ],
              ),
      ),
    );
  }
}
