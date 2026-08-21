import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart' as t;
import '../models/recurring_transaction.dart';
import '../models/category.dart';
import '../services/data_service.dart';
import '../widgets/custom_date_picker_field.dart';
import '../widgets/custom_time_picker_field.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/edit_categories_modal.dart';
import '../widgets/transaction_type_toggle.dart';
import '../widgets/slide_up_modal.dart';
import '../utils/string_extensions.dart';

class EditTransactionModal extends StatefulWidget {
  final t.Transaction? transaction;
  final RecurringTransaction? recurringTransaction;

  const EditTransactionModal({
    super.key,
    this.transaction,
    this.recurringTransaction,
  }) : assert(
         transaction != null || recurringTransaction != null,
         'Must provide a transaction to edit',
       );

  @override
  State<EditTransactionModal> createState() => _EditTransactionModalState();
}

class _EditTransactionModalState extends State<EditTransactionModal> {
  late bool _isIncome;
  Category? _selectedCategory;
  late DateTime _selectedDate;
  late final TextEditingController _amountController;
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late final TextEditingController _recurringIntervalController;

  static const List<String> _recurringPeriods = [
    'Day(s)',
    'Week(s)',
    'Month(s)',
    'Year(s)',
  ];
  late String _recurringPeriod;

  List<Category> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();

    final isRec = widget.recurringTransaction != null;

    _isIncome = isRec
        ? widget.recurringTransaction!.isIncome
        : widget.transaction!.isIncome;
    _selectedDate = isRec
        ? widget.recurringTransaction!.nextDueDate
        : widget.transaction!.date;

    _amountController = TextEditingController(
      text: isRec
          ? widget.recurringTransaction!.amount.toStringAsFixed(2)
          : widget.transaction!.amount.toStringAsFixed(2),
    );

    _titleController = TextEditingController(
      text: isRec
          ? widget.recurringTransaction!.title
          : widget.transaction!.title,
    );

    _noteController = TextEditingController(
      text: isRec
          ? widget.recurringTransaction!.note ?? ''
          : widget.transaction!.note ?? '',
    );

    _recurringIntervalController = TextEditingController(
      text: isRec ? widget.recurringTransaction!.interval.toString() : '1',
    );

    _recurringPeriod = isRec
        ? widget.recurringTransaction!.period
        : _recurringPeriods[2];

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await DataService.getCategories();
    setState(() {
      _categories = categories.where((c) => c.isActive).toList();
      _isLoadingCategories = false;

      final catId =
          widget.recurringTransaction?.categoryId ??
          widget.transaction!.categoryId;
      try {
        _selectedCategory = _categories.firstWhere((c) => c.id == catId);
      } catch (e) {
        _selectedCategory = null;
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    _recurringIntervalController.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    try {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0)
        throw Exception('Please enter a valid amount greater than 0.');
      if (_titleController.text.trim().isEmpty)
        throw Exception('Please enter a title.');
      if (_selectedCategory == null || _selectedCategory!.id == null)
        throw Exception('Please select a valid category.');

      final isRec = widget.recurringTransaction != null;

      if (isRec) {
        final recurringInterval = int.tryParse(
          _recurringIntervalController.text,
        );
        if (recurringInterval == null || recurringInterval <= 0)
          throw Exception('Please enter a valid recurring interval.');

        final nextDueDate = DataService.calculateNextDueDate(
          _selectedDate,
          recurringInterval,
          _recurringPeriod,
        );

        final updated = widget.recurringTransaction!.copyWith(
          amount: amount,
          title: _titleController.text.trim(),
          categoryId: _selectedCategory!.id!,
          isIncome: _isIncome,
          interval: recurringInterval,
          period: _recurringPeriod,
          nextDueDate: nextDueDate,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
        await DataService.updateRecurringTransaction(updated);
      } else {
        final updated = widget.transaction!.copyWith(
          amount: amount,
          title: _titleController.text.trim(),
          categoryId: _selectedCategory!.id!,
          date: _selectedDate,
          isIncome: _isIncome,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
        await DataService.updateTransaction(updated);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  void _deleteTransaction() async {
    try {
      if (widget.recurringTransaction != null) {
        await DataService.deleteRecurringTransaction(
          widget.recurringTransaction!.id!,
        );
      } else {
        await DataService.deleteTransaction(widget.transaction!.id!);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete transaction'.cased(context)),
            backgroundColor: AppColors.expense,
          ),
        );
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
      fillColor: Colors.white,
    );
  }

  Widget _buildFormField(String label, Widget child, {double? height = 60.0}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8.0),
          if (height != null) SizedBox(height: height, child: child) else child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRec = widget.recurringTransaction != null;

    return SlideUpModal(
      leftButtonTitle: 'Cancel'.cased(context),
      onLeftButtonPressed: () => Navigator.of(context).pop(),
      rightButtonTitle: 'Save'.cased(context),
      onRightButtonPressed: _saveTransaction,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TransactionTypeToggle(
              isIncome: _isIncome,
              onChanged: (value) => setState(() => _isIncome = value),
            ),
            const SizedBox(height: 32.0),

            _buildFormField(
              'Amount'.cased(context),
              TextField(
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

            _buildFormField(
              'Title'.cased(context),
              TextField(
                controller: _titleController,
                decoration: _getInputDecoration(
                  hintText: 'e.g. Groceries'.cased(context),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : CategoryDropdown(
                      label: 'Category'.cased(context),
                      hintText: 'Select a category...'.cased(context),
                      items: _categories,
                      selectedItem: _selectedCategory,
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val),
                      onEditPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => EditCategoriesModal(
                            initialCategories: _categories,
                            onCategoriesUpdated: (newCategories) {
                              setState(() {
                                _categories = newCategories;
                                if (_selectedCategory != null &&
                                    !_categories.any(
                                      (c) => c.id == _selectedCategory!.id,
                                    )) {
                                  _selectedCategory = null;
                                }
                              });
                            },
                            onCategorySelected: (category) {
                              setState(() => _selectedCategory = category);
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                    ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: CustomDatePickerField(
                      label: isRec
                          ? 'Start Date'.cased(context)
                          : 'Date'.cased(context),
                      selectedDate: _selectedDate,
                      onDateSelected: (newDate) =>
                          setState(() => _selectedDate = newDate),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: CustomTimePickerField(
                      label: 'Time'.cased(context),
                      selectedTime: _selectedDate,
                      onTimeSelected: (newTime) =>
                          setState(() => _selectedDate = newTime),
                    ),
                  ),
                ],
              ),
            ),

            if (isRec)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Repeat frequency'.cased(context),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Every'.cased(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 60.0,
                            child: TextField(
                              controller: _recurringIntervalController,
                              keyboardType: TextInputType.number,
                              decoration: _getInputDecoration(hintText: '1'),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          flex: 2,
                          child: CustomDropdownField<String>(
                            label: '',
                            items: _recurringPeriods,
                            selectedItem: _recurringPeriod,
                            displayText: (val) => val.cased(context),
                            onChanged: (val) =>
                                setState(() => _recurringPeriod = val),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            _buildFormField(
              'Note (optional)'.cased(context),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: _getInputDecoration(
                  hintText: 'Add details...'.cased(context),
                ).copyWith(contentPadding: const EdgeInsets.all(16.0)),
              ),
              height: null,
            ),

            SizedBox(
              width: double.infinity,
              height: 56.0,
              child: ElevatedButton(
                onPressed: _deleteTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: Text(
                  'Delete Transaction'.cased(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}
