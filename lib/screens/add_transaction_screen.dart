import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_date_picker_field.dart';
import '../widgets/custom_time_picker_field.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/custom_category_dropdown_field.dart';
import '../models/category.dart';
import '../services/data_service.dart';
import '../widgets/manage_categories_modal.dart';
import '../widgets/transaction_type_toggle.dart';
import '../widgets/custom_switch.dart';
import '../utils/string_extensions.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool _isIncome = false;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  static const List<String> _recurringPeriods = [
    'Day(s)',
    'Week(s)',
    'Month(s)',
    'Year(s)',
  ];

  final TextEditingController _recurringIntervalController =
      TextEditingController(text: '1');
  String _recurringPeriod = _recurringPeriods[2];
  List<Category> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await DataService.getCategories();
    setState(() {
      _categories = categories.where((c) => c.isActive).toList();
      _isLoadingCategories = false;
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
      await DataService.addTransaction(
        amountText: _amountController.text,
        title: _titleController.text,
        date: _selectedDate,
        category: _selectedCategory,
        isIncome: _isIncome,
        isRecurring: _isRecurring,
        recurringIntervalText: _recurringIntervalController.text,
        recurringPeriod: _recurringPeriod,
        note: _noteController.text,
      );

      // Show success and reset form
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction added successfully!'.cased(context)),
          ),
        );
        _amountController.clear();
        _titleController.clear();
        _noteController.clear();
        setState(() {
          _selectedCategory = null;
          _isRecurring = false;
          _recurringIntervalController.text = '1';
        });
      }
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
    return SingleChildScrollView(
      padding: AppStyles.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Income / Expense Toggle
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                : CustomCategoryDropdownField(
                    label: 'Category'.cased(context),
                    hintText: 'Select a category...'.cased(context),
                    items: _categories,
                    selectedItem: _selectedCategory,
                    onChanged: (val) => setState(() => _selectedCategory = val),
                    onManagePressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => ManageCategoriesModal(
                          initialCategories: _categories,
                          onCategoriesUpdated: (newCategories) {
                            setState(() {
                              _categories = newCategories;
                              if (_selectedCategory != null &&
                                  !_categories.any(
                                    (c) =>
                                        c.id == _selectedCategory!.id &&
                                        c.name == _selectedCategory!.name,
                                  )) {
                                _selectedCategory = null;
                              }
                            });
                          },
                          onCategorySelected: (category) {
                            setState(() {
                              _selectedCategory = category;
                            });
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
                    label: 'Date'.cased(context),
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
          // Recurring Transaction Toggle
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
                                        controller:
                                            _recurringIntervalController,
                                        keyboardType: TextInputType.number,
                                        decoration: _getInputDecoration(
                                          hintText: '1',
                                        ),
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
                                      onChanged: (val) => setState(
                                        () => _recurringPeriod = val,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 56.0,
            child: ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              child: Text(
                'Add transaction'.cased(context),
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
}
