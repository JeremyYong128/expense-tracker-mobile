import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T selectedItem;
  final ValueChanged<T> onChanged;
  final String Function(T) displayText;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.displayText,
  });

  void _showPicker(BuildContext context) {
    int selectedIndex = items.indexOf(selectedItem);
    if (selectedIndex == -1) selectedIndex = 0;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 280,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Header with Done button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          'Done'.cased(context),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40.0,
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedIndex,
                    ),
                    onSelectedItemChanged: (int index) {
                      onChanged(items[index]);
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
                Expanded(
                  child: Text(
                    displayText(selectedItem),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
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
