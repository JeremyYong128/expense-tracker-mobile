import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/notification_provider.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static void show(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications;

    if (notifications.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Notifications'.cased(context))),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'You\'re all caught up!',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Notifications'.cased(context))),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: notifications.length + 1,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey.withValues(alpha: 0.5)),
        itemBuilder: (context, index) {
          if (index == notifications.length) {
            return const SizedBox.shrink();
          }
          final notification = notifications[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: notification.color.withValues(alpha: 0.15),
                child: Icon(notification.icon, color: notification.color),
              ),
              title: Text(
                notification.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  notification.message,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              onTap: () {
                // Close the screen first
                Navigator.of(context).pop();
                // Execute the action if provided
                if (notification.onTap != null) {
                  notification.onTap!(context);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
