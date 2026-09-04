import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/core/exceptions.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_validated_field.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:expense_tracker_mobile/utils/validators.dart';
import 'package:expense_tracker_mobile/ui/widgets/category_type_toggle.dart';
import 'package:expense_tracker_mobile/utils/logger.dart';
import 'package:expense_tracker_mobile/ui/widgets/color_picker.dart';

class CategoryFormModal extends StatefulWidget {
  final Category? category;
  final VoidCallback? onSaved;

  const CategoryFormModal({super.key, this.category, this.onSaved});

  @override
  State<CategoryFormModal> createState() => _CategoryFormModalState();
}

class _CategoryFormModalState extends State<CategoryFormModal> {
  late TextEditingController _nameController;
  late String _iconString;
  late String _colorHex;
  late CategoryTypeSelection _typeSelection;

  String? _formError;
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final isEditing = widget.category != null;
    _nameController = TextEditingController(
      text: isEditing ? widget.category!.name : '',
    );
    _iconString = isEditing && widget.category!.iconString != null
        ? widget.category!.iconString!
        : 'category';
    _colorHex = isEditing
        ? widget.category!.colorHex
        : AppColors.colorPaletteHexes.first;

    if (isEditing) {
      if (widget.category!.isExpense && widget.category!.isIncome) {
        _typeSelection = CategoryTypeSelection.both;
      } else if (widget.category!.isIncome) {
        _typeSelection = CategoryTypeSelection.income;
      } else {
        _typeSelection = CategoryTypeSelection.expense;
      }
    } else {
      _typeSelection = CategoryTypeSelection.expense; // default
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    setState(() => _formError = null);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    try {
      final text = _nameController.text.trim();
      final provider = context.read<CategoryProvider>();

      final isExpense =
          _typeSelection == CategoryTypeSelection.expense ||
          _typeSelection == CategoryTypeSelection.both;
      final isIncome =
          _typeSelection == CategoryTypeSelection.income ||
          _typeSelection == CategoryTypeSelection.both;

      if (widget.category != null) {
        final updatedCategory = Category(
          id: widget.category!.id,
          name: text,
          colorHex: _colorHex,
          iconString: _iconString,
          isActive: widget.category!.isActive,
          isExpense: isExpense,
          isIncome: isIncome,
        );
        await provider.updateCategory(updatedCategory);
      } else {
        final newCategory = Category(
          name: text,
          colorHex: _colorHex,
          iconString: _iconString,
          isActive: true,
          isExpense: isExpense,
          isIncome: isIncome,
        );
        await provider.addCategory(newCategory);
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
    } catch (e, stack) {
      AppLogger.error('Failed to save category', e, stack);
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
      leftButtonTitle: 'Cancel',
      onLeftButtonPressed: () => Navigator.of(context).pop(),
      rightButtonTitle: 'Save',
      onRightButtonPressed: _saveCategory,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_formError != null) ...[
                Text(
                  _formError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],

              // 0. Type Selection
              CategoryTypeToggle(
                selection: _typeSelection,
                onChanged: (val) => setState(() => _typeSelection = val),
              ),
              const SizedBox(height: 24),

              // 1. Icon Preview
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.getColorFromHex(
                      _colorHex,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Category.getIconData(_iconString),
                    color: AppColors.getColorFromHex(_colorHex),
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // 2. Name Text Field
              CustomValidatedField(
                label: 'Category Name'.cased(context),
                validator: () {
                  final text = _nameController.text.trim();
                  return Validators.required(text);
                },
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  onSubmitted: (_) => _saveCategory(),
                ),
              ),

              // 3. Colors Picker
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

              // 4. Icons Picker
              Text(
                'Icon'.cased(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: Category.iconNames.map((iconName) {
                  final isSelected = _iconString == iconName;
                  final iconData = Category.getIconData(iconName);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _iconString = iconName;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        iconData,
                        color: isSelected ? AppColors.primary : AppColors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
