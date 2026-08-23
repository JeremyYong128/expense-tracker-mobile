import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/models/transaction.dart' as t;
import 'package:expense_tracker_mobile/models/recurring_transaction.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/models/credit_card.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_date_picker_field.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_time_picker_field.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_dropdown_field.dart';
import 'package:expense_tracker_mobile/ui/widgets/category_picker_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/category_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_type_toggle.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_switch.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_validated_field.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/utils/validators.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';

class TransactionFormData {
  final double amount;
  final String title;
  final int categoryId;
  final DateTime date;
  final bool isIncome;
  final String? note;
  final int? creditCardId;
  final bool isRecurring;
  final int recurringInterval;
  final String recurringPeriod;

  TransactionFormData({
    required this.amount,
    required this.title,
    required this.categoryId,
    required this.date,
    required this.isIncome,
    this.note,
    this.creditCardId,
    required this.isRecurring,
    required this.recurringInterval,
    required this.recurringPeriod,
  });
}

class TransactionForm extends StatefulWidget {
  final t.Transaction? transaction;
  final RecurringTransaction? recurringTransaction;
  final bool showSaveButton;
  final Future<void> Function(TransactionFormData data) onSave;

  const TransactionForm({
    super.key,
    this.transaction,
    this.recurringTransaction,
    this.showSaveButton = true,
    required this.onSave,
  });

  @override
  State<TransactionForm> createState() => TransactionFormState();
}

class TransactionFormState extends State<TransactionForm> {
  late bool _isIncome;
  Category? _selectedCategory;
  late DateTime _selectedDate;
  late final TextEditingController _amountController;
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;

  late bool _isRecurring;
  late final TextEditingController _recurringIntervalController;
  late String _recurringPeriod;
  String? _formError;

  static const List<String> _recurringPeriods = [
    'Day(s)',
    'Week(s)',
    'Month(s)',
    'Year(s)',
  ];

  List<Category> _categories = [];
  List<CreditCard> _creditCards = [];
  CreditCard? _selectedCreditCard;
  bool _isLoadingCategories = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    final isEditRec = widget.recurringTransaction != null;
    final isEditNor = widget.transaction != null;

    _isIncome = isEditRec
        ? widget.recurringTransaction!.isIncome
        : (isEditNor ? widget.transaction!.isIncome : false);

    _selectedDate = isEditRec
        ? widget.recurringTransaction!.startDate
        : (isEditNor ? widget.transaction!.date : DateTime.now());

    _amountController = TextEditingController(
      text: isEditRec
          ? widget.recurringTransaction!.amount.toStringAsFixed(2)
          : (isEditNor ? widget.transaction!.amount.toStringAsFixed(2) : ''),
    );

    _titleController = TextEditingController(
      text: isEditRec
          ? widget.recurringTransaction!.title
          : (isEditNor ? widget.transaction!.title : ''),
    );

    _noteController = TextEditingController(
      text: isEditRec
          ? widget.recurringTransaction!.note ?? ''
          : (isEditNor ? widget.transaction!.note ?? '' : ''),
    );

    _isRecurring = isEditRec;
    _recurringIntervalController = TextEditingController(
      text: isEditRec ? widget.recurringTransaction!.interval.toString() : '1',
    );

    _recurringPeriod = isEditRec
        ? widget.recurringTransaction!.period
        : _recurringPeriods[2];

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await DataService.getCategories();
    final creditCards = await DataService.getCreditCards();
    setState(() {
      int? catId;
      if (widget.recurringTransaction != null) {
        catId = widget.recurringTransaction!.categoryId;
      } else if (widget.transaction != null) {
        catId = widget.transaction!.categoryId;
      }

      _categories = categories.where((c) {
        return c.isActive || c.id == catId;
      }).toList();
      
      _creditCards = creditCards;
      _isLoadingCategories = false;

      if (catId != null) {
        try {
          _selectedCategory = _categories.firstWhere((c) => c.id == catId);
        } catch (e) {
          _selectedCategory = null;
        }
      } else if (_categories.isNotEmpty) {
        _selectedCategory = _categories.firstWhere(
          (c) => c.name.toLowerCase() == 'groceries',
          orElse: () => _categories.first,
        );
      }

      int? creditCardId;
      if (widget.recurringTransaction != null) {
        creditCardId = widget.recurringTransaction!.creditCardId;
      } else if (widget.transaction != null) {
        creditCardId = widget.transaction!.creditCardId;
      }

      if (creditCardId != null) {
        try {
          _selectedCreditCard = _creditCards.firstWhere(
            (c) => c.id == creditCardId,
          );
        } catch (e) {
          _selectedCreditCard = null;
        }
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

  void submit() async {
    setState(() => _formError = null);
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final data = TransactionFormData(
      amount: double.parse(_amountController.text),
      title: _titleController.text.trim(),
      categoryId: _selectedCategory!.id!,
      date: _selectedDate,
      isIncome: _isIncome,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      creditCardId: !_isIncome && _selectedCreditCard != null
          ? _selectedCreditCard!.id
          : null,
      isRecurring: _isRecurring,
      recurringInterval: _isRecurring
          ? int.parse(_recurringIntervalController.text)
          : 1,
      recurringPeriod: _recurringPeriod,
    );

    try {
      await widget.onSave(data);
    } catch (e) {
      if (mounted) {
        setState(() {
          _formError = e.toString().replaceAll('Exception: ', '');
        });
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

  @override
  Widget build(BuildContext context) {
    // If both are null, it's Add mode. If one is not null, it's Edit mode.
    final isEditMode =
        widget.transaction != null || widget.recurringTransaction != null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_formError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _formError!,
                style: const TextStyle(color: AppColors.expense, fontSize: 14),
              ),
            ),
          // Income / Expense Toggle
          TransactionTypeToggle(
            isIncome: _isIncome,
            onChanged: (value) => setState(() => _isIncome = value),
          ),
          const SizedBox(height: 32.0),

          CustomValidatedField(
            label: 'Amount'.cased(context),
            validator: () => Validators.greaterThanZero(_amountController.text),
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          CustomValidatedField(
            label: 'Title'.cased(context),
            validator: () => Validators.required(_titleController.text),
            child: TextField(
              controller: _titleController,
              decoration: _getInputDecoration(
                hintText: 'e.g. Groceries'.cased(context),
              ),
            ),
          ),

          CustomValidatedField(
            validator: () => Validators.required(
              _selectedCategory?.name,
              'Please select a valid category.',
            ),
            child: _isLoadingCategories
                ? const Center(child: CircularProgressIndicator())
                : CategoryDropdown(
                    label: 'Category'.cased(context),
                    hintText: 'Select a category...'.cased(context),
                    items: _categories,
                    selectedItem: _selectedCategory,
                    onChanged: (val) => setState(() => _selectedCategory = val),
                    onEditPressed: () {
                      SlideUpModal.showCustom(
                        context: context,
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
                    label: _isRecurring
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

          if (!_isIncome)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: CustomDropdownField<CreditCard?>(
                label: 'Credit Card'.cased(context),
                selectedItem: _selectedCreditCard,
                items: [null, ..._creditCards],
                displayText: (card) =>
                    card == null ? 'None'.cased(context) : card.name,
                onChanged: (val) => setState(() => _selectedCreditCard = val),
              ),
            ),

          // Recurring Transaction Logic
          if (!isEditMode) ...[
            // Add Mode: Show toggle to turn on/off recurring
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recurring transaction'.cased(context),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      CustomSwitch(
                        value: _isRecurring,
                        onChanged: (val) => setState(() => _isRecurring = val),
                      ),
                    ],
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return SizeTransition(
                            sizeFactor: animation,
                            alignment: const Alignment(-1.0, -1.0),
                            child: child,
                          );
                        },
                    child: _isRecurring
                        ? SizedBox(
                            key: const ValueKey('recurring_fields'),
                            width: double.infinity,
                            child: Column(
                              children: [
                                const SizedBox(height: 16.0),
                                _buildRecurringInputs(context),
                              ],
                            ),
                          )
                        : const SizedBox(
                            key: ValueKey('empty_fields'),
                            width: double.infinity,
                          ),
                  ),
                ],
              ),
            ),
          ] else if (widget.recurringTransaction != null) ...[
            // Edit Mode (Recurring): Show frequency without toggle
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
                  _buildRecurringInputs(context),
                ],
              ),
            ),
          ],

          CustomValidatedField(
            label: 'Note (optional)'.cased(context),
            child: TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: _getInputDecoration(
                hintText: 'Add details...'.cased(context),
              ).copyWith(contentPadding: const EdgeInsets.all(16.0)),
            ),
          ),

          if (widget.showSaveButton)
            SizedBox(
              width: double.infinity,
              height: 56.0,
              child: ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: Text(
                  'Save Transaction'.cased(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecurringInputs(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('Every'.cased(context), style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 16.0),
        Expanded(
          flex: 1,
          child: CustomValidatedField(
            padding: EdgeInsets.zero,
            validator: () =>
                Validators.greaterThanZero(_recurringIntervalController.text),
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
            onChanged: (val) => setState(() => _recurringPeriod = val),
          ),
        ),
      ],
    );
  }
}
