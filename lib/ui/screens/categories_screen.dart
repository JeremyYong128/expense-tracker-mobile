import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/widgets/category_form.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:expense_tracker_mobile/ui/screens/category_details_screen.dart';
import 'package:expense_tracker_mobile/ui/widgets/shared_filter_toggle.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_app_bar.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_reorderable_grid_view.dart';

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
      appBar: CustomAppBar(
        title: Text('Transaction Categories'.cased(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              SlideUpModal.showCustom(
                context: context,
                builder: (ctx) => const CategoryForm(),
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

            List<Category> categories;
            if (_filter == 'Expense') {
              categories = provider.activeExpenseCategories;
            } else if (_filter == 'Income') {
              categories = provider.activeIncomeCategories;
            } else {
              categories = provider.activeCategories;
            }

            return Padding(
              padding: AppStyles.screenPadding,
              child: Column(
                children: [
                  SharedFilterToggle<String>(
                    items: const ['All', 'Expense', 'Income'],
                    selectedItem: _filter,
                    labelBuilder: (item) => item.cased(context),
                    onSelected: (value) {
                      setState(() {
                        _filter = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppStyles.cardSpacing),
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
                        : CustomReorderableGridView(
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1.65,
                                  crossAxisSpacing: 12.0,
                                  mainAxisSpacing: 12.0,
                                ),
                            itemCount: categories.length,
                            onReorder: (oldIndex, newIndex) {
                              provider.reorderCategory(
                                oldIndex,
                                newIndex,
                                _filter,
                              );
                            },
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return Container(
                                key: ValueKey(category.id),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16.0),
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
                                    borderRadius: BorderRadius.circular(16.0),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              CategoryDetailsScreen(
                                                category: category,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            category.iconData,
                                            color: category.color,
                                            size: 28,
                                          ),
                                          const SizedBox(height: 4.0),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 2.0,
                                            ),
                                            child: Text(
                                              category.name,
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
