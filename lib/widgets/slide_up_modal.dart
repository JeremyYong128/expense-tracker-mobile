import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../utils/string_extensions.dart';

class SlideUpModal extends StatelessWidget {
  final String? title;
  final String? leftButtonTitle;
  final VoidCallback? onLeftButtonPressed;
  final String? rightButtonTitle;
  final VoidCallback? onRightButtonPressed;
  final Widget child;
  final double heightFraction;

  const SlideUpModal({
    Key? key,
    this.title,
    this.leftButtonTitle,
    this.onLeftButtonPressed,
    this.rightButtonTitle,
    this.onRightButtonPressed,
    required this.child,
    this.heightFraction = 0.75,
  }) : super(key: key);

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? leftButtonTitle,
    VoidCallback? onLeftButtonPressed,
    String? rightButtonTitle,
    VoidCallback? onRightButtonPressed,
    required Widget child,
    double heightFraction = 0.75,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SlideUpModal(
        title: title,
        leftButtonTitle: leftButtonTitle,
        onLeftButtonPressed: onLeftButtonPressed,
        rightButtonTitle: rightButtonTitle,
        onRightButtonPressed: onRightButtonPressed,
        heightFraction: heightFraction,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * heightFraction,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (title != null) ...[
                  Text(
                    title!.cased(context),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ] else ...[
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onLeftButtonPressed,
                    child: Text(
                      (leftButtonTitle ?? '').cased(context),
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onRightButtonPressed,
                    child: Text(
                      (rightButtonTitle ?? '').cased(context),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
          
          // Content
          Expanded(child: child),
        ],
      ),
    );
  }
}
