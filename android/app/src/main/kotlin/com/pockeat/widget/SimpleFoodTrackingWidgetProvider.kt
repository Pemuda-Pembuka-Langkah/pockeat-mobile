package com.pockeat.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
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
        // App Group ID harus sama dengan HomeWidgetConfig.appGroupId di Flutter
        private const val PREFS_NAME = "group.com.pockeat.widgets"
        
        // Keys harus sesuai dengan FoodTrackingKey.toStorageKey() di Flutter
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
        // Get calorie data from SharedPreferences
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val caloriesConsumed = prefs.getInt(KEY_CURRENT_CALORIES_CONSUMED, 0)
        val caloriesTarget = prefs.getInt(KEY_CALORIES_NEEDED, 2000) // Default target is 2000
        
        // Create the RemoteViews object
        val views = RemoteViews(context.packageName, R.layout.simple_food_tracking_widget)
        
        // Set calorie text
        views.setTextViewText(R.id.calories_text, "$caloriesConsumed/$caloriesTarget")
        
        // Hitung persentase kalori yang sudah dikonsumsi (0-100)
        val percentageConsumed = if (caloriesTarget > 0) {
            // Min antara 100% dan persentase aktual (agar tidak melebihi 100%)
            (caloriesConsumed.toFloat() / caloriesTarget.toFloat() * 100).coerceAtMost(100f).toInt()
        } else 0
        
        // Set level pada drawable (0-10000)
        // Android drawable levels berkisar dari 0 hingga 10000
        val level = percentageConsumed * 100
        views.setImageLevel(R.id.progress_arc, level)
        
        // Set up "Log your food" button click
        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        
        // Buat URI format yang sesuai dengan _determineEventType di Flutter
        // Format: pockeat://<appGroupId>?widgetName=<widgetName>&type=<actionType>
        val uri = Uri.parse("pockeat://$PREFS_NAME?widgetName=$WIDGET_NAME&$PARAM_TYPE=$ACTION_QUICK_LOG")
        
        // Create pendingIntent that will be processed by home_widget package
        val logFoodIntent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            data = uri
        }
        val pendingIntent = PendingIntent.getActivity(
            context, 0, logFoodIntent, pendingIntentFlags
        )
        views.setOnClickPendingIntent(R.id.log_food_button, pendingIntent)
        
        // Instruct the widget manager to update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
    
    /**
     * Static method to update widget data from Flutter
     */
    fun updateWidgetData(context: Context, calories: Int, caloriesTarget: Int, userId: String?) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()
        editor.putInt(KEY_CURRENT_CALORIES_CONSUMED, calories)
        editor.putInt(KEY_CALORIES_NEEDED, caloriesTarget)
        userId?.let { editor.putString(KEY_USER_ID, it) }
        editor.apply()
        
        // Trigger widget update
        val intent = Intent(context, SimpleFoodTrackingWidgetProvider::class.java)
        intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        val ids = AppWidgetManager.getInstance(context)
            .getAppWidgetIds(android.content.ComponentName(context, SimpleFoodTrackingWidgetProvider::class.java))
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        context.sendBroadcast(intent)
    }
}
