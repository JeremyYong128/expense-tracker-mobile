import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String? label;
  final String? infoText;
  final List<T> items;
  final T selectedItem;
  final ValueChanged<T> onChanged;
  final String Function(T) displayText;
  final bool enabled;

  const CustomDropdownField({
    super.key,
    this.label,
    this.infoText,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.displayText,
    this.enabled = true,
  });

  void _showPicker(BuildContext context) {
    if (!enabled || items.isEmpty) return;

    int selectedIndex = items.indexOf(selectedItem);
    if (selectedIndex == -1) selectedIndex = 0;

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
                // Header with Done button
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
                      Text(
                        label ?? '',
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
        if (label != null && label!.isNotEmpty) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label!,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              if (infoText != null) ...[
                const SizedBox(width: 8),
                JustTheTooltip(
                  content: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 220,
                      child: Text(
                        infoText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  backgroundColor: Colors.black87,
                  tailBaseWidth: 16,
                  tailLength: 8,
                  isModal: true,
                  margin: const EdgeInsets.all(16),
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8.0),
        ],
        InkWell(
          onTap: enabled ? () => _showPicker(context) : null,
          borderRadius: BorderRadius.circular(12.0),
          child: InputDecorator(
            decoration: _getInputDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText(selectedItem),
                    style: TextStyle(
                      fontSize: 16,
                      color: enabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
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
