import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as flutter_colorpicker;
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_field.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';

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
    HSVColor currentHsvColor = HSVColor.fromColor(pickerColor);
    String initialHex = pickerColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2, 8).toUpperCase();
    final TextEditingController hexController = TextEditingController(text: initialHex);

    SlideUpModal.show(
      context: context,
      leftButtonTitle: 'Cancel'.localized(context).cased(context),
      onLeftButtonPressed: () => Navigator.pop(context),
      rightButtonTitle: 'Save'.localized(context).cased(context),
      onRightButtonPressed: () {
        String hex = '#${pickerColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2, 8).toUpperCase()}';
        onColorSelected(hex);
        Navigator.pop(context);
      },
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomField(
                  label: 'Custom Colour'.localized(context).cased(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Square Shade Picker
                      AspectRatio(
                        aspectRatio: 1.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: flutter_colorpicker.ColorPickerArea(
                            currentHsvColor,
                            (HSVColor color) {
                              setState(() {
                                currentHsvColor = color;
                                pickerColor = color.toColor();
                                final newHex = pickerColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2, 8).toUpperCase();
                                if (hexController.text != newHex) {
                                  hexController.text = newHex;
                                }
                              });
                            },
                            flutter_colorpicker.PaletteType.hsv,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Horizontal Hue Slider
                      SizedBox(
                        height: 40,
                        child: flutter_colorpicker.ColorPickerSlider(
                          flutter_colorpicker.TrackType.hue,
                          currentHsvColor,
                          (HSVColor color) {
                            setState(() {
                              currentHsvColor = color;
                              pickerColor = color.toColor();
                              final newHex = pickerColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2, 8).toUpperCase();
                              if (hexController.text != newHex) {
                                hexController.text = newHex;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                CustomField(
                  label: 'Hex'.localized(context).cased(context),
                  child: TextField(
                    controller: hexController,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
                    ],
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                      hintText: '000000',
                      hintStyle: const TextStyle(color: AppColors.grey),
                      prefixText: '#',
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                    ),
                    onChanged: (val) {
                      if (val.length == 6) {
                        final color = AppColors.getColorFromHex('#$val');
                        setState(() {
                          pickerColor = color;
                          currentHsvColor = HSVColor.fromColor(pickerColor);
                        });
                      }
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          );
        },
      ),
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
    final isCustomColorSelected = !AppColors.colorPaletteHexes.contains(
      selectedColorHex,
    );
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

    return Wrap(spacing: 12, runSpacing: 12, children: colorWidgets);
  }
}
