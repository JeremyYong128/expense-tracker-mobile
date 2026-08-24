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
import 'package:expense_tracker_mobile/ui/widgets/pending_approvals_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingRecurringTransactions();
      Provider.of<RecurringTransactionProvider>(
        context,
        listen: false,
      ).addListener(_checkPendingRecurringTransactions);
    });
  }

  @override
  void dispose() {
    Provider.of<RecurringTransactionProvider>(
      context,
      listen: false,
    ).removeListener(_checkPendingRecurringTransactions);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkPendingRecurringTransactions() async {
    if (_isCheckingPending) return;
    _isCheckingPending = true;

    try {
      final pending = await RecurringProcessingService.getPendingApprovals();
      if (pending.isEmpty || !mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PendingApprovalsDialog(initialPending: pending);
        },
      );

      if (mounted) {
        context.read<TransactionProvider>().fetchTransactions();
        context
            .read<RecurringTransactionProvider>()
            .fetchRecurringTransactions();
      }
    } finally {
      _isCheckingPending = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        onTap: (index) {
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
          navigatorKey: _navigatorKeys[index],
          builder: (BuildContext context) {
            return _widgetOptions[index];
          },
        );
      },
    );
  }
}
