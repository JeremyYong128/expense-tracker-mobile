import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class CustomReorderableGridView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final void Function(int, int) onReorder;
  final SliverGridDelegate gridDelegate;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const CustomReorderableGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onReorder,
    required this.gridDelegate,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableGridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      onReorder: onReorder,
      dragWidgetBuilder: (int index, Widget child) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          builder: (context, animValue, childWidget) {
            final double scale = 1.0 + (0.05 * animValue);
            return Transform.scale(
              scale: scale,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15 * animValue),
                      blurRadius: 24 * animValue,
                      offset: Offset(0, 8 * animValue),
                    ),
                  ],
                ),
                child: childWidget,
              ),
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        return itemBuilder(context, index);
      },
    );
  }
}
