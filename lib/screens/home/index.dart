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
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _storage = const FlutterSecureStorage();
  bool isSignedIn = false;
  bool isCheckingAuth = true;

  int _currentTabIndex = 0;
  final PageController _pageController = PageController();
  final Map<int, Widget> _loadedTabs = {};

  final Map<int, Future<Widget>> _tabs = {
    0: Future.value(const HomeTab()),
    1: Future.value(const Attendance()),
    2: Future.value(const Tasks()),
    3: Future.value(const People()),
    4: Future.value(const More()),
  };

  void _onTap(int index) {
    setState(() {
      _currentTabIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Future<Widget> _loadTabContent(int index) async {
    // Simulate sideloading with a delay or actual API call
    await Future.delayed(const Duration(seconds: 1));
    return _tabs[index]!;
  }

  Widget _getTabContent(int index) {
    if (_loadedTabs.containsKey(index)) {
      return _loadedTabs[index]!;
    } else {
      return FutureBuilder<Widget>(
        future: _loadTabContent(index),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading tab: ${snapshot.error}'));
          } else {
            final tab = snapshot.data!;
            _loadedTabs[index] = tab;
            return tab;
          }
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkLoggedIn();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<UserProvider>(context, listen: false).loadData();
      Provider.of<WorkingProvider>(context, listen: false).loadWorking();
      Provider.of<RequestProvider>(context, listen: false).loadRequests();

      // final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      // taskProvider.loadtasks();

      // final webSocketService = TaskWebSocketService();
      // webSocketService.setTaskProvider(taskProvider);
      // webSocketService.connect();
    });
  }

  void checkLoggedIn() async {
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
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingAuth) {
      return const Center(child: CircularProgressIndicator());
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
          InkWell(
            onTap: () {},
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).focusColor,
              child: const Center(
                child: Text(
                  "SOS",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
