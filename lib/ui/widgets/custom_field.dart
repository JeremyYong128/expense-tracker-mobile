import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class CustomField extends StatelessWidget {
  final String? label;
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry padding;
  final String? infoText;

  const CustomField({
    super.key,
    this.label,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.only(bottom: 24.0),
    this.infoText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label!,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                if (infoText != null) ...[
                  const SizedBox(width: 8),
                  JustTheTooltip(
                    content: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 220,
                        child: Text(
                          infoText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    backgroundColor: Colors.black87,
                    tailBaseWidth: 16,
                    tailLength: 8,
                    isModal: true,
                    margin: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8.0),
          ],
          if (height != null) SizedBox(height: height, child: child) else child,
        ],
      ),
    );
  }
}
