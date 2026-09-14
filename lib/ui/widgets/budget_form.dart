import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/budget_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/models/category.dart';
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

  const BudgetForm({super.key, this.onSaved, required this.targetMonth});

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

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.targetMonth.month;
    _selectedYear = widget.targetMonth.year;
    _loadCategories();
  }

  void _loadCategories() {
    final categoryProvider = context.read<CategoryProvider>();
    setState(() {
      _categories = categoryProvider
          .getAvailableCategoriesForDropdown(null)
          .where((c) => c.isExpense)
          .toList();
      _isLoadingCategories = false;

      if (_selectedCategory == null && _categories.isNotEmpty) {
        _selectedCategory = _categories.first;
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
        category: _selectedCategory,
        selectedMonth: _selectedMonth,
        selectedYear: _selectedYear,
      );

      final amount = double.parse(_amountController.text);

      if (mounted) {
        context.read<BudgetProvider>().setBudget(
          targetMonth: _selectedMonth,
          targetYear: _selectedYear,
          type: 'category',
          categoryId: _selectedCategory?.id,
          cardId: null,
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
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
