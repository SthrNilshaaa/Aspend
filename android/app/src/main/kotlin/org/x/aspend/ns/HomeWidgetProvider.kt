package org.x.aspend.ns

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.util.Log

class HomeWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "HomeWidgetProvider"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            updateWidget(context, appWidgetManager, appWidgetId, options)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        updateWidget(context, appWidgetManager, appWidgetId, newOptions)
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        options: Bundle?
    ) {
        val views = RemoteViews(context.packageName, R.layout.home_widget)

        // Get widget data
        val widgetData = HomeWidgetPlugin.getData(context)
        val balance = widgetData.getString("balance", "₹0.00")
        val income = widgetData.getString("total_income", "0.0")
        val expense = widgetData.getString("total_expenses", "0.0")

        // Update basic views
        views.setTextViewText(R.id.widget_balance, balance)
        views.setTextViewText(R.id.widget_income, "₹${formatAmount(income)}")
        views.setTextViewText(R.id.widget_expense, "₹${formatAmount(expense)}")

        // Optional: Hide stats if widget is too small
        if (options != null) {
            val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
            val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
            
            Log.d(TAG, "Widget ID: $appWidgetId, Size: ${minWidth}x${minHeight}")

            // If height is small, hide stats to save space for buttons and balance
            if (minHeight < 100) {
                views.setViewVisibility(R.id.stats_container, View.GONE)
            } else {
                views.setViewVisibility(R.id.stats_container, View.VISIBLE)
            }
        }

        // Setup Buttons
        setupButton(context, views, R.id.income_button, "ADD_INCOME", 0)
        setupButton(context, views, R.id.expense_button, "ADD_EXPENSE", 1)

        // Update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun setupButton(context: Context, views: RemoteViews, viewId: Int, actionStr: String, reqCode: Int) {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = actionStr
            data = Uri.parse("aspend://$actionStr")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            reqCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(viewId, pendingIntent)
    }

    private fun formatAmount(amountStr: String?): String {
        return try {
            val amount = amountStr?.toDouble() ?: 0.0
            String.format("%.2f", amount)
        } catch (e: Exception) {
            "0.00"
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, HomeWidgetProvider::class.java)
            )
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }
}