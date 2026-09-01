import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final bool showAsBanner;
  final void Function(BuildContext context)? onTap;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    this.color = AppColors.primary,
    this.showAsBanner = false,
    this.onTap,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    IconData? icon,
    Color? color,
    bool? showAsBanner,
    void Function(BuildContext context)? onTap,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      showAsBanner: showAsBanner ?? this.showAsBanner,
      onTap: onTap ?? this.onTap,
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  final Map<String, AppNotification> _notifications = {
    'mock_1': AppNotification(
      id: 'mock_1',
      title: 'Approvals Pending',
      message: 'You have 3 recurring transactions awaiting your approval.',
      icon: Icons.assignment_late_outlined,
      color: Colors.orange,
    ),
    'mock_2': AppNotification(
      id: 'mock_2',
      title: 'Budget Alert',
      message: 'You have exceeded your monthly budget for Dining by \$45.00.',
      icon: Icons.warning_amber_outlined,
      color: Colors.red,
    ),
    'mock_3': AppNotification(
      id: 'mock_3',
      title: 'Credit Card Bill Due',
      message: 'Your Chase Sapphire Reserve bill is due in 3 days.',
      icon: Icons.credit_card_outlined,
      color: Colors.blue,
    ),
  };

  List<AppNotification> get notifications => _notifications.values.toList();
  bool get hasUnread => _notifications.isNotEmpty;
  
  List<AppNotification> get bannerNotifications => 
      _notifications.values.where((n) => n.showAsBanner).toList();

  void addNotification(AppNotification notification) {
    _notifications[notification.id] = notification;
    notifyListeners();
  }

  void removeNotification(String id) {
    if (_notifications.containsKey(id)) {
      _notifications.remove(id);
      notifyListeners();
    }
  }

  void dismissBanner(String id) {
    if (_notifications.containsKey(id)) {
      _notifications[id] = _notifications[id]!.copyWith(showAsBanner: false);
      notifyListeners();
    }
  }
}
