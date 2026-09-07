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
  late String _rewardType;
  late String _colorHex;
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
    _rewardType = isEditing ? widget.card!.rewardType : 'None';
    _colorHex = isEditing
        ? widget.card!.colorHex
        : AppColors.colorPaletteHexes.first;
  }

  bool get _hasChanges {
    if (widget.card == null) {
      return true; // New card
    }

    final currentName = _nameController.text.trim();
    final currentRate = double.tryParse(_rateController.text.trim()) ?? 0.0;

    return currentName != widget.card!.name ||
        _rewardType != widget.card!.rewardType ||
        currentRate != widget.card!.rewardRate ||
        _colorHex != widget.card!.colorHex;
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
        rewardType: _rewardType,
        rateText: rateText,
        colorHex: _colorHex,
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

  @override
  Widget build(BuildContext context) {
    return SlideUpModal(
      leftButtonTitle: 'Cancel'.cased(context),
      onLeftButtonPressed: () => Navigator.pop(context),
      rightButtonTitle: 'Save'.cased(context),
      onRightButtonPressed: _saveCard,
      child: SingleChildScrollView(
        controller: _scrollController,
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
                label: 'Card Name'.cased(context),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Chase Sapphire'.cased(context),
                    hintStyle: const TextStyle(color: AppColors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (_) => _saveCard(),
                ),
              ),

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
              const SizedBox(height: 24),

              CustomDropdownField<String>(
                label: 'Reward Type'.cased(context),
                items: const ['None', 'Cashback', 'Miles', 'Points'],
                selectedItem: _rewardType,
                displayText: (type) => type.cased(context),
                onChanged: (value) {
                  setState(() {
                    _rewardType = value;
                    if (_rewardType == 'None') {
                      _rateController.text = '0.0';
                    } else if (_rateController.text == '0.0') {
                      _rateController.text = '';
                    }
                  });
                },
              ),
              const SizedBox(height: 24.0),
              CustomField(
                label: _rewardType == 'Cashback'
                    ? 'Reward Rate (%)'.cased(context)
                    : 'Reward Rate (per \$)'.cased(context),
                infoText: _rewardType != 'None'
                    ? 'This will be the default rate applied to new transactions. You can modify or remove the rewards on individual transactions later.'
                    : null,
                child: TextField(
                  controller: _rateController,
                  enabled: _rewardType != 'None',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.0',
                    hintStyle: const TextStyle(color: AppColors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: _rewardType == 'None'
                        ? Colors.grey.shade200
                        : Colors.white,
                  ),
                  onSubmitted: (_) => _saveCard(),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
