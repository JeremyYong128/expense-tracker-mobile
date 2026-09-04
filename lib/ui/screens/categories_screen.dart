import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/widgets/category_form_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:expense_tracker_mobile/ui/screens/category_details_screen.dart';
import 'package:expense_tracker_mobile/ui/widgets/shared_filter_toggle.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _filter = 'All'; // 'All', 'Expense', 'Income'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Categories'.cased(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              SlideUpModal.showCustom(
                context: context,
                builder: (ctx) => const CategoryFormModal(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Consumer<CategoryProvider>(
          builder: (context, provider, child) {
          final allCategories = provider.activeCategories;

          if (allCategories.isEmpty) {
            return Center(
              child: Text(
                'No categories found'.cased(context),
                style: const TextStyle(color: AppColors.grey, fontSize: 16),
              ),
            );
          }

          final categories = allCategories.where((c) {
            if (_filter == 'Expense') return c.isExpense;
            if (_filter == 'Income') return c.isIncome;
            return true;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: AppStyles.screenPadding.copyWith(bottom: 8.0),
                child: SharedFilterToggle<String>(
                  items: const ['All', 'Expense', 'Income'],
                  selectedItem: _filter,
                  labelBuilder: (item) => item,
                  onSelected: (value) {
                    setState(() {
                      _filter = value;
                    });
                  },
                  showCheckIcon: true,
                ),
              ),
              Expanded(
                child: categories.isEmpty
                    ? Center(
                        child: Text(
                          'No categories found'.cased(context),
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: AppStyles.screenPadding.copyWith(top: 8.0),
                        itemCount: categories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(24.0),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.04,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: AppColors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24.0),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CategoryDetailsScreen(category: category),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: category.color.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                        ),
                                        child: Icon(
                                          category.iconData,
                                          color: category.color,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              category.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                if (category.isExpense)
                                                  _buildTypeBadge(
                                                    'Expense',
                                                    AppColors.expense,
                                                  ),
                                                if (category.isExpense &&
                                                    category.isIncome)
                                                  const SizedBox(width: 4),
                                                if (category.isIncome)
                                                  _buildTypeBadge(
                                                    'Income',
                                                    AppColors.income,
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
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
          );
        },
      ),
      ),
    );
  }


  Widget _buildTypeBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
