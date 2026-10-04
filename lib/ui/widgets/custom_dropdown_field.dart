import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final List<T> items;
  final T selectedItem;
  final ValueChanged<T> onChanged;
  final String Function(T) displayText;
  final bool enabled;
  final String? hintText;

  const CustomDropdownField({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.displayText,
    this.enabled = true,
    this.hintText,
  });

  void _showPicker(BuildContext context) {
    if (!enabled || items.isEmpty) return;

    int selectedIndex = items.indexOf(selectedItem);
    int tempSelectedIndex = selectedIndex == -1 ? 0 : selectedIndex;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 280,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Header with Cancel and Done buttons
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          'Cancel'.cased(context),
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          'Done'.cased(context),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          onChanged(items[tempSelectedIndex]);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40.0,
                    scrollController: FixedExtentScrollController(
                      initialItem: tempSelectedIndex,
                    ),
                    onSelectedItemChanged: (int index) {
                      tempSelectedIndex = index;
                    },
                    children: items.map((T value) {
                      return Center(
                        child: Text(
                          displayText(value),
                          style: const TextStyle(
                            fontSize: 20,
                            color: AppColors.textPrimary,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: enabled ? AppColors.white : Colors.grey.shade200,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: enabled ? () => _showPicker(context) : null,
          borderRadius: BorderRadius.circular(12.0),
          child: InputDecorator(
            decoration: _getInputDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedItem == null && hintText != null
                        ? hintText!
                        : displayText(selectedItem),
                    style: selectedItem == null && hintText != null
                        ? AppStyles.formPlaceholderText
                        : AppStyles.formOptionText(enabled),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: enabled ? AppColors.primary : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
