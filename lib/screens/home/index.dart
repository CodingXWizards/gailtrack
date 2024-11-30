import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gailtrack/components/bottom_navigation.dart';
import 'package:gailtrack/screens/home/tabs/attendance/index.dart';
import 'package:gailtrack/screens/home/tabs/home/index.dart';
import 'package:gailtrack/screens/home/tabs/more/index.dart';
import 'package:gailtrack/screens/home/tabs/people/index.dart';
import 'package:gailtrack/screens/home/tabs/tasks/index.dart';
import 'package:gailtrack/utils/helper.dart';

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
    const Attendace(),
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
    checkLoggedIn();
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
            style: Theme.of(context).textTheme.titleSmall),
        leading: const Icon(Icons.notifications_active_rounded),
        actions: [
          InkWell(
            onTap: () {
              _storage.deleteAll();
              Navigator.popAndPushNamed(context, '/signin');
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).focusColor,
              child: const Icon(Icons.person),
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
        children:
            _tabs.map((tab) => SingleChildScrollView(child: tab)).toList(),
      ),
      bottomNavigationBar: BottomNavigation(
        currentTabIndex: _currentTabIndex,
        onTap: _onTap,
      ),
    );
  }
}
