import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/screens/dashboard_screen.dart';
import 'package:expense_tracker_mobile/ui/screens/history_screen.dart';
import 'package:expense_tracker_mobile/ui/screens/add_transaction_screen.dart';
import 'package:expense_tracker_mobile/ui/screens/manage_screen.dart';
import 'package:expense_tracker_mobile/ui/screens/settings_screen.dart';
import 'package:expense_tracker_mobile/providers/user_preferences_provider.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/services/recurring_processing_service.dart';
import 'package:expense_tracker_mobile/ui/widgets/pending_approvals_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserPreferencesProvider(prefs),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker'.cased(context),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    HistoryScreen(),
    AddTransactionScreen(),
    ManageScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingRecurringTransactions();
    });
  }

  Future<void> _checkPendingRecurringTransactions() async {
    final pending = await RecurringProcessingService.getPendingApprovals();
    if (pending.isEmpty || !mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PendingApprovalsDialog(initialPending: pending);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home'.cased(context),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: 'History'.cased(context),
          ),
          BottomNavigationBarItem(
            icon: Transform.translate(
              offset: const Offset(0, 6),
              child: Container(
                width: 44,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
            activeIcon: Transform.translate(
              offset: const Offset(0, 6),
              child: Container(
                width: 44,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.apps),
            label: 'Manage'.cased(context),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'Settings'.cased(context),
          ),
        ],
        activeColor: AppColors.primary,
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            return _widgetOptions[index];
          },
        );
      },
    );
  }
}
