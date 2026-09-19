import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';

class CustomSegmentOption<T> {
  final T value;
  final String label;
  final Color activeColor;

  const CustomSegmentOption({
    required this.value,
    required this.label,
    required this.activeColor,
  });
}

class CustomSegmentToggle<T> extends StatelessWidget {
  final List<CustomSegmentOption<T>> options;
  final T activeValue;
  final ValueChanged<T> onChanged;
  final bool hasShadow;
  final Color backgroundColor;

  const CustomSegmentToggle({
    super.key,
    required this.options,
    required this.activeValue,
    required this.onChanged,
    this.hasShadow = false,
    this.backgroundColor = const Color(0x269E9E9E), // AppColors.grey.withValues(alpha: 0.15)
  });

  @override
  Widget build(BuildContext context) {
    int activeIndex = options.indexWhere((o) => o.value == activeValue);
    if (activeIndex == -1) activeIndex = 0;

    final activeOption = options[activeIndex];

    final double xAlign = options.length > 1
        ? -1.0 + (2.0 * activeIndex) / (options.length - 1)
        : 0.0;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            alignment: Alignment(xAlign, 0),
            child: FractionallySizedBox(
              widthFactor: options.isEmpty ? 1.0 : 1.0 / options.length,
              child: Container(
                decoration: BoxDecoration(
                  color: activeOption.activeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Row(
            children: options.map((option) {
              final isSelected = activeValue == option.value;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(option.value),
                  child: Container(
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14,
                        color: isSelected ? option.activeColor : AppColors.grey,
                      ),
                      child: Text(option.label.cased(context)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
