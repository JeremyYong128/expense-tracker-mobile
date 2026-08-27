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
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/credit_card_provider.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/services/recurring_processing_service.dart';
import 'package:expense_tracker_mobile/ui/widgets/dialogs/pending_approvals_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker_mobile/ui/screens/recurring_transactions_screen.dart';
import 'package:expense_tracker_mobile/providers/notification_provider.dart';
import 'package:expense_tracker_mobile/ui/widgets/global_notification_banner.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserPreferencesProvider(prefs)),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => RecurringTransactionProvider()),
        ChangeNotifierProvider(create: (_) => CreditCardProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
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

  static void navigateToHistory(BuildContext context) {
    final state = context.findAncestorStateOfType<_HomeScreenState>();
    if (state != null) {
      state._tabController.index = 1; // History Tab
      state._lastTappedIndex = 1;
    }
  }

  static void navigateToRecurring(BuildContext context) {
    final state = context.findAncestorStateOfType<_HomeScreenState>();
    if (state != null) {
      state._tabController.index = 3; // Manage Tab
      state._lastTappedIndex = 3;
      state._navigatorKeys[3].currentState?.popUntil((route) => route.isFirst);
      state._navigatorKeys[3].currentState?.push(
        MaterialPageRoute(
          builder: (_) => const RecurringTransactionsScreen(showAppBar: true),
        ),
      );
    }
  }

  static void navigateToAddTransaction(
    BuildContext context, {
    bool isRecurring = false,
  }) {
    final state = context.findAncestorStateOfType<_HomeScreenState>();
    if (state != null) {
      addTransactionFormState.value = AddTransactionFormConfig(initialIsRecurring: isRecurring);
      state._tabController.index = 2; // Add tab
      state._lastTappedIndex = 2;
    }
  }

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

  final CupertinoTabController _tabController = CupertinoTabController();
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );

  int _lastTappedIndex = 0;
  bool _isCheckingPending = false;

  late RecurringTransactionProvider _recurringProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recurringProvider = Provider.of<RecurringTransactionProvider>(
        context,
        listen: false,
      );
      _checkPendingRecurringTransactions();
      _recurringProvider.addListener(_checkPendingRecurringTransactions);
    });
  }

  @override
  void dispose() {
    _recurringProvider.removeListener(_checkPendingRecurringTransactions);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkPendingRecurringTransactions() async {
    if (_isCheckingPending) return;
    _isCheckingPending = true;

    try {
      final pending = await RecurringProcessingService.getPendingApprovals();
      if (!mounted) return;
      
      final notifProvider = Provider.of<NotificationProvider>(context, listen: false);

      if (pending.isNotEmpty) {
        notifProvider.addNotification(
          AppNotification(
            id: 'pending_approvals',
            title: 'Pending Approvals',
            message: 'You have ${pending.length} recurring transactions awaiting approval.',
            icon: Icons.access_time,
            color: AppColors.expense,
            showAsBanner: true,
            onTap: (ctx) => PendingApprovalsDialog.show(ctx, pending),
          ),
        );
      } else {
        notifProvider.removeNotification('pending_approvals');
      }
    } finally {
      _isCheckingPending = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlobalNotificationBanner(
      child: CupertinoTabScaffold(
        controller: _tabController,
      tabBar: CupertinoTabBar(
        onTap: (index) {
          if (index == 2 && _lastTappedIndex != 2) {
            addTransactionFormState.value = AddTransactionFormConfig();
          }

          if (_lastTappedIndex == index) {
            _navigatorKeys[index].currentState?.popUntil(
              (route) => route.isFirst,
            );
          }
          _lastTappedIndex = index;
        },
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
                child: const Icon(Icons.add, color: AppColors.white, size: 24),
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
                child: const Icon(Icons.add, color: AppColors.white, size: 24),
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
          navigatorKey: _navigatorKeys[index],
          builder: (BuildContext context) {
            return _widgetOptions[index];
          },
        );
      },
    ));
  }
}
