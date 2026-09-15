import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';

class PageContentCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final double? paddingTop;
  final double? paddingBottom;
  final double? paddingLeft;
  final double? paddingRight;

  const PageContentCard({
    super.key,
    this.title,
    this.paddingTop,
    this.paddingBottom,
    this.paddingLeft,
    this.paddingRight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: paddingTop ?? 20.0,
          bottom: paddingBottom ?? 20.0,
          left: paddingLeft ?? 20.0,
          right: paddingRight ?? 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null && title!.isNotEmpty) ...[
              Text(title!.cased(context), style: AppStyles.sectionHeader),
              const SizedBox(height: AppStyles.sectionHeaderSpacing),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
