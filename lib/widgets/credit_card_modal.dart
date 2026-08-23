import 'package:flutter/material.dart';
import '../models/credit_card.dart';
import '../services/data_service.dart';
import '../utils/string_extensions.dart';
import '../utils/validators.dart';
import '../widgets/custom_validated_field.dart';
import '../theme/app_theme.dart';
import 'slide_up_modal.dart';

class CreditCardModal extends StatefulWidget {
  final CreditCard? card;
  final VoidCallback onSaved;

  const CreditCardModal({super.key, this.card, required this.onSaved});

  @override
  State<CreditCardModal> createState() => _CreditCardModalState();
}

class _CreditCardModalState extends State<CreditCardModal> {
  late TextEditingController _nameController;
  late TextEditingController _rateController;
  late String _rewardType;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final isEditing = widget.card != null;
    _nameController = TextEditingController(
      text: isEditing ? widget.card!.name : '',
    );
    _rateController = TextEditingController(
      text: isEditing ? widget.card!.rewardRate.toString() : '',
    );
    _rewardType = isEditing ? widget.card!.rewardType : 'Cashback';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _saveCreditCard() async {
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
        await DataService.updateCreditCard(newCard);
      } else {
        await DataService.addCreditCard(newCard);
      }

      if (mounted) {
        widget.onSaved();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.expense,
          ),
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
      heightFraction: 0.8,
      onRightButtonPressed: _saveCreditCard,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  decoration: InputDecoration(labelText: 'Card Name'.cased(context)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _rewardType,
                decoration: InputDecoration(labelText: 'Reward Type'.cased(context)),
                items: ['Cashback', 'Miles', 'Points']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type.cased(context))),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _rewardType = value);
                  }
                },
              ),
              CustomValidatedField(
                label: _rewardType == 'Cashback'
                    ? 'Reward Rate (%)'.cased(context)
                    : 'Reward Rate (per \$)'.cased(context),
                validator: () =>
                    Validators.greaterThanZero(_rateController.text),
                child: TextField(
                  controller: _rateController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: _rewardType == 'Cashback'
                        ? 'Reward Rate (%)'.cased(context)
                        : 'Reward Rate (per \$)'.cased(context),
                  ),
                ),
              ),
              // Add bottom padding to account for keyboard
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
            ],
          ),
        ),
      ),
    );
  }
}
