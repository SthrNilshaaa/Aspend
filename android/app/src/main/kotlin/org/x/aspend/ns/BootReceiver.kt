package org.x.aspend.ns

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                Log.d(TAG, "Boot completed or package replaced")

                // Start the KeepAliveService to ensure transaction detection stays active
                try {
                    Log.d(TAG, "Starting KeepAliveService from BootReceiver")
                    KeepAliveService.startService(context)
                } catch (e: Exception) {
                    Log.e(TAG, "Error starting service from boot: ${e.message}")
                }
            }
        }
    }
} 