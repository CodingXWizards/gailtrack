import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentTabIndex;
  final ValueChanged<int> onTap;

  const BottomNavigation({
    super.key,
    required this.currentTabIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomAppBar(
      color: theme.primaryColor,
      padding: const EdgeInsets.all(0),
      height: 72,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1, color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.home_rounded,
              index: 0,
              label: "Home",
            ),
            _buildNavItem(
              context: context,
              icon: Icons.calendar_month_rounded,
              index: 1,
              label: "Calendar",
            ),
            _buildNavItem(
              context: context,
              icon: Icons.task,
              index: 2,
              label: "Tasks",
            ),
            _buildNavItem(
              context: context,
              icon: Icons.groups,
              index: 3,
              label: "Groups",
            ),
            _buildNavItem(
              context: context,
              icon: Icons.settings,
              index: 4,
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required int index,
    required String label,
  }) {
    final isActive = currentTabIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isActive
                      ? theme.colorScheme.secondary.withOpacity(0.2)
                      : theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Icon(
                icon,
                size: 24,
                color:
                    isActive ? theme.colorScheme.secondary : theme.focusColor,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? theme.colorScheme.secondary : theme.focusColor,
            ),
          ),
        ],
      ),
    );
  }
}
