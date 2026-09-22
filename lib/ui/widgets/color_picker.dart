import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';

class ColorPicker extends StatelessWidget {
  final String selectedColorHex;
  final ValueChanged<String> onColorSelected;

  const ColorPicker({
    super.key,
    required this.selectedColorHex,
    required this.onColorSelected,
  });

  void _showCustomColorPicker(BuildContext context) {
    Color pickerColor = AppColors.getColorFromHex(selectedColorHex);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Custom Color',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                HueRingPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (Color color) {
                    pickerColor = color;
                  },
                  enableAlpha: false,
                  displayThumbColor: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Select',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      // Convert Color to hex string #RRGGBB
                      String hex = '#${pickerColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2, 8).toUpperCase()}';
                      onColorSelected(hex);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> colorWidgets = AppColors.colorPaletteHexes.map((hex) {
      final isSelected = selectedColorHex == hex;
      final color = AppColors.getColorFromHex(hex);
      return GestureDetector(
        onTap: () => onColorSelected(hex),
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
              ? const Icon(Icons.check, color: AppColors.white, size: 20)
              : null,
        ),
      );
    }).toList();

    // Check if the current selected color is a custom color
    final isCustomColorSelected =
        !AppColors.colorPaletteHexes.contains(selectedColorHex);
    final customColor = isCustomColorSelected
        ? AppColors.getColorFromHex(selectedColorHex)
        : AppColors.white;

    colorWidgets.add(
      GestureDetector(
        onTap: () => _showCustomColorPicker(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: customColor,
            shape: BoxShape.circle,
            border: isCustomColorSelected
                ? Border.all(color: AppColors.primary, width: 3)
                : Border.all(color: AppColors.border, width: 2),
          ),
          child: Icon(
            isCustomColorSelected ? Icons.check : Icons.palette_outlined,
            color: isCustomColorSelected
                ? AppColors.white
                : AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colorWidgets,
    );
  }
}
