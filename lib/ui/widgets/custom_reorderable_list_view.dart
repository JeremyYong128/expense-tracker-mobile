import 'package:flutter/material.dart';

class CustomReorderableListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final void Function(int, int) onReorderItem;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const CustomReorderableListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onReorderItem,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      onReorderItem: onReorderItem,
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final double animValue = Curves.easeInOut.transform(animation.value);
            final double scale = Tween<double>(begin: 1.0, end: 1.02).transform(animValue);
            return Transform.scale(
              scale: scale,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 12.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12 * animValue),
                            blurRadius: 24 * animValue,
                            offset: Offset(0, 8 * animValue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  child!,
                ],
              ),
            );
          },
          child: child,
        );
      },
      itemBuilder: itemBuilder,
    );
  }
}
