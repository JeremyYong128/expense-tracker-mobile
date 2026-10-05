import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';

class CustomMonthYearPicker extends StatelessWidget {
  final String? label;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;
  final bool enabled;

  const CustomMonthYearPicker({
    super.key,
    this.label,
    required this.selectedDate,
    required this.onChanged,
    this.enabled = true,
  });

  void _showPicker(BuildContext context) {
    if (!enabled) return;

    // Use a temporary variable to hold the date while scrolling
    DateTime tempDate = selectedDate;

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
                        onPressed: () {
                          onChanged(tempDate);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                              initialItem: tempDate.month - 1),
                          itemExtent: 32.0,
                          useMagnifier: true,
                          magnification: 1.2,
                          squeeze: 1.25,
                          selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(),
                          onSelectedItemChanged: (int index) {
                            tempDate = DateTime(tempDate.year, index + 1);
                          },
                          children: List<Widget>.generate(12, (int index) {
                            return Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  DateFormat('MMMM')
                                      .format(DateTime(2000, index + 1))
                                      .cased(context),
                                  style: CupertinoTheme.of(context).textTheme.dateTimePickerTextStyle,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                              initialItem: tempDate.year - 2000),
                          itemExtent: 32.0,
                          useMagnifier: true,
                          magnification: 1.2,
                          squeeze: 1.25,
                          selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(),
                          onSelectedItemChanged: (int index) {
                            tempDate = DateTime(2000 + index, tempDate.month);
                          },
                          children: List<Widget>.generate(200, (int index) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  (2000 + index).toString(),
                                  style: CupertinoTheme.of(context).textTheme.dateTimePickerTextStyle,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
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
        borderRadius: BorderRadius.circular(AppStyles.formFieldRadius),
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
          Text(
            label!,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
                    DateFormat('MMMM yyyy').format(selectedDate).cased(context),
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
