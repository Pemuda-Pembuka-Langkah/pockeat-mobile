package com.pockeat.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import com.pockeat.R
import com.pockeat.MainActivity

/**
 * Implementation of App Widget functionality for Simple Food Tracking.
 * App Widget displays calorie consumption progress and provides a quick log action button.
 */
class SimpleFoodTrackingWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "SimpleFoodTrackingWidget"
        
        // App Group ID harus sama dengan HomeWidgetConfig.appGroupId di Flutter
        private const val PREFS_NAME = "group.com.pockeat.widgets"
        
        // Keys harus sesuai dengan FoodTrackingKey.toStorageKey() di Flutter
        // Menggunakan konstanta yang sama dengan CustomHomeWidgetPlugin
        private const val KEY_CALORIES_NEEDED = "caloriesNeeded"
        private const val KEY_CURRENT_CALORIES_CONSUMED = "currentCaloriesConsumed"
        private const val KEY_USER_ID = "userId"
        
        // Widget name harus sesuai dengan HomeWidgetConfig.simpleWidgetName.value
        private const val WIDGET_NAME = "simple_food_tracking_widget"
        
        // Query parameter untuk type action sesuai dengan _determineEventType di Flutter
        private const val PARAM_TYPE = "type"
        private const val ACTION_QUICK_LOG = "quicklog"
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        // Handle widget interaction sesuai dengan package home_widget
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            // Update semua widget yang aktif
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, SimpleFoodTrackingWidgetProvider::class.java)
            )
            for (appWidgetId in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, appWidgetId)
            }
        }
    }

    /**
     * Updates a single widget instance with the latest data
     */
    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        try {
            Log.d(TAG, "Updating widget ID: $appWidgetId")
            
            // Get calorie data from SharedPreferences
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            
            // Log all SharedPreference keys for debugging
            val allKeys = prefs.all.keys
            Log.d(TAG, "Available SharedPreference keys: $allKeys")
            
            // Check if user is logged in by looking for userId
            val userId = prefs.getString(KEY_USER_ID, null)
            val isLoggedIn = !userId.isNullOrEmpty()
            Log.d(TAG, "User login status: $isLoggedIn, userId: $userId")
            
            val caloriesConsumed = prefs.getInt(KEY_CURRENT_CALORIES_CONSUMED, 0)
            val caloriesTarget = prefs.getInt(KEY_CALORIES_NEEDED, 2000) // Default target is 2000
            
            Log.d(TAG, "Calorie data: consumed=$caloriesConsumed, target=$caloriesTarget")
        
        // Create RemoteViews dengan layout widget yang ada
        val views = RemoteViews(context.packageName, R.layout.simple_food_tracking_widget)
        
        if (isLoggedIn) {
            // User is logged in, show normal calorie tracking view
            // Set calorie text
            views.setTextViewText(R.id.calories_text, "$caloriesConsumed/$caloriesTarget")
            
            // Set button text
            views.setTextViewText(R.id.log_food_button, "Log your food")
            
            // Hitung persentase kalori yang sudah dikonsumsi (0-100)
            val percentageConsumed = if (caloriesTarget > 0) {
                // Min antara 100% dan persentase aktual (agar tidak melebihi 100%)
                (caloriesConsumed.toFloat() / caloriesTarget.toFloat() * 100).coerceAtMost(100f).toInt()
            } else 0
            
            // Set progress pada progress bar dengan setProgress
            views.setInt(R.id.calories_progress, "setProgress", percentageConsumed)
            Log.d(TAG, "Progress set to $percentageConsumed%")
        } else {
            // User is NOT logged in, show login prompt
            views.setTextViewText(R.id.calories_text, "Not logged in")
            views.setTextViewText(R.id.log_food_button, "Login")
            
            // Reset progress bar to 0
            views.setInt(R.id.calories_progress, "setProgress", 0)
        }
        
        // Set up "Log your food" button click
        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        
        // Buat intent dengan format URI yang konsisten dengan yang diharapkan di Flutter
        // Format: pockeat://<groupId>?widgetName=<widgetName>&&type=<action type>
        val widgetName = WIDGET_NAME  // Nama widget ini
        val appGroupId = PREFS_NAME  // App group ID
        
        // Check if user is logged in
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val userId = prefs.getString(KEY_USER_ID, null)
        val isLoggedIn = !userId.isNullOrEmpty()
        
        // Different action type based on login status
        val actionType = if (isLoggedIn) {
            "log"  // Action "log" digunakan untuk "Log your food"
        } else {
            "gologin"  // Action "gologin" digunakan untuk navigasi ke halaman login
        }
        
        // Intent untuk button (log food atau login)  
        val buttonIntent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            data = Uri.parse("pockeat://$appGroupId?widgetName=$widgetName&&type=$actionType")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        
        val buttonPendingIntent = PendingIntent.getActivity(
            context,
            0,
            buttonIntent,
            pendingIntentFlags
        )
        
        // Set button click listener
        views.setOnClickPendingIntent(R.id.log_food_button, buttonPendingIntent)
        
        // Intent untuk area utama widget (selalu membuka dashboard utama)
        val mainAreaIntent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            // Selalu menggunakan type=click untuk area utama widget
            data = Uri.parse("pockeat://$appGroupId?widgetName=$widgetName&&type=click") 
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        
        val mainAreaPendingIntent = PendingIntent.getActivity(
            context,
            1, // Gunakan requestCode yang berbeda dari button
            mainAreaIntent,
            pendingIntentFlags
        )
        
        // Set click listener untuk layout utama widget
        views.setOnClickPendingIntent(R.id.main_widget_area, mainAreaPendingIntent)
        
        // Instruct the widget manager to update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
        Log.d(TAG, "Widget updated successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error updating widget: ${e.message}")
            e.printStackTrace()
            
            // Fallback to super basic views in case of error
            try {
                val views = RemoteViews(context.packageName, R.layout.simple_food_tracking_widget)
                views.setTextViewText(R.id.calories_text, "0/2000")
                
                // Set progress bar default dengan setProgress
                views.setInt(R.id.calories_progress, "setProgress", 0)
                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d(TAG, "Fallback widget updated")
            } catch (fallbackError: Exception) {
                Log.e(TAG, "Even fallback failed: ${fallbackError.message}")
            }
        }
    }
    
    /**
     * Static method to update widget data from Flutter
     */
    fun updateWidgetData(context: Context, calories: Int, caloriesTarget: Int, userId: String?) {
        try {
            Log.d(TAG, "updateWidgetData called with: calories=$calories, target=$caloriesTarget, userId=$userId")
            
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val editor = prefs.edit()
            editor.putInt(KEY_CURRENT_CALORIES_CONSUMED, calories)
            editor.putInt(KEY_CALORIES_NEEDED, caloriesTarget)
            userId?.let { editor.putString(KEY_USER_ID, it) }
            editor.apply()
            
            // Log stored values for debugging
            Log.d(TAG, "Stored values - consumed: ${prefs.getInt(KEY_CURRENT_CALORIES_CONSUMED, -1)}, target: ${prefs.getInt(KEY_CALORIES_NEEDED, -1)}")
        
            // Trigger widget update
            val intent = Intent(context, SimpleFoodTrackingWidgetProvider::class.java)
            intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            val ids = AppWidgetManager.getInstance(context)
                .getAppWidgetIds(android.content.ComponentName(context, SimpleFoodTrackingWidgetProvider::class.java))
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            context.sendBroadcast(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Error in updateWidgetData: ${e.message}")
            e.printStackTrace()
        }
    }
}
