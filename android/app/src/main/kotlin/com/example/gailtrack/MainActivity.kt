package com.example.gailtrack

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings
import java.net.NetworkInterface

class MainActivity: FlutterActivity() {
    private val DEVELOPER_MODE_CHANNEL = "developer_mode_channel"
    private val VPN_DETECTION_CHANNEL = "vpn_detection_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Developer Mode Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVELOPER_MODE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isDeveloperModeEnabled" -> result.success(isDevModeEnabled())
                    else -> result.notImplemented()
                }
            }

        // VPN Detection Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VPN_DETECTION_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isVPNEnabled" -> result.success(isVPNEnabled())
                    else -> result.notImplemented()
                }
            }
    }

    private fun isDevModeEnabled(): Boolean {
        return Settings.Global.getInt(
            contentResolver,
            Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 
            0
        ) != 0
    }

    private fun isVPNEnabled(): Boolean {
        return NetworkInterface.getNetworkInterfaces()
            .toList()
            .any { networkInterface ->
                networkInterface.isUp && 
                (networkInterface.name.startsWith("tun") || 
                 networkInterface.name.startsWith("ppp") || 
                 networkInterface.name.startsWith("pptp"))
            }
    }
}