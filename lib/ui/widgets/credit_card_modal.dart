import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/models/credit_card.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/utils/validators.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_validated_field.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';

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
  String? _formError;
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
        setState(() {
          _formError = e.toString().replaceAll('Exception: ', '');
        });
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    labelText: 'Card Name'.cased(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _rewardType,
                decoration: InputDecoration(
                  labelText: 'Reward Type'.cased(context),
                ),
                items: ['Cashback', 'Miles', 'Points']
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.cased(context)),
                      ),
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
