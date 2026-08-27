import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';

enum CategoryTypeSelection { expense, income, both }

class CategoryTypeToggle extends StatelessWidget {
  final CategoryTypeSelection selection;
  final ValueChanged<CategoryTypeSelection> onChanged;

  const CategoryTypeToggle({
    super.key,
    required this.selection,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Determine alignment and color based on selection
    Alignment alignment;
    Color activeColor;
    
    switch (selection) {
      case CategoryTypeSelection.expense:
        alignment = Alignment.centerLeft;
        activeColor = AppColors.expense.withValues(alpha: 0.1);
        break;
      case CategoryTypeSelection.both:
        alignment = Alignment.center;
        activeColor = AppColors.primary.withValues(alpha: 0.1);
        break;
      case CategoryTypeSelection.income:
        alignment = Alignment.centerRight;
        activeColor = AppColors.income.withValues(alpha: 0.1);
        break;
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            alignment: alignment,
            child: FractionallySizedBox(
              widthFactor: 0.333,
              child: Container(
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Row(
            children: [
              _buildOption(
                context: context,
                type: CategoryTypeSelection.expense,
                label: 'Expense',
                activeColor: AppColors.expense,
              ),
              _buildOption(
                context: context,
                type: CategoryTypeSelection.both,
                label: 'Both',
                activeColor: AppColors.primary,
              ),
              _buildOption(
                context: context,
                type: CategoryTypeSelection.income,
                label: 'Income',
                activeColor: AppColors.income,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required CategoryTypeSelection type,
    required String label,
    required Color activeColor,
  }) {
    final isSelected = selection == type;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(type),
        child: Container(
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? activeColor : AppColors.grey,
            ),
            child: Text(label.cased(context)),
          ),
        ),
      ),
    );
  }
}
