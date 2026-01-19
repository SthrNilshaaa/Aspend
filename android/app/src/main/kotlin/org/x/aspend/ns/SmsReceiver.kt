package org.x.aspend.ns

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.SmsMessage
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class SmsReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "SmsReceiver"
        private var methodChannel: MethodChannel? = null

        fun setMethodChannel(channel: MethodChannel) {
            methodChannel = channel
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            try {
                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                if (messages != null) {
                    for (message in messages) {
                        val sender = message.originatingAddress ?: ""
                        val body = message.messageBody ?: ""

                        Log.d(TAG, "SMS received from $sender: $body")

                        // Send to Flutter for processing
                        val channel = methodChannel
                        if (channel != null) {
                            channel.invokeMethod(
                                "onSmsReceived", mapOf(
                                    "sender" to sender,
                                    "body" to body,
                                    "timestamp" to message.timestampMillis
                                )
                            )
                        } else {
                            Log.w(TAG, "MethodChannel not initialized. Queueing SMS.")
                            queueSms(context, sender, body)
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error processing SMS: ${e.message}")
            }
        }
    }

    private fun queueSms(context: Context, sender: String, body: String) {
        try {
            val prefs = context.getSharedPreferences("pending_notifications", Context.MODE_PRIVATE)
            val queue = prefs.getStringSet("queue", mutableSetOf()) ?: mutableSetOf()
            val entry = "SMS|$body|$sender|${System.currentTimeMillis()}"
            queue.add(entry)
            prefs.edit().putStringSet("queue", queue).apply()
        } catch (e: Exception) {
            Log.e(TAG, "Error queuing SMS: ${e.message}")
        }
    }
} 