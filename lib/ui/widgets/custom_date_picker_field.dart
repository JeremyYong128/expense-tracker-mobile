import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';

class CustomDatePickerField extends StatelessWidget {

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final CupertinoDatePickerMode mode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomDatePickerField({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.minimumDate,
    this.maximumDate,
    this.mode = CupertinoDatePickerMode.date,
    this.prefixIcon = const Icon(Icons.calendar_today, color: AppColors.primary),
    this.suffixIcon,
  });

  void _showPicker(BuildContext context) {
    DateTime? minDate = minimumDate;
    DateTime? maxDate = maximumDate;

    if (minDate != null && selectedDate.isBefore(minDate)) {
      minDate = selectedDate;
    }
    if (maxDate != null && selectedDate.isAfter(maxDate)) {
      maxDate = selectedDate;
    }

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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

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
                  child: Localizations.override(
                    context: context,
                    locale: const Locale('en', 'US'),
                    delegates: [
                      _LowercaseCupertinoLocalizationsDelegate(context),
                    ],
                    child: CupertinoDatePicker(
                      mode: mode,
                      initialDateTime: selectedDate,
                      minimumDate: minDate,
                      maximumDate: maxDate,
                      onDateTimeChanged: (DateTime newDateTime) {
                        final updatedDate = mode == CupertinoDatePickerMode.monthYear
                            ? DateTime(newDateTime.year, newDateTime.month)
                            : DateTime(
                                newDateTime.year,
                                newDateTime.month,
                                newDateTime.day,
                                selectedDate.hour,
                                selectedDate.minute,
                              );
                        onDateSelected(updatedDate);
                      },
                    ),
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
        borderRadius: BorderRadius.circular(AppStyles.formFieldRadius),
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

        InkWell(
          onTap: () => _showPicker(context),
          borderRadius: BorderRadius.circular(12.0),
          child: InputDecorator(
            decoration: _getInputDecoration(),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon!,
                  const SizedBox(width: 8.0),
                ],
                Expanded(
                  child: Text(
                    mode == CupertinoDatePickerMode.monthYear
                        ? DateFormat('MMMM yyyy').format(selectedDate).cased(context)
                        : DateFormat.yMMMd().format(selectedDate).cased(context),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (suffixIcon != null) ...[
                  const SizedBox(width: 8.0),
                  suffixIcon!,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LowercaseCupertinoLocalizations extends DefaultCupertinoLocalizations {
  final BuildContext context;
  const _LowercaseCupertinoLocalizations(this.context);

  @override
  String datePickerMonth(int monthIndex) {
    return super.datePickerMonth(monthIndex).cased(context);
  }
}

class _LowercaseCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  final BuildContext context;
  const _LowercaseCupertinoLocalizationsDelegate(this.context);

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(
      _LowercaseCupertinoLocalizations(context),
    );
  }

  @override
  bool shouldReload(covariant _LowercaseCupertinoLocalizationsDelegate old) =>
      old.context != context;
}
