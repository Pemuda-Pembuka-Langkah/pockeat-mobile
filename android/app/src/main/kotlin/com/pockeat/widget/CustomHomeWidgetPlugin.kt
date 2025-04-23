package com.pockeat.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Plugin yang menangani komunikasi antara Flutter dan home screen widget
 */
class CustomHomeWidgetPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var appGroupId: String? = "group.com.pockeat.widgets" // Default sesuai HomeWidgetConfig.appGroupId
    
    // Konstanta untuk widget keys sesuai dengan FoodTrackingKey di Flutter
    companion object {
        private const val TAG = "CustomHomeWidgetPlugin"
        private const val KEY_CALORIES_NEEDED = "caloriesNeeded"
        private const val KEY_CURRENT_CALORIES_CONSUMED = "currentCaloriesConsumed"
        private const val KEY_CURRENT_PROTEIN = "currentProtein"
        private const val KEY_CURRENT_CARB = "currentCarb"
        private const val KEY_CURRENT_FAT = "currentFat"
        private const val KEY_USER_ID = "userId"
        
        // Nama widget sesuai dengan HomeWidgetConfig widget names
        private const val SIMPLE_WIDGET_NAME = "simple_food_tracking_widget"
        private const val DETAILED_WIDGET_NAME = "detailed_food_tracking_widget"
    }
    
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.pockeat/custom_home_widget")
        channel.setMethodCallHandler(this)
        Log.d(TAG, "CustomHomeWidgetPlugin attached to engine")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "setAppGroupId" -> handleSetAppGroupId(call, result)
            "getWidgetData" -> handleGetWidgetData(call, result)
            "saveWidgetData" -> handleSaveWidgetData(call, result)
            "updateWidget" -> handleUpdateWidget(call, result)
            else -> result.notImplemented()
        }
    }
    
    private fun handleSetAppGroupId(call: MethodCall, result: Result) {
        try {
            val groupId = call.argument<String>("groupId")
            if (groupId != null) {
                appGroupId = groupId
                result.success(true)
            } else {
                result.error("INVALID_ARGUMENT", "Group ID cannot be null", null)
            }
        } catch (e: Exception) {
            result.error("EXCEPTION", "Error setting app group ID: ${e.message}", null)
        }
    }
    
    private fun handleGetWidgetData(call: MethodCall, result: Result) {
        try {
            val key = call.argument<String>("key")
            val groupId = call.argument<String>("appGroupId") ?: appGroupId
            
            if (key == null || groupId == null) {
                result.error("INVALID_ARGUMENT", "Key or app group ID is null", null)
                return
            }
            
            val prefs = context.getSharedPreferences(groupId, Context.MODE_PRIVATE)
            Log.d(TAG, "Getting widget data for key: $key from group: $groupId")
            
            getValueForKey(key, prefs, result)
        } catch (e: Exception) {
            result.error("EXCEPTION", "Error getting widget data: ${e.message}", null)
        }
    }
    
    private fun getValueForKey(key: String, prefs: SharedPreferences, result: Result) {
        when (key) {
            // Nilai numerik (int)
            KEY_CALORIES_NEEDED, KEY_CURRENT_CALORIES_CONSUMED -> {
                val value = prefs.getInt(key, 0)
                Log.d(TAG, "Retrieved INT value for $key: $value")
                result.success(value)
            }
            // Nilai numerik (float/double)
            KEY_CURRENT_PROTEIN, KEY_CURRENT_CARB, KEY_CURRENT_FAT -> {
                // Coba ambil sebagai float terlebih dahulu
                if (prefs.contains(key)) {
                    val value = prefs.getFloat(key, 0f)
                    Log.d(TAG, "Retrieved FLOAT value for $key: $value")
                    result.success(value.toDouble())
                } else {
                    Log.d(TAG, "Key $key not found, returning 0.0")
                    result.success(0.0)
                }
            }
            // String values seperti userId
            KEY_USER_ID -> {
                val value = prefs.getString(key, null)
                Log.d(TAG, "Retrieved STRING value for $key: $value")
                result.success(value)
            }
            // Default untuk key yang tidak dikenal
            else -> getUnknownKeyValue(key, prefs, result)
        }
    }
    
    private fun getUnknownKeyValue(key: String, prefs: SharedPreferences, result: Result) {
        try {
            if (prefs.contains(key)) {
                // Coba ambil sebagai string terlebih dahulu
                if (prefs.getString(key, null) != null) {
                    val value = prefs.getString(key, null)
                    Log.d(TAG, "Retrieved default STRING value for unknown key $key: $value")
                    result.success(value)
                } else if (prefs.getInt(key, -999) != -999) {
                    val value = prefs.getInt(key, 0)
                    Log.d(TAG, "Retrieved default INT value for unknown key $key: $value")
                    result.success(value)
                } else {
                    val value = prefs.getFloat(key, 0f)
                    Log.d(TAG, "Retrieved default FLOAT value for unknown key $key: $value")
                    result.success(value.toDouble())
                }
            } else {
                Log.d(TAG, "Key $key not found, returning null")
                result.success(null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting value for key $key: ${e.message}")
            result.success(null)
        }
    }
    
    private fun handleSaveWidgetData(call: MethodCall, result: Result) {
        try {
            val key = call.argument<String>("key")
            val value = call.argument<Any>("value")
            val groupId = call.argument<String>("appGroupId") ?: appGroupId
            
            if (key == null || groupId == null) {
                result.error("INVALID_ARGUMENT", "Key or app group ID is null", null)
                return
            }
            
            val prefs = context.getSharedPreferences(groupId, Context.MODE_PRIVATE)
            val editor = prefs.edit()
            
            // Log untuk debugging
            Log.d(TAG, "Saving data: key=$key, value=$value, type=${value?.javaClass}")
            
            saveValueByType(key, value, editor)
            
            editor.apply()
            result.success(true)
        } catch (e: Exception) {
            result.error("EXCEPTION", "Error saving widget data: ${e.message}", null)
        }
    }
    
    private fun saveValueByType(key: String, value: Any?, editor: SharedPreferences.Editor) {
        when (value) {
            is Int -> {
                editor.putInt(key, value)
            }
            is Double -> {
                // Untuk key kalori, convert double ke int karena SimpleFoodTrackingWidgetProvider mengharapkan int
                if (key == KEY_CALORIES_NEEDED || key == KEY_CURRENT_CALORIES_CONSUMED) {
                    editor.putInt(key, value.toInt())
                } else {
                    editor.putFloat(key, value.toFloat())
                }
            }
            is Boolean -> {
                editor.putBoolean(key, value)
            }
            is String -> {
                editor.putString(key, value)
            }
            null -> {
                editor.remove(key)
            }
            else -> {
                handleOtherValueTypes(key, value, editor)
            }
        }
    }
    
    private fun handleOtherValueTypes(key: String, value: Any, editor: SharedPreferences.Editor) {
        // Untuk nilai yang tidak spesifik, coba convert ke Int jika key adalah kalori
        if (key == KEY_CALORIES_NEEDED || key == KEY_CURRENT_CALORIES_CONSUMED) {
            val intValue = value.toString().toIntOrNull() ?: 0
            editor.putInt(key, intValue)
        } else {
            editor.putString(key, value.toString())
        }
    }
    
    private fun handleUpdateWidget(call: MethodCall, result: Result) {
        try {
            val name = call.argument<String>("name") ?: ""
            val androidName = call.argument<String>("androidName") ?: name
            
            when (androidName) {
                SIMPLE_WIDGET_NAME -> updateSimpleWidget()
                DETAILED_WIDGET_NAME -> updateDetailedWidget() 
                else -> {
                    // Update semua widget jika tidak ada nama spesifik
                    updateSimpleWidget()
                    updateDetailedWidget()
                }
            }
            
            result.success(true)
        } catch (e: Exception) {
            result.error("EXCEPTION", "Error updating widget: ${e.message}", null)
        }
    }
    
    private fun updateSimpleWidget() {
        try {
            Log.d(TAG, "Updating simple widget")
            
            // Ambil app widget manager
            val appWidgetManager = AppWidgetManager.getInstance(context)
            
            // Dapatkan ID widget yang aktif
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, SimpleFoodTrackingWidgetProvider::class.java)
            )
            
            Log.d(TAG, "Found ${appWidgetIds.size} widget instances")
            
            // Update semua widget yang aktif
            if (appWidgetIds.isNotEmpty()) {
                // Cara 1: Menggunakan broadcast dengan intent
                val intent = Intent(context, SimpleFoodTrackingWidgetProvider::class.java)
                intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
                context.sendBroadcast(intent)
                
                // Cara 2: Update widget langsung (alternatif)
                for (appWidgetId in appWidgetIds) {
                    Log.d(TAG, "Direct updating widget ID: $appWidgetId")
                    val provider = SimpleFoodTrackingWidgetProvider()
                    provider.onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
                }
            } else {
                Log.d(TAG, "No widget instances found")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error updating widget: ${e.message}")
            e.printStackTrace()
        }
    }
    
    private fun updateDetailedWidget() {
        try {
            Log.d(TAG, "Updating detailed widget")
            
            // Ambil app widget manager
            val appWidgetManager = AppWidgetManager.getInstance(context)
            
            // Dapatkan ID widget yang aktif
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, DetailedFoodTrackingWidgetProvider::class.java)
            )
            
            Log.d(TAG, "Found ${appWidgetIds.size} detailed widget instances")
            
            // Update semua widget yang aktif
            if (appWidgetIds.isNotEmpty()) {
                // Cara 1: Menggunakan broadcast dengan intent
                val intent = Intent(context, DetailedFoodTrackingWidgetProvider::class.java)
                intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
                context.sendBroadcast(intent)
                
                // Cara 2: Update widget langsung (alternatif)
                for (appWidgetId in appWidgetIds) {
                    Log.d(TAG, "Direct updating detailed widget ID: $appWidgetId")
                    val provider = DetailedFoodTrackingWidgetProvider()
                    provider.onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
                }
            } else {
                Log.d(TAG, "No detailed widget instances found")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error updating detailed widget: ${e.message}")
            e.printStackTrace()
        }
    }
}
