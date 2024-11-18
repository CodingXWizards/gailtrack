import 'package:flutter/material.dart';
import 'package:gailtrack/components/bottom_navigation.dart';
import 'package:gailtrack/screens/home/tabs/attendance/index.dart';
import 'package:gailtrack/screens/home/tabs/home/index.dart';
import 'package:gailtrack/screens/home/tabs/more/index.dart';
import 'package:gailtrack/screens/home/tabs/people/index.dart';
import 'package:gailtrack/screens/home/tabs/tasks/index.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
    _pageController.jumpToPage(
      index,
    );
  }

  @override
  Widget build(BuildContext context) {
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
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).focusColor,
            child: const Icon(Icons.person),
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
