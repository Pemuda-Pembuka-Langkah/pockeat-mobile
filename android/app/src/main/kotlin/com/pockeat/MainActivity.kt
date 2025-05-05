package com.pockeat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import android.content.Intent
import android.provider.Settings
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.pockeat.widget.CustomHomeWidgetPlugin

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.pockeat/health_connect"
    private val NOTIFICATION_CHANNEL = "com.pockeat/notification_actions"
    private val WIDGET_INSTALLATION_CHANNEL = "com.pockeat/widget_installation"
    
    companion object {
        private const val TAG = "MainActivity"
        private const val HEALTH_CONNECT_PACKAGE = "com.google.android.apps.healthdata"
    }
    
    // Deep link handling sudah ditangani otomatis oleh AppLinks plugin
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register plugins
        registerCustomHomeWidgetPlugin(flutterEngine)
        Log.d("MainActivity", "Successfully Registering CustomHomeWidgetPlugin")
        // Setup method channels
        setupNotificationActionsChannel(flutterEngine)
        setupHealthConnectChannel(flutterEngine)
        setupWidgetInstallationChannel(flutterEngine)
    }
    
    private fun registerCustomHomeWidgetPlugin(flutterEngine: FlutterEngine) {
        // Daftarkan CustomHomeWidgetPlugin untuk widget kita
        // Plugin ini sudah menangani semua interaksi widget <-> Flutter
        flutterEngine.plugins.add(CustomHomeWidgetPlugin())
    }
    
    private fun setupNotificationActionsChannel(flutterEngine: FlutterEngine) {
        // Notification actions channel untuk handling deeplinks dari notifikasi
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_CHANNEL)
            .setMethodCallHandler { call, result ->
                when(call.method) {
                    "launchUri" -> handleLaunchUri(call, result)
                    else -> result.notImplemented()
                }
            }
    }
    
    private fun handleLaunchUri(call: MethodCall, result: Result) {
        try {
            val uriString = call.argument<String>("uri")
            if (uriString != null) {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(uriString))
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                result.success(true)
            } else {
                result.error("NULL_URI", "URI cannot be null", null)
            }
        } catch (e: Exception) {
            result.error("LAUNCH_ERROR", e.message, null)
        }
    }
    
    private fun setupHealthConnectChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "launchHealthConnect" -> handleLaunchHealthConnect(result)
                    "launchHealthConnectPermissions" -> handleLaunchHealthConnectPermissions(result)
                    "openHealthConnectPlayStore" -> handleOpenHealthConnectPlayStore(result)
                    else -> result.notImplemented()
                }
            }
    }
    
    private fun handleLaunchHealthConnect(result: Result) {
        try {
            // Get the launch intent for Health Connect
            val intent = packageManager.getLaunchIntentForPackage(HEALTH_CONNECT_PACKAGE)
            if (intent != null) {
                startActivity(intent)
                result.success(true)
            } else {
                // Try an alternate approach
                val settingsIntent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                settingsIntent.data = Uri.parse("package:$HEALTH_CONNECT_PACKAGE")
                startActivity(settingsIntent)
                result.success(true)
            }
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }
    
    private fun handleLaunchHealthConnectPermissions(result: Result) {
        try {
            // Use a simpler approach to launch the Health Connect app
            // with the permissions screen
            val intent = Intent("androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE")
            
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                result.success(true)
            } else {
                // If that doesn't work, try launching the Health Connect app directly
                val healthConnectIntent = packageManager.getLaunchIntentForPackage(HEALTH_CONNECT_PACKAGE)
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
    
    private fun handleOpenHealthConnectPlayStore(result: Result) {
        try {
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("market://details?id=$HEALTH_CONNECT_PACKAGE")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            // If Play Store is not available, open in browser
            openHealthConnectInBrowser(result, e)
        }
    }
    
    private fun openHealthConnectInBrowser(result: Result, originalException: Exception) {
        try {
            val webIntent = Intent(Intent.ACTION_VIEW, 
                Uri.parse("https://play.google.com/store/apps/details?id=$HEALTH_CONNECT_PACKAGE"))
            startActivity(webIntent)
            result.success(true)
        } catch (e2: Exception) {
            result.error("ERROR", "Failed to open Play Store: ${e2.message}", null)
        }
    }
    
    /**
     * Setup the method channel for widget installation operations
     */
    private fun setupWidgetInstallationChannel(flutterEngine: FlutterEngine) {
        // Create widget installation handler
        val widgetInstallationHandler = com.pockeat.widget.WidgetInstallationHandler(applicationContext, this)
        
        // Setup widget installation method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_INSTALLATION_CHANNEL)
            .setMethodCallHandler { call, result -> 
                widgetInstallationHandler.handleMethodCall(call, result)
            }
    }
}