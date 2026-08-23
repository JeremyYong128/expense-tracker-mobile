import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'slide_up_modal.dart';
import '../theme/app_theme.dart';
import '../models/category.dart';
import '../utils/string_extensions.dart';
import '../utils/category_appearance.dart';

class CategoryDropdown extends StatelessWidget {
  final String label;
  final List<Category> items;
  final Category? selectedItem;
  final String? hintText;
  final ValueChanged<Category> onChanged;
  final VoidCallback onEditPressed;

  const CategoryDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItem,
    this.hintText,
    required this.onChanged,
    required this.onEditPressed,
  });

  void _showPicker(BuildContext context) {
    SlideUpModal.show(
      context: context,
      leftButtonTitle: 'Cancel',
      onLeftButtonPressed: () {
        Navigator.of(context).pop();
      },
      rightButtonTitle: 'Edit',
      onRightButtonPressed: () {
        Navigator.of(context).pop();
        onEditPressed();
      },
      heightFraction: 0.6,
      child: SafeArea(
        top: false,
        child: items.isEmpty
            ? Center(
                child: Text(
                  'No categories'.cased(context),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.grey,
                    decoration: TextDecoration.none,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final category = items[index];
                  final isSelected = selectedItem?.id == category.id;

                  return InkWell(
                    onTap: () {
                      onChanged(category);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category.color.withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              category.iconData,
                              color: category.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: AppColors.textPrimary,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check, color: category.color),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8.0),
        ],
        InkWell(
            onTap: () => _showPicker(context),
            borderRadius: BorderRadius.circular(12.0),
            child: InputDecorator(
              decoration: _getInputDecoration(),
              child: Row(
                children: [
                  if (selectedItem != null) ...[
                    Icon(
                      selectedItem!.iconData,
                      color: selectedItem!.color,
                      size: 20,
                    ),
                    const SizedBox(width: 8.0),
                  ],
                  Expanded(
                    child: Text(
                      selectedItem?.name ?? hintText ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedItem != null
                            ? AppColors.textPrimary
                            : AppColors.grey,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
