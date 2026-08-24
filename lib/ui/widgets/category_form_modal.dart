import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/core/exceptions.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_validated_field.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:expense_tracker_mobile/utils/category_appearance.dart';
import 'package:expense_tracker_mobile/utils/validators.dart';

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
    _colorHex = isEditing && widget.category!.colorHex != null
        ? widget.category!.colorHex!
        : '#9E9E9E';
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

      if (widget.category != null) {
        final updatedCategory = Category(
          id: widget.category!.id,
          name: text,
          colorHex: _colorHex,
          iconString: _iconString,
          isActive: widget.category!.isActive,
        );
        await provider.updateCategory(updatedCategory);
      } else {
        final newCategory = Category(
          name: text,
          colorHex: _colorHex,
          iconString: _iconString,
          isActive: true,
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

  Future<void> _deleteCategory() async {
    if (widget.category == null) return;

    try {
      final provider = context.read<CategoryProvider>();
      await provider.deleteCategory(widget.category!.id!);

      if (mounted) {
        widget.onSaved?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete category'.cased(context)),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

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
                  style: const TextStyle(
                    color: AppColors.expense,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 1. Icon Preview
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: CategoryAppearance.getColorFromHex(
                      _colorHex,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    CategoryAppearance.getIconData(_iconString),
                    color: CategoryAppearance.getColorFromHex(_colorHex),
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
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (_) => _saveCategory(),
                ),
              ),

              // 3. Colors Picker
              Text(
                'Colours'.localized(context).cased(context),
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
                children: CategoryAppearance.colorHexes.map((hex) {
                  final isSelected = _colorHex == hex;
                  final color = CategoryAppearance.getColorFromHex(hex);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _colorHex = hex;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 4. Icons Picker
              Text(
                'Icons'.cased(context),
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
                children: CategoryAppearance.iconNames.map((iconName) {
                  final isSelected = _iconString == iconName;
                  final iconData = CategoryAppearance.getIconData(iconName);
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
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(
                        iconData,
                        color: isSelected ? AppColors.primary : AppColors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (isEditing) ...[
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  height: 56.0,
                  child: ElevatedButton(
                    onPressed: _deleteCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: Text(
                      'Delete Category'.cased(context),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
