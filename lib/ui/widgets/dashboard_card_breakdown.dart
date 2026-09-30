import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/user_preferences_provider.dart';
import 'package:expense_tracker_mobile/utils/currency_utils.dart';
import 'package:expense_tracker_mobile/models/card.dart' as model_card;
import 'package:expense_tracker_mobile/ui/widgets/layout_widgets.dart';
import 'package:expense_tracker_mobile/ui/widgets/simple_pie_chart.dart';
import 'package:expense_tracker_mobile/ui/widgets/text_widgets.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/providers/analytics_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:expense_tracker_mobile/ui/screens/card_details_screen.dart';

class CardBreakdownCard extends StatefulWidget {
  const CardBreakdownCard({super.key});

  @override
  State<CardBreakdownCard> createState() => _CardBreakdownCardState();
}

class _CardBreakdownCardState extends State<CardBreakdownCard> {
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
    final baseCurrency = context.watch<UserPreferencesProvider>().baseCurrency;
    final entries = context
        .select<AnalyticsProvider, List<MapEntry<model_card.Card, double>>>(
          (p) => p.getDashboardStats().cardExpenseBreakdown.entries.toList(),
        );
    final budgets = context
        .select<AnalyticsProvider, Map<model_card.Card, double?>>(
          (p) => p.getDashboardStats().cardBudgets,
        );
    final totalAmount = context.select<AnalyticsProvider, double>(
      (p) => p.getDashboardStats().totalExpense,
    );

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return ContentCard(
      child: Column(
        children: [
          SectionHeader(
            title: 'Card Expenses',
            action: entries.length > 3
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
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )
                : null,
          ),
          if (entries.isNotEmpty)
            Center(
              child: SimplePieChart(
                data: [
                  for (var entry in entries)
                    PieChartSector(
                      color: Color(
                        int.parse(entry.key.colorHex.replaceAll('#', '0xFF')),
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
          if (entries.isNotEmpty)
            const SizedBox(height: AppStyles.listItemSpacing),
          if (entries.isNotEmpty)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Column(
                children: () {
                  final visibleEntries =
                      (_isExpanded ? entries : entries.take(3)).toList();
                  final List<Widget> children = [];

                  for (int i = 0; i < visibleEntries.length; i++) {
                    final entry = visibleEntries[i];
                    final amount = entry.value;

                    final card = entry.key;
                    final name = card.name == 'No card'
                        ? card.name.cased(context)
                        : card.name;
                    final color = Color(
                      int.parse(card.colorHex.replaceAll('#', '0xFF')),
                    );
                    final iconData = Icons.credit_card;
                    final budgetAmount = budgets[card];

                    final percentage = totalAmount > 0
                        ? (amount / totalAmount)
                        : 0.0;
                    String subtitleText = 'No budget'.cased(context);
                    Color subtitleColor = AppColors.textSecondary;
                    if (budgetAmount != null && budgetAmount > 0) {
                      final diff = budgetAmount - amount;
                      if (diff >= 0) {
                        subtitleText =
                            '${CurrencyFormatter.format(diff, baseCurrency)} under budget';
                      } else {
                        subtitleText =
                            '${CurrencyFormatter.format(diff.abs(), baseCurrency)} over budget';
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
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (entry.key.id != -1) {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          CardDetailsScreen(card: entry.key),
                                    ),
                                  );
                                }
                              },
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              CurrencyFormatter.format(
                                                amount,
                                                baseCurrency,
                                              ),
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
                        const SizedBox(height: AppStyles.listItemSpacing),
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
