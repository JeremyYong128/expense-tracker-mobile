import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/notification_provider.dart';
import 'package:expense_tracker_mobile/ui/screens/notifications_screen.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () => NotificationsScreen.show(context),
        ),
        if (context.watch<NotificationProvider>().hasUnread)
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.expense,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
