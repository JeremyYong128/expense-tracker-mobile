import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/models/card.dart' as model_card;
import 'package:expense_tracker_mobile/ui/widgets/layout_widgets.dart';
import 'package:expense_tracker_mobile/ui/widgets/simple_pie_chart.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_segment_toggle.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/text_widgets.dart';

class BreakdownCard<T> extends StatefulWidget {
  final String title;
  final String? infoText;
  final List<MapEntry<T, double>> entries;
  final Map<T, double?> budgets;
  final double totalAmount;
  final bool isCategory;
  final bool showBudget;
  
  // Toggle properties
  final String? activeToggleValue;
  final List<CustomSegmentOption<String>>? toggleOptions;
  final ValueChanged<String>? onToggleChanged;
  final void Function(T item)? onItemTap;

  const BreakdownCard({
    super.key,
    required this.title,
    this.infoText,
    required this.entries,
    required this.budgets,
    required this.totalAmount,
    this.isCategory = false,
    this.showBudget = true,
    this.activeToggleValue,
    this.toggleOptions,
    this.onToggleChanged,
    this.onItemTap,
  });

  @override
  State<BreakdownCard> createState() => _BreakdownCardState<T>();
}

class _BreakdownCardState<T> extends State<BreakdownCard<T>> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  
  bool _isExpanded = false;
  int? _touchedIndex;
  Timer? _clearSelectionTimer;
  int _pieAnimationMs = 150;

  @override
  void dispose() {
    _clearSelectionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty && widget.toggleOptions == null) {
      return const SizedBox.shrink();
    }

    return ContentCard(
      child: Column(
        children: [
          SectionHeader(
            title: widget.title,
            infoText: widget.infoText,
            action: widget.entries.length > 3
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _isExpanded
                          ? 'Less'.cased(context)
                          : 'More'.cased(context),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : null,
          ),
          if (widget.toggleOptions != null && widget.onToggleChanged != null) ...[
            CustomSegmentToggle<String>(
              activeValue: widget.activeToggleValue!,
              options: widget.toggleOptions!,
              onChanged: (val) {
                setState(() {
                  _pieAnimationMs = 150;
                  _touchedIndex = null;
                  _isExpanded = false;
                });
                widget.onToggleChanged!(val);
              },
            ),
            const SizedBox(height: AppStyles.listItemSpacing * 1.5),
          ],
          if (widget.entries.isNotEmpty)
            Center(
              child: SimplePieChart(
                data: [
                  for (var entry in widget.entries)
                    PieChartSector(
                      color: widget.isCategory
                          ? (entry.key as Category).color
                          : Color(
                              int.parse(
                                (entry.key as model_card.Card)
                                    .colorHex
                                    .replaceAll('#', '0xFF'),
                              ),
                            ),
                      value: entry.value,
                    ),
                ],
                radius: 80,
                strokeWidth: 32,
                touchedIndex: _touchedIndex,
                animationDuration: Duration(milliseconds: _pieAnimationMs),
                onSectionTouched: (index) {
                  _clearSelectionTimer?.cancel();
                  setState(() {
                    if (index == null || index == _touchedIndex) {
                      _pieAnimationMs = 600;
                      _touchedIndex = null;
                    } else {
                      _pieAnimationMs = 150;
                      _touchedIndex = index;
                      _clearSelectionTimer = Timer(
                        const Duration(milliseconds: 250),
                        () {
                          if (mounted) {
                            setState(() {
                              _pieAnimationMs = 600;
                              _touchedIndex = null;
                            });
                          }
                        },
                      );
                    }
                  });
                },
              ),
            ),
          if (widget.entries.isNotEmpty)
            const SizedBox(height: AppStyles.listItemSpacing * 1.5),
          if (widget.entries.isNotEmpty)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Column(
                children: () {
                  final visibleEntries = (_isExpanded
                          ? widget.entries
                          : widget.entries.take(3))
                      .toList();
                  final List<Widget> children = [];

                  for (int i = 0; i < visibleEntries.length; i++) {
                    final entry = visibleEntries[i];
                    final amount = entry.value;

                    String name;
                    Color color;
                    IconData iconData;
                    double? budgetAmount;

                    if (widget.isCategory) {
                      final category = entry.key as Category;
                      name = category.name;
                      color = category.color;
                      iconData = category.iconData;
                      budgetAmount = widget.budgets[category];
                    } else {
                      final card = entry.key as model_card.Card;
                      name = card.name == 'No card' ? card.name.cased(context) : card.name;
                      color = Color(
                        int.parse(card.colorHex.replaceAll('#', '0xFF')),
                      );
                      iconData = Icons.credit_card;
                      budgetAmount = widget.budgets[card];
                    }

                    final percentage = widget.totalAmount > 0
                        ? (amount / widget.totalAmount)
                        : 0.0;
                    String subtitleText = 'No budget'.cased(context);
                    Color subtitleColor = AppColors.textSecondary;
                    if (budgetAmount != null && budgetAmount > 0) {
                      final diff = budgetAmount - amount;
                      if (diff >= 0) {
                        subtitleText = '${_currencyFormat.format(diff)} under budget';
                      } else {
                        subtitleText = '${_currencyFormat.format(diff.abs())} over budget';
                        subtitleColor = AppColors.error;
                      }
                    }

                    children.add(
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -8.0,
                            bottom: -8.0,
                            left: -12.0,
                            right: -12.0,
                            child: AnimatedContainer(
                              duration: Duration(
                                milliseconds: _touchedIndex == i ? 150 : 600,
                              ),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                color: _touchedIndex == i
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: widget.onItemTap != null
                                  ? () => widget.onItemTap!(entry.key)
                                  : null,
                              borderRadius: BorderRadius.circular(12.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Icon(
                                      iconData,
                                      color: color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              if (widget.showBudget) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  subtitleText,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: subtitleColor,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _currencyFormat.format(amount),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${(percentage * 100).toStringAsFixed(1)}%',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (i < visibleEntries.length - 1) {
                      children.add(
                        const SizedBox(
                          height: AppStyles.listItemSpacing,
                        ),
                      );
                    }
                  }
              return children;
            }(),
              ),
            ),
        ],
      ),
    );
  }
}
