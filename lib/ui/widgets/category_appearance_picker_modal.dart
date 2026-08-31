import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/color_picker.dart';

class CategoryAppearancePicker extends StatefulWidget {
  final String initialIcon;
  final String initialColorHex;
  final Function(String icon, String colorHex) onSave;

  const CategoryAppearancePicker({
    super.key,
    required this.initialIcon,
    required this.initialColorHex,
    required this.onSave,
  });

  @override
  State<CategoryAppearancePicker> createState() =>
      _CategoryAppearancePickerState();
}

class _CategoryAppearancePickerState extends State<CategoryAppearancePicker> {
  late String _selectedIcon;
  late String _selectedColorHex;

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.initialIcon;
    _selectedColorHex = widget.initialColorHex;
  }

  @override
  Widget build(BuildContext context) {
    return SlideUpModal(
      leftButtonTitle: 'Cancel',
      onLeftButtonPressed: () => Navigator.of(context).pop(),
      rightButtonTitle: 'Save',
      onRightButtonPressed: () {
        widget.onSave(_selectedIcon, _selectedColorHex);
        Navigator.of(context).pop();
      },

      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Selection Preview
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.getColorFromHex(
                    _selectedColorHex,
                  ).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Category.getIconData(_selectedIcon),
                  color: AppColors.getColorFromHex(_selectedColorHex),
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Colors
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
              selectedColorHex: _selectedColorHex,
              onColorSelected: (hex) {
                setState(() {
                  _selectedColorHex = hex;
                });
              },
            ),

            const SizedBox(height: 32),

            // Icons
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
                final isSelected = _selectedIcon == iconName;
                final iconData = Category.getIconData(iconName);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconName;
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
