import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/category_appearance.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/edit_transaction_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_list.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
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
    final transactionProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    if (transactionProvider.isLoading || categoryProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('History'.cased(context))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(title: Text('History'.cased(context))),
        body: SingleChildScrollView(
          child: TransactionList(transactions: transactionProvider.transactions),
        ),
      ),
    );
  }
}
