import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String? confirmText;
  final VoidCallback? onConfirm;
  final bool isDestructive;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText = 'Cancel',
    this.confirmText,
    this.onConfirm,
    this.isDestructive = false,
    this.secondaryActionText,
    this.onSecondaryAction,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    String cancelText = 'Cancel',
    String? confirmText,
    VoidCallback? onConfirm,
    bool isDestructive = false,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
  }) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return ConfirmationDialog(
          title: title,
          content: content,
          cancelText: cancelText,
          confirmText: confirmText,
          onConfirm: onConfirm,
          isDestructive: isDestructive,
          secondaryActionText: secondaryActionText,
          onSecondaryAction: onSecondaryAction,
        );
      },
    ).then((result) {
      if (result == 'confirm' && onConfirm != null) {
        onConfirm();
      } else if (result == 'secondary' && onSecondaryAction != null) {
        onSecondaryAction();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(title.cased(context)),
      content: Text(
        content.cased(context),
        style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            cancelText.cased(context),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        if (secondaryActionText != null && onSecondaryAction != null)
          TextButton(
            onPressed: () => Navigator.pop(context, 'secondary'),
            child: Text(
              secondaryActionText!.cased(context),
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        if (confirmText != null && onConfirm != null)
          TextButton(
            onPressed: () => Navigator.pop(context, 'confirm'),
            child: Text(
              confirmText!.cased(context),
              style: TextStyle(
                color: isDestructive ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
