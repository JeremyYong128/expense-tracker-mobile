import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:expense_tracker_mobile/ui/screens/recurring_transactions_screen.dart';
import 'package:expense_tracker_mobile/ui/screens/credit_cards_screen.dart';
import 'package:expense_tracker_mobile/ui/screens/categories_screen.dart';
import 'package:expense_tracker_mobile/ui/widgets/notification_button.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage'.cased(context)),
        actions: const [NotificationButton()],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          children: [
            _buildManageListItem(
              context,
              title: 'Recurring Transactions',
              icon: Icons.event_repeat,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) =>
                        const RecurringTransactionsScreen(showAppBar: true),
                  ),
                );
              },
            ),
            Divider(height: 1, color: Colors.grey.withValues(alpha: 0.5)),
            _buildManageListItem(
              context,
              title: 'Transaction Categories',
              icon: Icons.category,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const CategoriesScreen(),
                  ),
                );
              },
            ),
            Divider(height: 1, color: Colors.grey.withValues(alpha: 0.5)),
            _buildManageListItem(
              context,
              title: 'Credit Cards',
              icon: Icons.credit_card,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const CreditCardsScreen(),
                  ),
                );
              },
            ),
            Divider(height: 1, color: Colors.grey.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildManageListItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title.cased(context),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
