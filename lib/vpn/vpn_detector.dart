import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'package:logging/logging.dart';
import 'dart:async';

class VpnDetectorApp extends StatelessWidget {
  const VpnDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: VpnHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VpnHomePage extends StatefulWidget {
  const VpnHomePage({super.key});

  @override
  VpnHomePageState createState() => VpnHomePageState();
}

class VpnHomePageState extends State<VpnHomePage> {
  bool _isVpnActive = false;
  bool _isLoading = true;
  bool _hasInternet = false;
  final Logger _logger = Logger('VpnHomePage');

  @override
  void initState() {
    super.initState();
    _checkVpnStatus();
  }

  // Check if VPN is active by identifying VPN network interfaces
  Future<void> _checkVpnStatus() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult != ConnectivityResult.none) {
        _isVpnActive = await _isVpnConnected();
      } else {
        _isVpnActive = false;
      }

      if (!_isVpnActive) {
        // If VPN is not active, check for internet connectivity
        _hasInternet = await _checkInternetConnection();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _logger.severe("Error checking VPN status: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to check VPN status based on network interfaces
  Future<bool> _isVpnConnected() async {
    try {
      List<NetworkInterface> interfaces = await NetworkInterface.list();

      for (var interface in interfaces) {
        if (interface.name.contains("tun") ||
            interface.name.contains("ppp") ||
            interface.name.contains("tap")) {
          return true;
        }
      }
      return false;
    } catch (e) {
      _logger.severe("Error fetching network interfaces: $e");
      return false;
    }
  }

  // Method to check if there is an active internet connection
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _logger.info("Internet connection is available");
        return true;
      } else {
        _logger.info("No internet connection");
        return false;
      }
    } catch (e) {
      _logger.severe("Error checking internet connection: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VPN Detector with Internet Check'),
        centerTitle: true,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isVpnActive
                        ? "VPN is Active ..... Turn Off VPN and Try again"
                        : "Login Page",
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  if (!_isVpnActive) // Show internet status only if VPN is off
                    Text(
                      _hasInternet
                          ? "Internet is Connected 📶"
                          : "No Internet Connection 🔌",
                      style: const TextStyle(fontSize: 20),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isLoading = true;
          });
          _checkVpnStatus();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
