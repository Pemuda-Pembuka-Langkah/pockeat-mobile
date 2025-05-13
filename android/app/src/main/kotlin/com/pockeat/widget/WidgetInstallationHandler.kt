package com.pockeat.widget

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Handler for widget installation operations
 * 
 * Provides functionality to:
 * 1. Check if widgets are installed on home screen
 * 2. Request user to add widgets to home screen
 */
class WidgetInstallationHandler(private val context: Context, private val activity: Activity?) {
    companion object {
        private const val TAG = "WidgetInstallationHandler"
        
        // Component names for our widgets
        private const val SIMPLE_WIDGET_PROVIDER = "com.pockeat.widget.SimpleFoodTrackingWidgetProvider"
        private const val DETAILED_WIDGET_PROVIDER = "com.pockeat.widget.DetailedFoodTrackingWidgetProvider"
        
        // Method names
        const val CHECK_WIDGET_INSTALLED = "checkWidgetInstalled"
        const val ADD_WIDGET_TO_HOME_SCREEN = "addWidgetToHomeScreen"
    }
    
    /**
     * Handle method calls from Flutter
     */
    fun handleMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            CHECK_WIDGET_INSTALLED -> handleCheckWidgetInstalled(result)
            ADD_WIDGET_TO_HOME_SCREEN -> handleAddWidgetToHomeScreen(call, result)
            else -> result.notImplemented()
        }
    }
    
    /**
     * Check if any widgets are installed on the home screen
     */
    private fun handleCheckWidgetInstalled(result: Result) {
        try {
            val simpleWidgetInstalled = isWidgetInstalled(SIMPLE_WIDGET_PROVIDER)
            val detailedWidgetInstalled = isWidgetInstalled(DETAILED_WIDGET_PROVIDER)
            
            Log.d(TAG, "Widget status - Simple: $simpleWidgetInstalled, Detailed: $detailedWidgetInstalled")
            
            val statusMap = mapOf(
                "isSimpleWidgetInstalled" to simpleWidgetInstalled,
                "isDetailedWidgetInstalled" to detailedWidgetInstalled
            )
            
            result.success(statusMap)
        } catch (e: Exception) {
            Log.e(TAG, "Error checking widget installation status", e)
            result.error("ERROR", "Failed to check widget status: ${e.message}", null)
        }
    }
    
    /**
     * Request to add a widget to the home screen
     */
    private fun handleAddWidgetToHomeScreen(call: MethodCall, result: Result) {
        try {
            if (activity == null) {
                result.error("NO_ACTIVITY", "Activity is null, cannot launch widget picker", null)
                return
            }
            
            // Get the widget type from the call arguments
            val widgetType = call.argument<String>("widgetType")
            if (widgetType == null) {
                result.error("INVALID_ARGS", "widgetType argument is required", null)
                return
            }
            
            val componentName = when (widgetType.lowercase()) {
                "simple" -> ComponentName(context, SIMPLE_WIDGET_PROVIDER)
                "detailed" -> ComponentName(context, DETAILED_WIDGET_PROVIDER)
                else -> {
                    result.error("INVALID_TYPE", "Invalid widget type: $widgetType", null)
                    return
                }
            }
            
            // Launch the widget picker or configuration activity
            val success = launchWidgetPicker(componentName)
            result.success(success)
        } catch (e: Exception) {
            Log.e(TAG, "Error adding widget to home screen", e)
            result.error("ERROR", "Failed to add widget: ${e.message}", null)
        }
    }
    
    /**
     * Check if a specific widget is installed
     */
    private fun isWidgetInstalled(providerClassName: String): Boolean {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val componentName = ComponentName(context.packageName, providerClassName)
        
        // Get all widget IDs for this provider
        val widgetIds = appWidgetManager.getAppWidgetIds(componentName)
        
        // If there are any IDs, the widget is installed
        return widgetIds.isNotEmpty()
    }
    
    /**
     * Launch the widget picker/configuration
     */
    private fun launchWidgetPicker(componentName: ComponentName): Boolean {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // For Android 8.0 (API 26) and above, we can use requestPinAppWidget
                val appWidgetManager = AppWidgetManager.getInstance(context)
                
                if (appWidgetManager.isRequestPinAppWidgetSupported) {
                    // Launch the widget picker
                    appWidgetManager.requestPinAppWidget(componentName, null, null)
                    return true
                } else {
                    Log.w(TAG, "Pin app widget not supported on this device")
                    return false
                }
            } else {
                // For older versions, we need to use a workaround
                // This is a simple approach - we just launch the widget picker intent
                val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_PICK)
                activity?.startActivity(intent)
                return true
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error launching widget picker", e)
            return false
        }
    }
}
