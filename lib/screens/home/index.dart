import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gailtrack/state/attendance/provider.dart';
import 'package:gailtrack/state/request/provider.dart';
import 'package:gailtrack/state/tasks/provider.dart';
import 'package:gailtrack/websocket/tasks_service.dart';
import 'package:provider/provider.dart';

import 'package:gailtrack/utils/helper.dart';
import 'package:gailtrack/state/user/provider.dart';
import 'package:gailtrack/components/bottom_navigation.dart';
import 'package:gailtrack/screens/home/tabs/home/index.dart';
import 'package:gailtrack/screens/home/tabs/more/index.dart';
import 'package:gailtrack/screens/home/tabs/people/index.dart';
import 'package:gailtrack/screens/home/tabs/tasks/index.dart';
import 'package:gailtrack/screens/home/tabs/attendance/index.dart';

class Home extends StatefulWidget {
  const Home({super.key}); // Already using const

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _storage = const FlutterSecureStorage(); // Already using const
  bool isSignedIn = false;
  bool isCheckingAuth = true;
  bool isActive = false; 
  bool isxyz = true; 

  int _currentTabIndex = 0;
  final PageController _pageController = PageController(); // Note: PageController can't be const due to internal mutability

  final Map<int, Widget> _loadedTabs = {};

  final Map<int, Widget> _tabs = {
    0: const HomeTab(), // Using const for widget constructors
    1: const Attendance(), // Using const for widget constructors
    2: const Tasks(), // Using const for widget constructors
    3: const People(), // Using const for widget constructors
    4: const More(), // Using const for widget constructors
  };

  void _onTap(int index) {
    setState(() {
      _currentTabIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Widget _getTabContent(int index) {
    return _tabs[index]!;
  }

  @override
  void initState() {
    super.initState();
    checkLoggedIn();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<UserProvider>(context, listen: false).loadData();
      Provider.of<WorkingProvider>(context, listen: false).loadWorking();
      Provider.of<RequestProvider>(context, listen: false).loadRequests();

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.loadtasks();

      final webSocketService = TaskWebSocketService();
      webSocketService.setTaskProvider(taskProvider);
      webSocketService.connect();
    });
  }

  void checkLoggedIn() async {
    try {
      String? authToken = await _storage.read(key: 'authToken');
      String? isBiometricsEnabled =
          await _storage.read(key: 'isBiometricsEnabled');

      if (authToken != null && isBiometricsEnabled == 'true') {
        bool authenticated = await authenticateWithBiometrics();
        if (authenticated) {
          setState(() {
            isSignedIn = true;
            isCheckingAuth = false;
          });
          return;
        }
      }

      setState(() {
        isCheckingAuth = false;
      });

      if (authToken == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/signin');
        });
      }
    } catch (e) {
      setState(() {
        isCheckingAuth = false;
      });
      print('Error checking login: $e');
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _currentTabIndex == 0
              ? "Home"
              : _currentTabIndex == 1
                  ? "Attendance"
                  : _currentTabIndex == 2
                      ? "Tasks"
                      : _currentTabIndex == 3
                          ? "People"
                          : "More",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        leading: const Icon(Icons.notifications_active_rounded),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isActive
                          ? Colors.green 
                          : isxyz
                          ? const Color.fromARGB(255, 255, 157, 59) 
                          : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                isActive
                    ? 'Active' 
                    : isxyz
                    ? 'xyz' 
                    : 'Offline',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _tabs.length,
        onPageChanged: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        itemBuilder: (context, index) => _getTabContent(index),
      ),
      bottomNavigationBar: BottomNavigation(
        currentTabIndex: _currentTabIndex,
        onTap: _onTap,
      ),
    );
  }
}