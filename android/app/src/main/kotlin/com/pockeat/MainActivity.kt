package com.pockeat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.net.Uri
import io.flutter.plugins.GeneratedPluginRegistrant
import es.antonborri.home_widget.HomeWidgetPlugin

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.pockeat/health_connect"
    private val WIDGET_CHANNEL = "com.pockeat/home_widget"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        HomeWidgetPlugin.registerWith(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchHealthConnect" -> {
                    try {
                        // Get the launch intent for Health Connect
                        val intent = packageManager.getLaunchIntentForPackage("com.google.android.apps.healthdata")
                        if (intent != null) {
                            startActivity(intent)
                            result.success(true)
                        } else {
                            // Try an alternate approach
                            val settingsIntent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                            settingsIntent.data = Uri.parse("package:com.google.android.apps.healthdata")
                            startActivity(settingsIntent)
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "launchHealthConnectPermissions" -> {
                    try {
                        // Use a simpler approach to launch the Health Connect app
                        // with the permissions screen
                        val intent = Intent("androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE")
                        
                        if (intent.resolveActivity(packageManager) != null) {
                            startActivity(intent)
                            result.success(true)
                        } else {
                            // If that doesn't work, try launching the Health Connect app directly
                            val healthConnectIntent = packageManager.getLaunchIntentForPackage("com.google.android.apps.healthdata")
                            if (healthConnectIntent != null) {
                                startActivity(healthConnectIntent)
                                result.success(true)
                            } else {
                                result.success(false)
                            }
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "openHealthConnectPlayStore" -> {
                    try {
                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            data = Uri.parse("market://details?id=com.google.android.apps.healthdata")
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        // If Play Store is not available, open in browser
                        try {
                            val webIntent = Intent(Intent.ACTION_VIEW, 
                                Uri.parse("https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata"))
                            startActivity(webIntent)
                            result.success(true)
                        } catch (e2: Exception) {
                            result.error("ERROR", "Failed to open Play Store: ${e2.message}", null)
                        }
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val data = intent.data
        if (data != null && "pockeat" == data.scheme) {
            HomeWidgetPlugin.handleIntent(intent)
        }
    }
}