import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_preferences_provider.dart';

const Map<String, String> _ukToUsDictionary = {
  'colour': 'color',
  'categorise': 'categorize',
  'categorised': 'categorized',
  'categorising': 'categorizing',
  'generalise': 'generalize',
  'generalised': 'generalized',
  'generalising': 'generalizing',
  'customise': 'customize',
  'customised': 'customized',
  'customising': 'customizing',
  'analyse': 'analyze',
  'analysed': 'analyzed',
  'analysing': 'analyzing',
  'favourite': 'favorite',
  'favourites': 'favorites',
  'optimise': 'optimize',
  'optimised': 'optimized',
  'optimising': 'optimizing',
  'recognise': 'recognize',
  'recognised': 'recognized',
  'recognising': 'recognizing',
  'synchronise': 'synchronize',
  'synchronised': 'synchronized',
  'synchronising': 'synchronizing',
};

extension StringCasing on String {
  String cased(BuildContext context) {
    try {
      final isLower = Provider.of<UserPreferencesProvider>(context).isLowerCaps;
      return isLower ? toLowerCase() : this;
    } catch (e) {
      // Fallback in case provider is not found
      return toLowerCase();
    }
  }
}

extension StringLocalization on String {
  String localized(BuildContext context) {
    try {
      final useUsEnglish = Provider.of<UserPreferencesProvider>(context).useUsEnglish;
      if (!useUsEnglish) return this;

      var result = this;
      _ukToUsDictionary.forEach((ukWord, usWord) {
        final regex = RegExp('\\b$ukWord\\b', caseSensitive: false);
        result = result.replaceAllMapped(regex, (match) {
          final matchedStr = match.group(0)!;
          if (matchedStr.isNotEmpty && matchedStr[0] == matchedStr[0].toUpperCase()) {
            return usWord[0].toUpperCase() + usWord.substring(1);
          }
          return usWord;
        });
      });
      return result;
    } catch (e) {
      return this;
    }
  }
}
