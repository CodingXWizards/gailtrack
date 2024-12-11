import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

class VpnDetectorService {
  static Timer? _vpnCheckTimer;
  static ValueNotifier<bool> vpnStatusNotifier = ValueNotifier<bool>(false);

  static Future<bool> isVpnActive() async {
    try {
      // Get network interfaces
      List<NetworkInterface> interfaces = await NetworkInterface.list();

      // Check for VPN-related interfaces (e.g., tun, ppp, or tap)
      for (var interface in interfaces) {
        if (interface.name.contains("tun") ||
            interface.name.contains("ppp") ||
            interface.name.contains("tap")) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error checking VPN status: $e");
      return false;
    }
  }

  // Method to start periodic VPN checking
  static void startPeriodicVpnCheck() {
    // Cancel any existing timer to prevent multiple timers
    _vpnCheckTimer?.cancel();

    _vpnCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      bool isVpnActive = await VpnDetectorService.isVpnActive();
      vpnStatusNotifier.value = isVpnActive;

      if (isVpnActive) {
        // Stop the timer if VPN is detected
        timer.cancel();
      }
    });
  }

  // Method to stop periodic checking
  static void stopPeriodicVpnCheck() {
    _vpnCheckTimer?.cancel();
  }
}

// Wrapper widget to perform initial VPN check
class VpnCheckWrapper extends StatefulWidget {
  final Widget child;

  const VpnCheckWrapper({super.key, required this.child});

  @override
  State<VpnCheckWrapper> createState() => _VpnCheckWrapperState();
}

class _VpnCheckWrapperState extends State<VpnCheckWrapper> {
  @override
  void initState() {
    super.initState();
    _checkInitialVpnStatus();
  }

  @override
  void dispose() {
    VpnDetectorService.stopPeriodicVpnCheck();
    VpnDetectorService.vpnStatusNotifier.dispose();
    super.dispose();
  }

  Future<void> _checkInitialVpnStatus() async {
    bool isVpnActive = await VpnDetectorService.isVpnActive();
    VpnDetectorService.vpnStatusNotifier.value = isVpnActive;

    // Start periodic VPN checking
    VpnDetectorService.startPeriodicVpnCheck();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: VpnDetectorService.vpnStatusNotifier,
      builder: (context, isVpnActive, child) {
        if (isVpnActive) {
          return MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('VPN Detected'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('VPN is active. Please turn off VPN.'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        exit(0);
                      },
                      child: const Text('Exit App'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return widget.child;
      },
    );
  }
}