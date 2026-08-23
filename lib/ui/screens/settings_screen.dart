import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/user_preferences_provider.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_switch.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLowerCaps = Provider.of<UserPreferencesProvider>(
      context,
    ).isLowerCaps;

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(title: Text('Settings'.cased(context))),
        body: SafeArea(
          child: Padding(
            padding: AppStyles.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lower caps'.cased(context),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Set all text in the app to lowercase'.cased(
                              context,
                            ),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomSwitch(
                      value: isLowerCaps,
                      onChanged: (bool value) {
                        Provider.of<UserPreferencesProvider>(
                          context,
                          listen: false,
                        ).toggleLowerCaps(value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use US English'.cased(context),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomSwitch(
                      value: Provider.of<UserPreferencesProvider>(
                        context,
                      ).useUsEnglish,
                      onChanged: (bool value) {
                        Provider.of<UserPreferencesProvider>(
                          context,
                          listen: false,
                        ).toggleUsEnglish(value);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
