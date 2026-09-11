import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/core/exceptions.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/card_provider.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_form.dart';

import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/models/card.dart';

class ValidatorService {
  static Future<TransactionFormData> validateTransaction({
    required BuildContext context,
    required String titleText,
    required String amountText,
    required int? categoryId,
    required DateTime date,
    required bool isIncome,
    required String noteText,
    required int? cardId,
    required int? recurringId,
    required bool isRecurring,
    required String recurringIntervalText,
    required String recurringPeriod,
    required String rewardAmountText,
    required bool hasRewards,
  }) async {
    // 1. Field-Level Validation & Parsing
    if (!Validators.isPresent(titleText)) {
      throw ValidationException('Title cannot be empty.');
    }
    final title = titleText.trim();
    if (title.length > 50) {
      throw ValidationException('Title must be 50 characters or less.');
    }

    if (isRecurring && title.toLowerCase() == 'none') {
      throw ValidationException('Title cannot be "None".');
    }

    final parsedNote = noteText.trim();
    if (parsedNote.length > 250) {
      throw ValidationException('Note must be 250 characters or less.');
    }
    final note = parsedNote.isEmpty ? null : parsedNote;

    if (!Validators.amount(amountText)) {
      throw ValidationException(
        'Amount must be a valid number greater than 0.',
      );
    }
    final amount = double.parse(amountText);

    if (categoryId == null) {
      throw ValidationException('Please select a category.');
    }

    int recurringInterval = 1;
    if (isRecurring) {
      final parsedInterval = int.tryParse(recurringIntervalText);
      if (parsedInterval == null || parsedInterval <= 0) {
        throw ValidationException(
          'Recurring interval must be a valid number greater than 0.',
        );
      }
      recurringInterval = parsedInterval;
    }

    double? rewardAmount;
    if (!isIncome &&
        cardId != null &&
        hasRewards &&
        rewardAmountText.isNotEmpty) {
      if (!Validators.rewardAmount(rewardAmountText)) {
        throw ValidationException('Reward amount must be a valid number.');
      }
      rewardAmount = double.parse(rewardAmountText);
    }

    // 2. Cross-Field Validation
    if (isIncome && cardId != null) {
      throw ValidationException(
        'Income transactions cannot be linked to a credit card.',
      );
    }

    // 3. Database / Complex Validation
    final categoryProvider = context.read<CategoryProvider>();
    final category = categoryProvider.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () =>
          throw ValidationException('Selected category was not found.'),
    );

    final isCompatible = isIncome ? category.isIncome : category.isExpense;
    if (!isCompatible) {
      throw ValidationException(
        '"${category.name}" does not support a transaction of type "${isIncome ? 'income' : 'expense'}".',
      );
    }

    if (recurringId != null) {
      final recurringProvider = context.read<RecurringTransactionProvider>();
      final recurringTransaction = recurringProvider.transactions.firstWhere(
        (rt) => rt.id == recurringId,
        orElse: () => throw ValidationException(
          'Linked recurring transaction not found.',
        ),
      );

      if (recurringTransaction.categoryId != categoryId) {
        throw ValidationException(
          'Category must match the linked recurring transaction template ("${categoryProvider.categories.firstWhere((c) => c.id == recurringTransaction.categoryId).name}").',
        );
      }
    }

    // All checks passed! Return the parsed data.
    return TransactionFormData(
      amount: amount,
      title: title,
      categoryId: categoryId,
      date: date,
      isIncome: isIncome,
      note: note,
      cardId: !isIncome && cardId != null ? cardId : null,
      recurringId: recurringId,
      isRecurring: isRecurring,
      recurringInterval: recurringInterval,
      recurringPeriod: recurringPeriod,
      rewardAmount: rewardAmount,
    );
  }

  static Category validateCategory({
    required BuildContext context,
    required int? id,
    required String nameText,
    required String colorHex,
    required String iconString,
    required bool isActive,
    required bool isExpense,
    required bool isIncome,
  }) {
    final categoryProvider = context.read<CategoryProvider>();

    if (!Validators.isPresent(nameText)) {
      throw ValidationException('Category name cannot be empty.');
    }
    final parsedName = nameText.trim();
    if (parsedName.length > 50) {
      throw ValidationException('Category name must be 50 characters or less.');
    }

    final existingCategories = categoryProvider.categories.where(
      (c) => c.name.toLowerCase() == parsedName.toLowerCase() && c.id != id,
    );
    if (existingCategories.isNotEmpty && existingCategories.first.isActive) {
      throw ValidationException('A category with this name already exists.');
    }

    return Category(
      id: id,
      name: parsedName,
      colorHex: colorHex,
      iconString: iconString,
      isActive: isActive,
      isExpense: isExpense,
      isIncome: isIncome,
    );
  }

  static Card validateCard({
    required BuildContext context,
    required int? id,
    required String nameText,
    required String rewardType,
    required String rateText,
    required String colorHex,
  }) {
    final cardProvider = context.read<CardProvider>();

    final parsedName = nameText.trim();
    if (parsedName.toLowerCase() == 'none') {
      throw ValidationException('Card name cannot be "None".');
    }
    if (!Validators.isPresent(parsedName)) {
      throw ValidationException('Card name cannot be empty.');
    }
    if (parsedName.length > 50) {
      throw ValidationException('Card name must be 50 characters or less.');
    }

    final existingCards = cardProvider.cards.where(
      (c) => c.name.toLowerCase() == parsedName.toLowerCase() && c.id != id,
    );
    if (existingCards.isNotEmpty) {
      throw ValidationException('A card with this name already exists.');
    }

    double rate = 0.0;
    if (rewardType != 'None') {
      if (!Validators.greaterThanZero(rateText)) {
        throw ValidationException(
          'Reward Rate must be a valid number greater than 0.',
        );
      }
      rate = double.parse(rateText.trim());
    }

    return Card(
      id: id,
      name: parsedName,
      rewardType: rewardType,
      rewardRate: rate,
      colorHex: colorHex,
    );
  }
}

class Validators {
  /// Checks if a field is not empty.
  static bool isPresent(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Checks if a field is a valid number.
  static bool number(String? value) {
    if (!isPresent(value)) return false;
    return double.tryParse(value!) != null;
  }

  /// Checks if a field is a number greater than zero.
  static bool greaterThanZero(String? value) {
    if (!number(value)) return false;
    return double.parse(value!) > 0;
  }

  /// Checks if an amount is valid (> 0 and max 2 decimal places).
  static bool amount(String? value) {
    if (!greaterThanZero(value)) return false;

    final parts = value!.trim().split('.');
    if (parts.length == 2 && parts[1].length > 2) {
      return false;
    }
    return true;
  }

  /// Checks if a reward amount is valid (>= 0 and max 2 decimal places).
  static bool rewardAmount(String? value) {
    if (value == null || value.trim().isEmpty) return true;

    final parsed = double.tryParse(value);
    if (parsed == null || parsed < 0) return false;

    final parts = value.trim().split('.');
    if (parts.length == 2 && parts[1].length > 2) {
      return false;
    }

    return true;
  }
}
