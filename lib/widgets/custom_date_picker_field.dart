import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../utils/string_extensions.dart';

class CustomDatePickerField extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const CustomDatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  void _showPicker(BuildContext context) {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);

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
                  child: Localizations.override(
                    context: context,
                    locale: const Locale('en', 'US'),
                    delegates: [
                      _LowercaseCupertinoLocalizationsDelegate(context),
                    ],
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: selectedDate,
                      minimumDate: firstDate,
                      maximumDate: now,
                      onDateTimeChanged: (DateTime newDateTime) {
                        final updatedDate = DateTime(
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
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 60.0,
          child: InkWell(
            onTap: () => _showPicker(context),
            borderRadius: BorderRadius.circular(12.0),
            child: InputDecorator(
              decoration: _getInputDecoration(),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.primary),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      DateFormat.yMMMd().format(selectedDate).cased(context),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
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
  bool shouldReload(covariant _LowercaseCupertinoLocalizationsDelegate old) => old.context != context;
}
