package org.x.aspend.ns

import android.app.Notification
import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class TransactionDetectionService : NotificationListenerService() {
    companion object {
        private const val TAG = "TransactionDetection"
        private const val CHANNEL_NAME = "transaction_detection"

        private var methodChannel: MethodChannel? = null
        private var instance: TransactionDetectionService? = null

        fun setMethodChannel(channel: MethodChannel) {
            methodChannel = channel
        }

        fun getActiveNotifications(): List<Map<String, String>> {
            val inst = instance ?: return emptyList()
            val list = mutableListOf<Map<String, String>>()
            try {
                val active = inst.activeNotifications
                if (active != null) {
                    for (sbn in active) {
                        val notification = sbn.notification
                        val extras = notification.extras
                        val title = extras.getString(Notification.EXTRA_TITLE) ?: ""
                        val text = extras.getString(Notification.EXTRA_TEXT) ?: ""
                        val bigText = extras.getString(Notification.EXTRA_BIG_TEXT) ?: ""
                        val fullText = "$title $text $bigText".trim()
                        
                        list.add(mapOf(
                            "title" to title,
                            "text" to text,
                            "bigText" to bigText,
                            "fullText" to fullText,
                            "packageName" to sbn.packageName,
                            "timestamp" to sbn.postTime.toString()
                        ))
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error getting active notifications: ${e.message}")
            }
            return list
        }
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        Log.d(TAG, "TransactionDetectionService created")
    }

    override fun onDestroy() {
        super.onDestroy()
        if (instance == this) {
            instance = null
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        super.onNotificationPosted(sbn)

        try {
            val notification = sbn.notification
            val extras = notification.extras

            val title = extras.getString(Notification.EXTRA_TITLE) ?: ""
            val text = extras.getString(Notification.EXTRA_TEXT) ?: ""
            val bigText = extras.getString(Notification.EXTRA_BIG_TEXT) ?: ""

            val fullText = "$title $text $bigText".trim()

            Log.d(TAG, "Notification received: $fullText")

            // Send to Flutter for processing
            val channel = methodChannel
            if (channel != null) {
                channel.invokeMethod(
                    "onNotificationReceived", mapOf(
                        "title" to title,
                        "text" to text,
                        "bigText" to bigText,
                        "fullText" to fullText,
                        "packageName" to sbn.packageName
                    )
                )
            } else {
                Log.w(TAG, "MethodChannel not initialized. Saving to pending notifications.")
                
                val sharedPreferences = getSharedPreferences("AspendPrefs", android.content.Context.MODE_PRIVATE)
                val pendingList = sharedPreferences.getStringSet("pending_notifications", mutableSetOf())?.toMutableSet() ?: mutableSetOf()
                
                // Create a JSON-like simple string or proper JSON
                val data = """{"type":"Notification","title":"${title.replace("\"", "\\\"")}","text":"${text.replace("\"", "\\\"")}","bigText":"${bigText.replace("\"", "\\\"")}","fullText":"${fullText.replace("\"", "\\\"")}","packageName":"${sbn.packageName}"}"""
                pendingList.add(data)
                
                sharedPreferences.edit().putStringSet("pending_notifications", pendingList).apply()
            }

        } catch (e: Exception) {
            Log.e(TAG, "Error processing notification: ${e.message}")
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        super.onNotificationRemoved(sbn)
        // We don't need to handle removed notifications for transaction detection
    }
} 