import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';

class ExpandableSelectionItem<T> {
  final T value;
  final String title;
  final Widget? expandedWidget;

  ExpandableSelectionItem({
    required this.value,
    required this.title,
    this.expandedWidget,
  });
}

class ExpandableSelectionList<T> extends StatelessWidget {
  final List<ExpandableSelectionItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  const ExpandableSelectionList({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isSelected = selectedValue == item.value;
        final isFirst = index == 0;
        final isLast = index == items.length - 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => onChanged(item.value),
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: EdgeInsets.only(
                  top: isFirst ? 0.0 : 8.0,
                  bottom: isLast ? 0.0 : 8.0,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected ? AppColors.primary : AppColors.grey,
                      size: 24.0,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppStyles.formOptionText(isSelected, boldWhenSelected: true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isSelected && item.expandedWidget != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        left:
                            36.0, // Indent to align with the text, past the radio button
                        top: isLast ? 12.0 : 4.0,
                        bottom: 8.0,
                        right: 0.0,
                      ),
                      child: item.expandedWidget!,
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ],
        );
      }).toList(),
    );
  }
}
