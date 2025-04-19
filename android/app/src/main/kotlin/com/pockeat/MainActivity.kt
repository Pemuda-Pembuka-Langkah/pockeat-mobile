package com.pockeat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
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
    private val WIDGET_CHANNEL = "com.pockeat/custom_home_widget"
    
    companion object {
        private const val TAG = "MainActivity"
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Periksa intent saat aplikasi pertama kali dibuka
        handleIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Update intent dan tangani saat aplikasi sudah berjalan
        setIntent(intent)
        handleIntent(intent)
    }
    
    private fun handleIntent(intent: Intent?) {
        if (intent == null) return
        
        // Cek apakah intent memiliki data dan action VIEW (deep link)
        if (Intent.ACTION_VIEW == intent.action && intent.data != null) {
            val uri = intent.data
            Log.d(TAG, "Received deep link: $uri")
            
            // Tangkap semua deep link dari widget dengan scheme pockeat://
            if (uri.toString().startsWith("pockeat://")) {
                Log.d(TAG, "Detected widget deep link: $uri")
                
                // Widget sekarang langsung memberikan URI dengan format yang benar:
                // Format: pockeat://<groupId>?widgetName=<widgetName>&&type=<action type>
                // Jadi tidak perlu parsing atau formatting khusus lagi
                
                // Tunda sedikit untuk memastikan Flutter engine sudah siap
                Handler(Looper.getMainLooper()).postDelayed({
                    MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, WIDGET_CHANNEL)
                        .invokeMethod("onWidgetClick", mapOf("uri" to uri.toString()))
                    Log.d(TAG, "Sent widget deep link to Flutter: $uri")
                }, 500)
            }
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Daftarkan CustomHomeWidgetPlugin untuk widget kita
        flutterEngine.plugins.add(CustomHomeWidgetPlugin())
        
        // Setup widget channel untuk menerima deep link callback
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "handleWidgetDeepLink" -> {
                    val uriString = call.argument<String>("uri")
                    if (uriString != null) {
                        Log.d(TAG, "Handling widget deep link: $uriString")
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "URI cannot be null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        
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
}