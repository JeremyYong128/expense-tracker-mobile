import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'slide_up_modal.dart';
import '../utils/category_appearance.dart';
import '../theme/app_theme.dart';
import '../utils/string_extensions.dart';

class CategoryAppearancePicker extends StatefulWidget {
  final String initialIcon;
  final String initialColorHex;
  final Function(String icon, String colorHex) onSave;

  const CategoryAppearancePicker({
    Key? key,
    required this.initialIcon,
    required this.initialColorHex,
    required this.onSave,
  }) : super(key: key);

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
      heightFraction: 0.75,
      child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Selection Preview
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: CategoryAppearance.getColorFromHex(_selectedColorHex).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CategoryAppearance.getIconData(_selectedIcon),
                        color: CategoryAppearance.getColorFromHex(_selectedColorHex),
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Colors
                  Text(
                    'Colors'.cased(context),
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
                      final isSelected = _selectedColorHex == hex;
                      final color = CategoryAppearance.getColorFromHex(hex);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColorHex = hex;
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
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Icons
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
                      final isSelected = _selectedIcon == iconName;
                      final iconData = CategoryAppearance.getIconData(iconName);
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
