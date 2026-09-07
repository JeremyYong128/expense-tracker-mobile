import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';

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
            Text(
              label!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8.0),
          ],
          if (height != null)
            SizedBox(height: height, child: child)
          else
            child,
          if (infoText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      infoText!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
