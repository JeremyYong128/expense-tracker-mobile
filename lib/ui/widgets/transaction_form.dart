import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/models/transaction.dart' as t;
import 'package:expense_tracker_mobile/models/recurring_transaction.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/models/credit_card.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_date_picker_field.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_time_picker_field.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_dropdown_field.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_type_toggle.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_switch.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_validated_field.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/utils/validators.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/providers/credit_card_provider.dart';
import 'package:expense_tracker_mobile/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker_mobile/core/exceptions.dart';
import 'package:expense_tracker_mobile/utils/logger.dart';

class TransactionFormData {
  final double amount;
  final String title;
  final int categoryId;
  final DateTime date;
  final bool isIncome;
  final String? note;
  final int? creditCardId;
  final int? recurringId;
  final bool isRecurring;
  final int recurringInterval;
  final String recurringPeriod;
  final double? rewardAmount;

  TransactionFormData({
    required this.amount,
    required this.title,
    required this.categoryId,
    required this.date,
    required this.isIncome,
    this.note,
    this.creditCardId,
    this.recurringId,
    required this.isRecurring,
    required this.recurringInterval,
    required this.recurringPeriod,
    this.rewardAmount,
  });
}

class TransactionForm extends StatefulWidget {
  final t.Transaction? transaction;
  final RecurringTransaction? recurringTransaction;
  final bool showSaveButton;
  final ScrollController? scrollController;
  final Future<void> Function(TransactionFormData data) onSave;
  final bool initialIsRecurring;

  const TransactionForm({
    super.key,
    this.transaction,
    this.recurringTransaction,
    this.showSaveButton = true,
    this.scrollController,
    required this.onSave,
    this.initialIsRecurring = false,
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

  late final TextEditingController _rewardAmountController;
  bool _hasRewards = false;
  bool _lockRewardRecalculation = false;

  static const List<String> _recurringPeriods = [
    'Day(s)',
    'Week(s)',
    'Month(s)',
    'Year(s)',
  ];

  List<Category> _categories = [];
  List<CreditCard> _creditCards = [];
  List<RecurringTransaction> _recurringTransactions = [];
  CreditCard? _selectedCreditCard;
  RecurringTransaction? _selectedRecurring;
  bool _isLoadingCategories = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    double? initialAmount;
    String? initialTitle;
    String? initialNote;
    DateTime? initialDate;
    bool initialIsIncome = false;
    double? initialRewardAmount;
    int initialInterval = 1;
    String initialPeriod = _recurringPeriods[2];

    if (widget.recurringTransaction != null) {
      final rt = widget.recurringTransaction!;
      initialAmount = rt.amount;
      initialTitle = rt.title;
      initialNote = rt.note;
      initialDate = rt.startDate;
      initialIsIncome = rt.isIncome;
      initialRewardAmount = rt.rewardAmount;
      initialInterval = rt.interval;
      initialPeriod = rt.period;
    } else if (widget.transaction != null) {
      final t = widget.transaction!;
      initialAmount = t.amount;
      initialTitle = t.title;
      initialNote = t.note;
      initialDate = t.date;
      initialIsIncome = t.isIncome;
      initialRewardAmount = t.rewardAmount;
    }

    _isIncome = initialIsIncome;
    _selectedDate = initialDate ?? DateTime.now();
    _amountController = TextEditingController(text: initialAmount?.toStringAsFixed(2) ?? '');
    _titleController = TextEditingController(text: initialTitle ?? '');
    _noteController = TextEditingController(text: initialNote ?? '');
    
    _isRecurring = widget.recurringTransaction != null || widget.initialIsRecurring;
    _recurringIntervalController = TextEditingController(text: initialInterval.toString());
    _recurringPeriod = initialPeriod;
    
    _hasRewards = initialRewardAmount != null;
    _lockRewardRecalculation = initialRewardAmount != null;
    _rewardAmountController = TextEditingController(text: initialRewardAmount?.toStringAsFixed(2) ?? '');

    _amountController.addListener(_onAmountChanged);

    _loadCategories();
  }

  void _onAmountChanged() {
    if (_lockRewardRecalculation ||
        !_hasRewards ||
        _selectedCreditCard == null ||
        _isIncome)
      return;

    final amtStr = _amountController.text;
    final amt = double.tryParse(amtStr) ?? 0.0;

    double reward = 0;
    if (_selectedCreditCard!.rewardType == 'Cashback') {
      reward = amt * (_selectedCreditCard!.rewardRate / 100);
    } else {
      reward = amt * _selectedCreditCard!.rewardRate;
    }

    _rewardAmountController.text = reward.toStringAsFixed(2);
  }

  void _onRecurringSelected(RecurringTransaction? val) {
    setState(() {
      _selectedRecurring = val;
      if (val != null) {
        if (_selectedCreditCard == null && val.creditCardId != null) {
          try {
            _selectedCreditCard = _creditCards.firstWhere((c) => c.id == val.creditCardId);
            if (_selectedCreditCard!.rewardRate > 0) {
              _hasRewards = true;
              if (val.rewardAmount != null) {
                _rewardAmountController.text = val.rewardAmount!.toStringAsFixed(2);
                _lockRewardRecalculation = true;
              }
            }
          } catch (e) {}
        }
        
        if (_amountController.text.trim().isEmpty || _amountController.text == '0.00' || _amountController.text == '0') {
          if (val.rewardAmount == null) {
            _lockRewardRecalculation = false;
          }
          _amountController.text = val.amount.toStringAsFixed(2);
        }

        if (_titleController.text.trim().isEmpty) {
          _titleController.text = val.title;
        }

        if (_noteController.text.trim().isEmpty && val.note != null) {
          _noteController.text = val.note!;
        }

        try {
          _selectedCategory = _categories.firstWhere((c) => c.id == val.categoryId);
        } catch (e) {}
      }
    });
  }

  void _loadCategories() {
    final categories = context.read<CategoryProvider>().categories;
    final creditCards = context.read<CreditCardProvider>().creditCards;
    final recTxs = context.read<RecurringTransactionProvider>().transactions;
    setState(() {
      _recurringTransactions = recTxs;

      int? catId;
      if (widget.recurringTransaction != null) {
        catId = widget.recurringTransaction!.categoryId;
      } else if (widget.transaction != null) {
        catId = widget.transaction!.categoryId;
      }

      int? ccId;
      if (widget.recurringTransaction != null) {
        ccId = widget.recurringTransaction!.creditCardId;
      } else if (widget.transaction != null) {
        ccId = widget.transaction!.creditCardId;
      }

      _categories = categories.where((c) {
        return c.isActive || c.id == catId;
      }).toList();

      _creditCards = creditCards.where((c) {
        return c.isActive || c.id == ccId;
      }).toList();
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

      if (ccId != null) {
        try {
          _selectedCreditCard = _creditCards.firstWhere(
            (c) => c.id == ccId,
          );
        } catch (e) {
          _selectedCreditCard = null;
        }
      }

      int? recurringId;
      if (widget.transaction != null) {
        recurringId = widget.transaction!.recurringId;
      }

      if (recurringId != null) {
        try {
          _selectedRecurring = _recurringTransactions.firstWhere(
            (r) => r.id == recurringId,
          );
        } catch (e) {
          _selectedRecurring = null;
        }
      }
    });
  }

  List<Category> get _filteredCategories {
    return _categories
        .where((c) => _isIncome ? c.isIncome : c.isExpense)
        .toList();
  }

  List<RecurringTransaction> get _filteredRecurringTransactions {
    return _recurringTransactions
        .where((r) => _isIncome ? r.isIncome : !r.isIncome)
        .toList();
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _rewardAmountController.dispose();
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
      recurringId: !_isRecurring && _selectedRecurring != null
          ? _selectedRecurring!.id
          : null,
      isRecurring: _isRecurring,
      recurringInterval: _isRecurring
          ? int.parse(_recurringIntervalController.text)
          : 1,
      recurringPeriod: _recurringPeriod,
      rewardAmount:
          (!_isIncome &&
              _selectedCreditCard != null &&
              _hasRewards &&
              _rewardAmountController.text.isNotEmpty)
          ? double.tryParse(_rewardAmountController.text)
          : null,
    );

    try {
      await widget.onSave(data);
    } on DatabaseValidationException catch (e) {
      if (mounted) {
        setState(() {
          _formError = e.message;
        });
        widget.scrollController?.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e, stack) {
      AppLogger.error('Failed to submit transaction', e, stack);
      if (mounted) {
        setState(() {
          _formError = 'An unexpected error occurred: $e';
        });
        widget.scrollController?.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
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
                style: const TextStyle(color: AppColors.error, fontSize: 14),
              ),
            ),
          // Income / Expense Toggle
          TransactionTypeToggle(
            isIncome: _isIncome,
            onChanged: (value) {
              setState(() {
                _isIncome = value;

                // Auto-select fallback category if current one is invalid
                final validCategories = _filteredCategories;
                if (_selectedCategory != null) {
                  final isValid = _isIncome
                      ? _selectedCategory!.isIncome
                      : _selectedCategory!.isExpense;
                  if (!isValid) {
                    _selectedCategory = validCategories.isNotEmpty
                        ? validCategories.first
                        : null;
                  }
                } else {
                  _selectedCategory = validCategories.isNotEmpty
                      ? validCategories.first
                      : null;
                }

                if (_selectedRecurring != null) {
                  final isValid = _isIncome
                      ? _selectedRecurring!.isIncome
                      : !_selectedRecurring!.isIncome;
                  if (!isValid) {
                    _selectedRecurring = null;
                  }
                }
              });
            },
          ),
          const SizedBox(height: 32.0),

          CustomValidatedField(
            label: 'Amount'.cased(context),
            validator: () => Validators.amount(_amountController.text),
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
            infoText: 'Add or edit categories under \'Manage\'.'.cased(context),
            validator: () => Validators.required(
              _selectedCategory?.name,
              'Select a valid category.',
            ),
            child: _isLoadingCategories
                ? const Center(child: CircularProgressIndicator())
                : CustomDropdownField<Category?>(
                    label: 'Category'.cased(context),
                    items: _filteredCategories,
                    selectedItem: _selectedCategory,
                    displayText: (cat) => cat?.name ?? '',
                    onChanged: (val) => setState(() => _selectedCategory = val),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomValidatedField(
                    infoText: 'Add or edit credit cards under \'Manage\'.'
                        .cased(context),
                    padding: EdgeInsets.zero,
                    child: CustomDropdownField<CreditCard?>(
                      label: 'Credit Card'.cased(context),
                      selectedItem: _selectedCreditCard,
                      items: [null, ..._creditCards],
                      displayText: (card) =>
                          card == null ? 'None'.cased(context) : card.name,
                      onChanged: (val) {
                        setState(() {
                          _selectedCreditCard = val;
                          if (val != null &&
                              val.rewardRate > 0 &&
                              !_hasRewards) {
                            _hasRewards = true;
                          }
                          _lockRewardRecalculation =
                              false; // Reset override state
                          _onAmountChanged(); // Recalculate
                        });
                      },
                    ),
                  ),

                  if (_selectedCreditCard != null &&
                      _selectedCreditCard!.rewardRate > 0) ...[
                    const SizedBox(height: 24),
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerLeft,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Eligible for rewards'.cased(context),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: CustomSwitch(
                            value: _hasRewards,
                            onChanged: (val) {
                              setState(() {
                                _hasRewards = val;
                                if (val) {
                                  _lockRewardRecalculation = false;
                                  _onAmountChanged();
                                } else {
                                  _rewardAmountController.clear();
                                }
                              });
                            },
                          ),
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
                      child: _hasRewards
                          ? Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: CustomValidatedField(
                                padding: EdgeInsets.zero,
                                validator: () => Validators.rewardAmount(
                                  _rewardAmountController.text,
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _rewardAmountController,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: _getInputDecoration(
                                          hintText: '0.00',
                                          prefixIcon: _selectedCreditCard!.rewardType == 'Cashback'
                                              ? const Icon(
                                                  Icons.attach_money,
                                                  color: AppColors.primary,
                                                )
                                              : null,
                                        ),
                                        onChanged: (_) {
                                          _lockRewardRecalculation = true;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Text(
                                      _selectedCreditCard!.rewardType ==
                                              'Cashback'
                                          ? 'cashback'
                                          : _selectedCreditCard!.rewardType
                                                .toLowerCase(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),

          // Recurrence Section
          if (!isEditMode) ...[
            // Add Mode: Unified Recurrence Section
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.centerLeft,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Save as new recurring transaction'.cased(context),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: CustomSwitch(
                          value: _isRecurring,
                          onChanged: (val) => setState(() {
                            _isRecurring = val;
                            if (val) {
                              _selectedRecurring =
                                  null; // Cannot link if creating new template
                            }
                          }),
                        ),
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
                        : SizedBox(
                            key: const ValueKey('empty_fields_or_link'),
                            width: double.infinity,
                            child: Column(
                              children: [
                                const SizedBox(height: 24.0),
                                CustomValidatedField(
                                  padding: EdgeInsets.zero,
                                  child: CustomDropdownField<RecurringTransaction?>(
                                    label:
                                        'Link to existing recurring transaction'
                                            .cased(context),
                                    items: [
                                      null,
                                      ..._filteredRecurringTransactions,
                                    ],
                                    selectedItem: _selectedRecurring,
                                    displayText: (r) =>
                                        r?.title ?? 'None'.cased(context),
                                    onChanged: _onRecurringSelected,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ] else if (widget.transaction != null) ...[
            // Edit Mode (Normal Transaction): Just show the dropdown
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: CustomValidatedField(
                infoText: 'Link to existing template (Optional)'.cased(context),
                padding: EdgeInsets.zero,
                child: CustomDropdownField<RecurringTransaction?>(
                  label: 'Recurring Transaction'.cased(context),
                  items: [null, ..._filteredRecurringTransactions],
                  selectedItem: _selectedRecurring,
                  displayText: (r) => r?.title ?? 'None'.cased(context),
                  onChanged: _onRecurringSelected,
                ),
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
