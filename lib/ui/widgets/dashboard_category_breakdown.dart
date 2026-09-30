import 'dart:async';
import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/ui/widgets/layout_widgets.dart';
import 'package:expense_tracker_mobile/ui/widgets/simple_pie_chart.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_segment_toggle.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/analytics_provider.dart';
import 'package:expense_tracker_mobile/ui/screens/category_details_screen.dart';
import 'package:expense_tracker_mobile/ui/widgets/text_widgets.dart';

class CategoryBreakdownCard extends StatefulWidget {
  const CategoryBreakdownCard({super.key});

  @override
  State<CategoryBreakdownCard> createState() => _CategoryBreakdownCardState();
}

class _CategoryBreakdownCardState extends State<CategoryBreakdownCard> {
  bool _isExpanded = false;
  int? _touchedIndex;
  Timer? _clearSelectionTimer;
  int _pieAnimationMs = 150;
  String _categoryBreakdownType = 'expense';

  @override
  void dispose() {
    _clearSelectionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = context
        .select<AnalyticsProvider, List<MapEntry<Category, double>>>((p) {
          final stats = p.getDashboardStats();
          return _categoryBreakdownType == 'expense'
              ? stats.expenseBreakdown.entries.toList()
              : stats.incomeBreakdown.entries.toList();
        });
    final totalAmount = context.select<AnalyticsProvider, double>((p) {
      final stats = p.getDashboardStats();
      return _categoryBreakdownType == 'expense'
          ? stats.totalExpense
          : stats.totalIncome;
    });

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return ContentCard(
      child: Column(
        children: [
          SectionHeader(
            title: 'Category Breakdown',
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
          CustomSegmentToggle<String>(
            activeValue: _categoryBreakdownType,
            options: [
              CustomSegmentOption(
                value: 'expense',
                label: 'Expense',
                activeColor: AppColors.expense,
              ),
              CustomSegmentOption(
                value: 'income',
                label: 'Income',
                activeColor: AppColors.income,
              ),
            ],
            onChanged: (val) {
              setState(() {
                _pieAnimationMs = 150;
                _touchedIndex = null;
                _isExpanded = false;
                _categoryBreakdownType = val;
              });
            },
          ),
          const SizedBox(height: AppStyles.listItemSpacing),
          if (entries.isNotEmpty)
            Center(
              child: SimplePieChart(
                data: [
                  for (var entry in entries)
                    PieChartSector(color: entry.key.color, value: entry.value),
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

                    final category = entry.key;
                    final name = category.name;
                    final color = category.color;

                    final percentage = totalAmount > 0
                        ? (amount / totalAmount)
                        : 0.0;

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
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => CategoryDetailsScreen(
                                      category: entry.key,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 12.0,
                                    height: 12.0,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
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
                                              '${(percentage * 100).toStringAsFixed(1)}%',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 15,
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
