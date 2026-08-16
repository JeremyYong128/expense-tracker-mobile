import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/history_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/recurring_transactions_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/user_preferences_provider.dart';
import 'utils/string_extensions.dart';
import 'services/recurring_processing_service.dart';
import 'widgets/pending_approvals_dialog.dart';
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
  int _selectedIndex = 0;

  static const List<String> _appBarTitles = [
    'Home',
    'History',
    'Add Transaction',
    'Recurring',
    'Settings',
  ];

  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Home Screen')),
    HistoryScreen(),
    AddTransactionScreen(),
    RecurringTransactionsScreen(),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitles[_selectedIndex].localized(context).cased(context),
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: CupertinoTabBar(
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
            icon: const Icon(Icons.event_repeat),
            label: 'Recurring'.cased(context),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'Settings'.cased(context),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        activeColor: AppColors.primary,
      ),
    );
  }
}
