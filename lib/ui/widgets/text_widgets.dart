import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? infoText;
  final Widget? action;

  const SectionHeader({
    super.key,
    required this.title,
    this.infoText,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title.cased(context), style: AppStyles.sectionHeader),
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
                      borderRadius: BorderRadius.circular(8),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      triggerMode: TooltipTriggerMode.tap,
                      isModal: true,
                      fadeInDuration: const Duration(milliseconds: 600),
                      fadeOutDuration: const Duration(milliseconds: 600),
                      child: const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?action,
          ],
        ),
        const SizedBox(height: AppStyles.sectionHeaderBottomSpacing),
      ],
    );
  }
}
