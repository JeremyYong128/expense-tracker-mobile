import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/database/drift_database.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/budget_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/models/card.dart' as app_card;
import 'package:expense_tracker_mobile/providers/card_provider.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/services/validator_service.dart';
import 'package:expense_tracker_mobile/core/exceptions.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_field.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_dropdown_field.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_month_year_picker.dart';

import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';

class BudgetForm extends StatefulWidget {
  final VoidCallback? onSaved;
  final DateTime targetMonth;
  final Budget? existingBudget;

  const BudgetForm({
    super.key,
    this.onSaved,
    required this.targetMonth,
    this.existingBudget,
  });

  @override
  State<BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  List<Category> _categories = [];
  bool _isLoadingCategories = true;
  Category? _selectedCategory;
  late int _selectedMonth;
  late int _selectedYear;
  String? _formError;
  bool _isSaving = false;
  
  String _budgetType = 'category';
  List<app_card.Card> _cards = [];
  bool _isLoadingCards = true;
  app_card.Card? _selectedCard;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.targetMonth.month;
    _selectedYear = widget.targetMonth.year;
    
    if (widget.existingBudget != null) {
      _budgetType = widget.existingBudget!.type;
      final amount = widget.existingBudget!.amount;
      _amountController.text = amount != null ? amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2) : '';
    }

    _loadCategories();
  }

  void _loadCategories() {
    final categoryProvider = context.read<CategoryProvider>();
    final cardProvider = context.read<CardProvider>();
    setState(() {
      _categories = categoryProvider
          .getAvailableCategoriesForDropdown(null)
          .where((c) => c.isExpense)
          .toList();
      _isLoadingCategories = false;

      if (widget.existingBudget != null && widget.existingBudget!.type == 'category') {
        try {
          _selectedCategory = _categories.firstWhere((c) => c.id == widget.existingBudget!.categoryId);
        } catch (_) {}
      }
      if (_selectedCategory == null && _categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
      
      _cards = cardProvider.getAvailableCardsForDropdown(null);
      _isLoadingCards = false;

      if (widget.existingBudget != null && widget.existingBudget!.type == 'card') {
        try {
          _selectedCard = _cards.firstWhere((c) => c.id == widget.existingBudget!.cardId);
        } catch (_) {}
      }
      if (_selectedCard == null && _cards.isNotEmpty) {
        _selectedCard = _cards.first;
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    setState(() {
      _formError = null;
      _isSaving = true;
    });
    FocusScope.of(context).unfocus();

    try {
      await ValidatorService.validateBudget(
        amountText: _amountController.text,
        type: _budgetType,
        category: _selectedCategory,
        card: _selectedCard,
        selectedMonth: _selectedMonth,
        selectedYear: _selectedYear,
        excludeBudgetId: widget.existingBudget?.id,
      );

      final amount = double.parse(_amountController.text);

      if (mounted) {
        context.read<BudgetProvider>().setBudget(
          targetMonth: _selectedMonth,
          targetYear: _selectedYear,
          type: _budgetType,
          categoryId: _budgetType == 'category' ? _selectedCategory?.id : null,
          cardId: _budgetType == 'card' ? _selectedCard?.id : null,
          amount: amount,
        );

        if (widget.onSaved != null) {
          widget.onSaved!();
        }
      }
    } on ValidationException catch (e) {
      if (mounted) {
        setState(() {
          _formError = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _formError = 'An unexpected error occurred.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _getInputDecoration({String? hintText, Widget? prefixIcon}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.grey),
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: AppColors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideUpModal(
      leftButtonTitle: 'Cancel'.cased(context),
      onLeftButtonPressed: () => Navigator.pop(context),
      rightButtonTitle: _isSaving ? 'Saving...' : 'Save'.cased(context),
      onRightButtonPressed: _isSaving ? null : _saveBudget,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_formError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _formError!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: CustomMonthYearPicker(
                  label: 'Month'.cased(context),
                  selectedDate: DateTime(_selectedYear, _selectedMonth),
                  onChanged: (DateTime newDate) {
                    setState(() {
                      _selectedMonth = newDate.month;
                      _selectedYear = newDate.year;
                    });
                  },
                ),
              ),

              CustomField(
                label: 'Amount'.cased(context),
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _getInputDecoration(
                    hintText: '0.00',
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: AppColors.primary,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Stack(
                    children: [
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        alignment: _budgetType == 'card' ? Alignment.centerRight : Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _budgetType = 'category'),
                              child: Container(
                                alignment: Alignment.center,
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 150),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _budgetType == 'category' ? AppColors.primary : Colors.grey,
                                  ),
                                  child: Text('Category'.cased(context)),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _budgetType = 'card'),
                              child: Container(
                                alignment: Alignment.center,
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 150),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _budgetType == 'card' ? AppColors.primary : Colors.grey,
                                  ),
                                  child: Text('Card'.cased(context)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (_budgetType == 'category')
                CustomField(
                  child: _isLoadingCategories
                      ? const Center(child: CircularProgressIndicator())
                      : CustomDropdownField<Category?>(
                          label: 'Category'.cased(context),
                          items: _categories,
                          selectedItem: _selectedCategory,
                          displayText: (cat) => cat?.name ?? '',
                          onChanged: (val) {
                            setState(() {
                              _selectedCategory = val;
                            });
                          },
                        ),
                )
              else
                CustomField(
                  child: _isLoadingCards
                      ? const Center(child: CircularProgressIndicator())
                      : CustomDropdownField<app_card.Card?>(
                          label: 'Card'.cased(context),
                          items: _cards,
                          selectedItem: _selectedCard,
                          displayText: (c) => c?.name ?? '',
                          onChanged: (val) {
                            setState(() {
                              _selectedCard = val;
                            });
                          },
                        ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
