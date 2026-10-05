import 'package:flutter/material.dart' hide Card;
import 'package:expense_tracker_mobile/models/card.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/card_provider.dart';
import 'package:expense_tracker_mobile/core/exceptions.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/services/validator_service.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_field.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_dropdown_field.dart';
import 'package:expense_tracker_mobile/utils/logger.dart';
import 'package:expense_tracker_mobile/ui/widgets/color_picker.dart';
import 'package:expense_tracker_mobile/services/snackbar_service.dart';
import 'package:expense_tracker_mobile/providers/user_preferences_provider.dart';

import 'package:expense_tracker_mobile/utils/currency_utils.dart';

class CardForm extends StatefulWidget {
  final Card? card;
  final VoidCallback? onSaved;

  const CardForm({super.key, this.card, this.onSaved});

  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  late TextEditingController _nameController;
  late TextEditingController _rateController;
  String? _rewardType;
  late String _colorHex;
  String? _selectedCurrency;
  bool _saveAsDefaultCurrency = false;
  String? _formError;
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final isEditing = widget.card != null;
    _nameController = TextEditingController(
      text: isEditing ? widget.card!.name : '',
    );
    _rateController = TextEditingController(
      text: isEditing ? widget.card!.rewardRate.toString() : '0.0',
    );
    _rewardType = isEditing && widget.card!.rewardType != 'None'
        ? widget.card!.rewardType
        : null;
    _colorHex = isEditing
        ? widget.card!.colorHex
        : AppColors.colorPaletteHexes.first;
    _selectedCurrency = isEditing ? widget.card!.currencyCode : null;
  }

  bool get _hasChanges {
    if (widget.card == null) {
      return true; // New card
    }

    final currentName = _nameController.text.trim();
    final currentRate = double.tryParse(_rateController.text.trim()) ?? 0.0;

    return currentName != widget.card!.name ||
        (_rewardType ?? 'None') != widget.card!.rewardType ||
        currentRate != widget.card!.rewardRate ||
        _colorHex != widget.card!.colorHex ||
        _selectedCurrency != widget.card!.currencyCode;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _saveCard() async {
    setState(() => _formError = null);
    FocusScope.of(context).unfocus();

    if (!_hasChanges) {
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      final name = _nameController.text.trim();
      final rateText = _rateController.text.trim();

      final newCard = ValidatorService.validateCard(
        context: context,
        id: widget.card?.id,
        nameText: name,
        rewardType: _rewardType ?? 'None',
        rateText: rateText,
        colorHex: _colorHex,
        currencyCode: _selectedCurrency,
      );

      if (widget.card != null) {
        if (widget.card!.rewardRate != newCard.rewardRate) {
          final shouldProceed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Rate Changed'.cased(context)),
              content: Text(
                'Changing the reward rate only applies to new transactions. Past transactions will retain their originally calculated reward amounts.'
                    .cased(context),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Cancel'.cased(context)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('Continue'.cased(context)),
                ),
              ],
            ),
          );
          if (shouldProceed != true) return;
        }

        if (!mounted) return;
        await context.read<CardProvider>().updateCard(newCard);
        SnackBarService.showSuccess('Card updated successfully');
      } else {
        await context.read<CardProvider>().addCard(newCard);
        SnackBarService.showSuccess('Card added successfully');
      }

      if (mounted) {
        if (_saveAsDefaultCurrency) {
          context.read<UserPreferencesProvider>().setDefaultInputCurrency(
            _selectedCurrency!,
          );
        }
        widget.onSaved?.call();
        Navigator.pop(context);
      }
    } on ValidationException catch (e) {
      if (mounted) {
        setState(() {
          _formError = e.message;
        });
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e, stack) {
      AppLogger.error('Failed to save card', e, stack);
      if (mounted) {
        setState(() {
          _formError = 'An unexpected error occurred.';
        });
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  String _getRewardRateHintText(BuildContext context) {
    if (_rewardType == 'Cashback') {
      return 'Reward rate (%)'.cased(context);
    }
    if (_selectedCurrency != null) {
      if (_rewardType == 'Points') {
        return '${'Reward rate (Points per'.cased(context)} $_selectedCurrency)';
      } else if (_rewardType == 'Miles') {
        return '${'Reward rate (Miles per'.cased(context)} $_selectedCurrency)';
      }
    }
    return 'Reward rate'.cased(context);
  }

  @override
  Widget build(BuildContext context) {

    return SlideUpModal(
      leftButtonTitle: 'Cancel'.cased(context),
      onLeftButtonPressed: () => Navigator.pop(context),
      rightButtonTitle: 'Save'.cased(context),
      onRightButtonPressed: _saveCard,
      isScrollable: true,
      scrollController: _scrollController,
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
              CustomField(
                child: TextField(
                  autofocus: true,
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Name'.cased(context),
                    hintStyle: AppStyles.formPlaceholderText,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppStyles.formFieldRadius),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (_) => _saveCard(),
                ),
              ),

              CustomDropdownField<String?>(
                hintText: 'Billing Currency'.cased(context),
                items: CurrencyFormatter.commonCurrencies,
                selectedItem: _selectedCurrency,
                displayText: (currency) => currency ?? '',
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                },
              ),
              if (_selectedCurrency != null &&
                  _selectedCurrency !=
                      context.read<UserPreferencesProvider>().defaultInputCurrency)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: GestureDetector(
                    onTap: () => setState(
                      () => _saveAsDefaultCurrency = !_saveAsDefaultCurrency,
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Checkbox(
                            value: _saveAsDefaultCurrency,
                            onChanged: (val) {
                              setState(() {
                                _saveAsDefaultCurrency = val ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${'Set'.cased(context)} $_selectedCurrency ${'as default currency'.cased(context)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: AppStyles.formFieldSpacing),

              CustomDropdownField<String?>(
                hintText: 'Reward type'.cased(context),
                items: const [null, 'Cashback', 'Miles', 'Points'],
                selectedItem: _rewardType,
                displayText: (type) =>
                    type == null ? 'No rewards'.cased(context) : type.cased(context),
                onChanged: (value) {
                  setState(() {
                    _rewardType = value;
                    if (_rewardType == null) {
                      _rateController.text = '0.0';
                    } else if (_rateController.text == '0.0') {
                      _rateController.text = '';
                    }
                  });
                },
              ),
              if (_rewardType != null) ...[
                const SizedBox(height: AppStyles.formFieldSpacing),
                CustomField(
                  padding: EdgeInsets.zero,
                  child: TextField(
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: _getRewardRateHintText(context),
                      hintStyle: AppStyles.formPlaceholderText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppStyles.formFieldRadius),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                    ),
                    onSubmitted: (_) => _saveCard(),
                  ),
                ),
              ],
              const SizedBox(height: AppStyles.formFieldSpacing),

              // Colors Picker
              Text(
                'Colour'.localized(context).cased(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ColorPicker(
                selectedColorHex: _colorHex,
                onColorSelected: (hex) {
                  setState(() {
                    _colorHex = hex;
                  });
                },
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
    );
  }
}
