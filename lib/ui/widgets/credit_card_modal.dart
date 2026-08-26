import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/models/credit_card.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/credit_card_provider.dart';
import 'package:expense_tracker_mobile/core/exceptions.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/utils/validators.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_validated_field.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_dropdown_field.dart';

class CreditCardModal extends StatefulWidget {
  final CreditCard? card;
  final VoidCallback? onSaved;

  const CreditCardModal({super.key, this.card, this.onSaved});

  @override
  State<CreditCardModal> createState() => _CreditCardModalState();
}

class _CreditCardModalState extends State<CreditCardModal> {
  late TextEditingController _nameController;
  late TextEditingController _rateController;
  late String _rewardType;
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _saveCreditCard() async {
    setState(() => _formError = null);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    try {
      final name = _nameController.text.trim();
      final rateText = _rateController.text.trim();

      final rate = double.parse(rateText);

      final newCard = CreditCard(
        id: widget.card?.id,
        name: name,
        rewardType: _rewardType,
        rewardRate: rate,
      );

      if (widget.card != null) {
        await context.read<CreditCardProvider>().updateCreditCard(newCard);
      } else {
        await context.read<CreditCardProvider>().addCreditCard(newCard);
      }

      if (mounted) {
        widget.onSaved?.call();
        Navigator.pop(context);
      }
    } on DatabaseValidationException catch (e) {
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
    } catch (e) {
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
      onRightButtonPressed: _saveCreditCard,
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
                      color: AppColors.expense,
                      fontSize: 14,
                    ),
                  ),
                ),
              CustomValidatedField(
                label: 'Card Name'.cased(context),
                validator: () {
                  final text = _nameController.text.trim();
                  if (text.toLowerCase() == 'none') {
                    return 'Card name cannot be "None"';
                  }
                  return Validators.required(text);
                },
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
                  onSubmitted: (_) => _saveCreditCard(),
                ),
              ),
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
              CustomValidatedField(
                label: _rewardType == 'Cashback'
                    ? 'Reward Rate (%)'.cased(context)
                    : 'Reward Rate (per \$)'.cased(context),
                validator: () => _rewardType == 'None'
                    ? null
                    : Validators.greaterThanZero(_rateController.text),
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
                  onSubmitted: (_) => _saveCreditCard(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
