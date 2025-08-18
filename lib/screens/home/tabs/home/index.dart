import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gailtrack/state/user/model.dart';
import 'package:gailtrack/state/user/provider.dart';
import 'package:gailtrack/state/attendance/model.dart';
import 'package:gailtrack/state/attendance/provider.dart';
import 'package:gailtrack/screens/home/components/custom_card.dart';
import 'package:gailtrack/screens/home/wrappers/box_container.dart';
import 'dart:async';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start timer to update current working duration every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild to show updated working duration
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Method to calculate total working time for today (cumulative of all sessions)
  String getTotalWorkingTime(List<Working> workingList) {
    Duration totalDuration = Duration.zero;

    for (var working in workingList) {
      if (isToday(working.date)) {
        totalDuration += calculateWorkingDuration(working);
      }
    }

    return formatDuration(totalDuration);
  }

  // Get the latest working record for today from the provided list
  Working? getLatestTodayRecord(List<Working> workingList) {
    final today = DateTime.now();
    final todayFormatted = '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    try {
      // Get all records for today and sort by check-in time to get the latest
      final todayRecords = workingList.where((working) {
        final workingDateFormatted =
            '${working.date.year.toString().padLeft(4, '0')}-'
            '${working.date.month.toString().padLeft(2, '0')}-'
            '${working.date.day.toString().padLeft(2, '0')}';
        return workingDateFormatted == todayFormatted;
      }).toList();

      if (todayRecords.isEmpty) return null;

      // Sort by check-in time (most recent first) and return the first one
      todayRecords.sort((a, b) => b.checkIn.compareTo(a.checkIn));
      return todayRecords.first;
    } catch (e) {
      return null;
    }
  }

  // Calculate working duration for a specific working record
  Duration calculateWorkingDuration(Working working) {
    try {
      // Parse check-in time
      final checkInTime = _parseTimeString(working.date, working.checkIn);
      if (checkInTime == null) return Duration.zero;

      // Parse check-out time or use current time if not checked out
      DateTime checkOutTime;
      if (working.checkOut != null && working.checkOut!.isNotEmpty) {
        final parsedCheckOut =
            _parseTimeString(working.date, working.checkOut!);
        if (parsedCheckOut != null) {
          checkOutTime = parsedCheckOut;
        } else {
          checkOutTime = DateTime.now();
        }
      } else {
        checkOutTime = DateTime.now();
      }

      // Calculate duration
      final duration = checkOutTime.difference(checkInTime);

      // Ensure duration is not negative (in case of time parsing issues)
      return duration.isNegative ? Duration.zero : duration;
    } catch (e) {
      print('Error calculating working duration: $e');
      return Duration.zero;
    }
  }

  // Parse time string to DateTime
  DateTime? _parseTimeString(DateTime date, String timeString) {
    try {
      // Handle different time formats
      String formattedTime = timeString;

      // If time is in HH:mm:ss format, keep it as is
      if (timeString.length == 8) {
        formattedTime = timeString;
      }
      // If time is in HH:mm format, add seconds
      else if (timeString.length == 5) {
        formattedTime = '$timeString:00';
      }
      // If time is in HH format, add minutes and seconds
      else if (timeString.length == 2) {
        formattedTime = '$timeString:00:00';
      }

      final dateString = '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

      return DateTime.parse('${dateString}T$formattedTime');
    } catch (e) {
      print('Error parsing time string: $timeString - $e');
      return null;
    }
  }

  // Format duration to human-readable string
  String formatDuration(Duration duration) {
    if (duration.inMinutes == 0) {
      return '0m';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Get current working duration if checked in
  String getCurrentWorkingDuration(List<Working> workingList) {
    final today = DateTime.now();
    final todayFormatted = '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    for (var working in workingList) {
      final workingDateFormatted =
          '${working.date.year.toString().padLeft(4, '0')}-'
          '${working.date.month.toString().padLeft(2, '0')}-'
          '${working.date.day.toString().padLeft(2, '0')}';

      if (workingDateFormatted == todayFormatted &&
          (working.checkOut == null || working.checkOut!.isEmpty)) {
        // Currently working, calculate current duration
        final checkInTime = _parseTimeString(working.date, working.checkIn);
        if (checkInTime != null) {
          final currentDuration = DateTime.now().difference(checkInTime);
          return formatDuration(currentDuration);
        }
      }
    }
    return '0m';
  }

  // Get total completed working time for today (excluding current session)
  String getCompletedWorkingTime(List<Working> workingList) {
    Duration totalDuration = Duration.zero;

    for (var working in workingList) {
      if (isToday(working.date)) {
        // Only count completed sessions (with check-out)
        if (working.checkOut != null && working.checkOut!.isNotEmpty) {
          totalDuration += calculateWorkingDuration(working);
        }
      }
    }

    return formatDuration(totalDuration);
  }

  // Get current session working time (if currently checked in)
  String getCurrentSessionTime(List<Working> workingList) {
    final Working? currentWorking = getCurrentWorkingSession(workingList);

    if (currentWorking != null) {
      return formatDuration(calculateWorkingDuration(currentWorking));
    }
    return '0m';
  }

  // Get current working session details
  Working? getCurrentWorkingSession(List<Working> workingList) {
    final today = DateTime.now();
    final todayFormatted = '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    for (var working in workingList) {
      final workingDateFormatted =
          '${working.date.year.toString().padLeft(4, '0')}-'
          '${working.date.month.toString().padLeft(2, '0')}-'
          '${working.date.day.toString().padLeft(2, '0')}';

      if (workingDateFormatted == todayFormatted &&
          (working.checkOut == null || working.checkOut!.isEmpty)) {
        return working;
      }
    }
    return null;
  }

  // Get working session start time in readable format
  String getSessionStartTime(Working working) {
    try {
      final timeString = working.checkIn;
      if (timeString.length >= 5) {
        return timeString.substring(0, 5); // Return HH:mm format
      }
      return timeString;
    } catch (e) {
      return working.checkIn;
    }
  }

  // Show dialog for manual check-in/check-out
  void _showManualDialog(
      BuildContext context, String type, WorkingProvider workingProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Manual $type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to manually $type?'),
            const SizedBox(height: 16),
            if (workingProvider.isLoading)
              const CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      bool success = false;
                      if (type == "Check-in") {
                        success = await workingProvider.manualCheckIn();
                      } else {
                        success = await workingProvider.manualCheckOut();
                      }

                      if (success) {
                        navigator.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Successfully ${type.toLowerCase()}',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Refresh the UI to show the latest data
                        workingProvider.refreshTodayData();
                      } else {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(workingProvider.error ??
                                'Failed to ${type.toLowerCase()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('Confirm'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, WorkingProvider>(
      builder: (context, userProvider, workingProvider, child) {
        User user = userProvider.user;
        List<Working> workingList = workingProvider.working;

        // Check current status
        final bool isCurrentlyCheckedIn =
            workingProvider.isCurrentlyCheckedIn();
        final Working? todayRecord = getLatestTodayRecord(workingList);

        final String checkInTime = todayRecord?.checkIn.isNotEmpty == true
            ? todayRecord!.checkIn.substring(0, 5)
            : "---";

        final String checkOutTime = todayRecord?.checkOut?.isNotEmpty == true
            ? todayRecord!.checkOut!.substring(0, 5)
            : "---";

        return Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      // Checked-in Box
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!isCurrentlyCheckedIn) {
                              _showManualDialog(
                                  context, "Check-in", workingProvider);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('You are already checked in today'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                          child: BoxContainer(
                            child: Column(
                              children: [
                                Text(
                                  "Checked-in",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                if (workingProvider.isLoading &&
                                    !isCurrentlyCheckedIn)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                else
                                  Text(
                                    checkInTime,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Checked-out Box
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (isCurrentlyCheckedIn) {
                              _showManualDialog(
                                  context, "Check-out", workingProvider);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('You need to check in first'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                          child: BoxContainer(
                            child: Column(
                              children: [
                                Text(
                                  "Checked-out",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                if (workingProvider.isLoading &&
                                    isCurrentlyCheckedIn)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                else
                                  Text(
                                    checkOutTime,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Working Hours
                  BoxContainer(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Working Hours Today",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Row(
                              children: [
                                // Test auto checkout button (for development)
                                IconButton(
                                  onPressed: () =>
                                      workingProvider.triggerAutoCheckout(),
                                  icon: const Icon(Icons.timer, size: 20),
                                  tooltip: 'Test Auto Checkout',
                                ),
                                IconButton(
                                  onPressed: () =>
                                      workingProvider.refreshTodayData(),
                                  icon: workingProvider.isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Icon(Icons.refresh, size: 20),
                                  tooltip: 'Refresh Today\'s Data',
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Total working hours
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              getTotalWorkingTime(workingList),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Auto checkout status and toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: workingProvider.isAutoCheckoutEnabled()
                                    ? Colors.orange.shade50
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: workingProvider.isAutoCheckoutEnabled()
                                      ? Colors.orange.shade200
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color:
                                        workingProvider.isAutoCheckoutEnabled()
                                            ? Colors.orange.shade600
                                            : Colors.grey.shade600,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    workingProvider.isAutoCheckoutEnabled()
                                        ? workingProvider
                                            .getAutoCheckoutStatus()
                                        : 'Auto checkout disabled',
                                    style: TextStyle(
                                      color: workingProvider
                                              .isAutoCheckoutEnabled()
                                          ? Colors.orange.shade700
                                          : Colors.grey.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Toggle button
                            Switch(
                              value: workingProvider.isAutoCheckoutEnabled(),
                              onChanged: (_) =>
                                  workingProvider.toggleAutoCheckout(),
                              activeColor: Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Cards
                  CustomCard(
                    title: user.userType == UserType.hr
                        ? "Check Requests"
                        : "Offsite Work",
                    description: user.userType == UserType.hr
                        ? "You can check your employee requests take action upon it."
                        : "You can request to work offsite if you're unable to come in.",
                    buttonText: user.userType == UserType.hr
                        ? "Requests"
                        : "Request Offsite Work",
                    imagePath: "assets/images/bg1.png",
                    onPressed: () => Navigator.of(context).pushNamed(
                      user.userType == UserType.hr
                          ? "/request/all"
                          : "/request/offsite",
                    ),
                  ),
                  const SizedBox(height: 32),

                  CustomCard(
                    title: "Request a leave or HalfDay",
                    description:
                        "You can request a leave from work to your superiors.",
                    buttonText: "Request a leave",
                    imagePath: "assets/images/bg1.png",
                    onPressed: () =>
                        Navigator.pushNamed(context, '/request/leave'),
                  ),
                  const SizedBox(height: 32),

                  if (user.userType == UserType.hr)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/request/members'),
                      child: Text(
                        "Manage Members",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                ],
              ),
            ));
      },
    );
  }
}
