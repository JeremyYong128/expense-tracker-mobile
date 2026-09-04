import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';

class SharedFilterToggle<T> extends StatefulWidget {
  final List<T> items;
  final T selectedItem;
  final String Function(T item) labelBuilder;
  final ValueChanged<T> onSelected;
  final bool showCheckIcon;
  final ScrollController? scrollController;

  const SharedFilterToggle({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.labelBuilder,
    required this.onSelected,
    this.showCheckIcon = false,
    this.scrollController,
  });

  @override
  State<SharedFilterToggle<T>> createState() => _SharedFilterToggleState<T>();
}

class _SharedFilterToggleState<T> extends State<SharedFilterToggle<T>> {
  final Map<T, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    _initKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  @override
  void didUpdateWidget(SharedFilterToggle<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _initKeys();
    }
    if (oldWidget.selectedItem != widget.selectedItem) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected();
      });
    }
  }

  void _initKeys() {
    _itemKeys.clear();
    for (var item in widget.items) {
      _itemKeys[item] = GlobalKey();
    }
  }

  void _scrollToSelected() {
    final key = _itemKeys[widget.selectedItem];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        controller: widget.scrollController,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.items.map((item) {
            final isSelected = item == widget.selectedItem;
            final label = widget.labelBuilder(item);

            return Padding(
              key: _itemKeys[item],
              padding: const EdgeInsets.only(right: 8.0),
              child: Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    if (!isSelected) {
                      widget.onSelected(item);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.showCheckIcon && isSelected) ...[
                          const Icon(
                            Icons.check,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
