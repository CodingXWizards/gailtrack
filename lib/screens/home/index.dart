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
  bool isCheckingAuth = true; // Added to track loading state

  int _currentTabIndex = 0;
  final PageController _pageController = PageController();
  final List<Widget> _tabs = [
    const HomeTab(),
    const Attendance(),
    const Tasks(),
    const People(),
    const More()
  ];

  void _onTap(int index) {
    //* Triggers Page Change and applies animation
    _pageController.jumpToPage(index);
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

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.loadtasks();

      print("ehllo");
      final webSocketService = TaskWebSocketService();
      webSocketService.setTaskProvider(taskProvider);
      webSocketService.connect();
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
          isCheckingAuth = false; // Stop the loading state
        });
        return;
      }
    }

    // If not authenticated or auth fails
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
    // Loading indicator while checking authentication
    if (isCheckingAuth) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // final userProvider = Provider.of<UserProvider>(context);

    // // Handle loading, error, and data-fetching logic inline
    // if (userProvider.isLoading) {
    //   return const Center(
    //       child: CircularProgressIndicator(color: Colors.white));
    // }

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
                        : _currentTabIndex == 31
                            ? "People"
                            : "More",
            style: Theme.of(context).textTheme.titleSmall),
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
          const SizedBox(width: 12)
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        children: _tabs
            .map(
              (tab) => SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: tab,
                ),
              ),
            )
            .toList(),
      ),
      bottomNavigationBar: BottomNavigation(
        currentTabIndex: _currentTabIndex,
        onTap: _onTap,
      ),
    );
  }
}
