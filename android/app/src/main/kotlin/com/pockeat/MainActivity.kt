package com.pockeat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.pockeat/health_connect"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchHealthConnect") {
                try {
                    // Get the launch intent for Health Connect
                    val intent = packageManager.getLaunchIntentForPackage("com.google.android.apps.healthdata")
                    if (intent != null) {
                        startActivity(intent)
                        result.success(true)
                    } else {
                        // Try an alternate approach
                        val settingsIntent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                        settingsIntent.data = android.net.Uri.parse("package:com.google.android.apps.healthdata")
                        startActivity(settingsIntent)
                        result.success(true)
                    }
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}