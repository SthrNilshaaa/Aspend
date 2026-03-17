package org.x.aspend.ns

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.util.Log
import android.os.PowerManager
import android.net.Uri
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import java.io.ByteArrayOutputStream
import android.Manifest
import android.os.Build
import android.view.WindowManager
import android.view.Display
import androidx.core.content.ContextCompat
import android.os.Bundle

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val CHANNEL_NAME = "transaction_detection"
    }

    private var pendingWidgetAction: String? = null
    private var isDartReady = false
    private lateinit var channel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Force high refresh rate at the window level
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val display = display
            if (display != null) {
                val modes = display.supportedModes
                // Find mode with highest refresh rate
                val highRefreshMode = modes.maxByOrNull { it.refreshRate }
                if (highRefreshMode != null && highRefreshMode.refreshRate > 60f) {
                    val params = window.attributes
                    params.preferredDisplayModeId = highRefreshMode.modeId
                    window.attributes = params
                    Log.d(TAG, "Setting preferred display mode: ${highRefreshMode.modeId} (${highRefreshMode.refreshRate}Hz)")
                }
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // Older API for M-Q
            val manager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
            val display = manager.defaultDisplay
            val modes = display.supportedModes
            val highRefreshMode = modes.maxByOrNull { it.refreshRate }
            if (highRefreshMode != null && highRefreshMode.refreshRate > 60f) {
                val params = window.attributes
                params.preferredDisplayModeId = highRefreshMode.modeId
                window.attributes = params
                Log.d(TAG, "Setting preferred display mode (legacy): ${highRefreshMode.modeId} (${highRefreshMode.refreshRate}Hz)")
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)

        // Set up method channel for native components
        TransactionDetectionService.setMethodChannel(channel)
        SmsReceiver.setMethodChannel(channel)
        TransactionAccessibilityService.setMethodChannel(channel)

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "appReady" -> {
                    isDartReady = true
                    pendingWidgetAction?.let {
                        handleAction(it)
                        pendingWidgetAction = null
                    }
                    result.success(true)
                }
                "requestNotificationPermission" -> {
                    try {
                        val intent =
                            Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error requesting notification permission: ${e.message}")
                        result.error("PERMISSION_ERROR", e.message, null)
                    }
                }

                "checkNotificationPermission" -> {
                    try {
                        // Check if notification access is enabled
                        val enabled = isNotificationServiceEnabled()
                        result.success(enabled)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error checking notification permission: ${e.message}")
                        result.error("PERMISSION_CHECK_ERROR", e.message, null)
                    }
                }

                "requestSmsPermission" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            requestPermissions(arrayOf(Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS), 101)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error requesting SMS permission: ${e.message}")
                        result.error("SMS_PERMISSION_ERROR", e.message, null)
                    }
                }

                "checkSmsPermission" -> {
                    try {
                        val granted = ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED
                        result.success(granted)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error checking SMS permission: ${e.message}")
                        result.error("SMS_CHECK_ERROR", e.message, null)
                    }
                }

                "requestBatteryOptimization" -> {
                    try {
                        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                        intent.data = Uri.parse("package:$packageName")
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error requesting battery optimization: ${e.message}")
                        result.error("BATTERY_OPTIMIZATION_ERROR", e.message, null)
                    }
                }

                "requestAccessibilityPermission" -> {
                    try {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error requesting accessibility permission: ${e.message}")
                        result.error("ACCESSIBILITY_PERMISSION_ERROR", e.message, null)
                    }
                }

                "checkAccessibilityPermission" -> {
                    try {
                        val enabled = isAccessibilityServiceEnabled()
                        result.success(enabled)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error checking accessibility permission: ${e.message}")
                        result.error("ACCESSIBILITY_CHECK_ERROR", e.message, null)
                    }
                }

                "startKeepAliveService" -> {
                    try {
                        KeepAliveService.startService(this)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error starting keep alive service: ${e.message}")
                        result.error("KEEP_ALIVE_ERROR", e.message, null)
                    }
                }

                "stopKeepAliveService" -> {
                    try {
                        KeepAliveService.stopService(this)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error stopping keep alive service: ${e.message}")
                        result.error("KEEP_ALIVE_ERROR", e.message, null)
                    }
                }

                "processNotification" -> {
                    try {
                        val title = call.argument<String>("title") ?: ""
                        val text = call.argument<String>("text") ?: ""
                        val bigText = call.argument<String>("bigText") ?: ""
                        val fullText = call.argument<String>("fullText") ?: ""
                        val packageName = call.argument<String>("packageName") ?: ""

                        Log.d(TAG, "Processing notification: $fullText")

                        // This will be handled by the Flutter side
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error processing notification: ${e.message}")
                        result.error("PROCESSING_ERROR", e.message, null)
                    }
                }

                "processSms" -> {
                    try {
                        val sender = call.argument<String>("sender") ?: ""
                        val body = call.argument<String>("body") ?: ""
                        val timestamp = call.argument<Long>("timestamp") ?: 0L

                        Log.d(TAG, "Processing SMS from $sender: $body")

                        // This will be handled by the Flutter side
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error processing SMS: ${e.message}")
                        result.error("SMS_PROCESSING_ERROR", e.message, null)
                    }
                }

                "getPendingNotifications" -> {
                    try {
                        val prefs = getSharedPreferences("pending_notifications", Context.MODE_PRIVATE)
                        val queue = prefs.getStringSet("queue", mutableSetOf()) ?: mutableSetOf()
                        val list = queue.toList()
                        
                        // Clear the queue
                        prefs.edit().remove("queue").apply()
                        
                        result.success(list)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error getting pending notifications: ${e.message}")
                        result.error("QUEUE_ERROR", e.message, null)
                    }
                }

                "getInstalledApps" -> {
                    Thread {
                        try {
                            val pm = packageManager
                            val intent = Intent(Intent.ACTION_MAIN, null)
                            intent.addCategory(Intent.CATEGORY_LAUNCHER)
                            val resolveInfos = pm.queryIntentActivities(intent, 0)
                            
                            val appList = mutableListOf<Map<String, Any>>()
                            val processedPackages = mutableSetOf<String>()

                            for (info in resolveInfos) {
                                val packageName = info.activityInfo.packageName
                                if (processedPackages.contains(packageName)) continue

                                val map = mutableMapOf<String, Any>()
                                map["packageName"] = packageName
                                map["appName"] = info.loadLabel(pm).toString()
                                
                                // Get icon as Base64 - Optimized
                                try {
                                    val icon = info.loadIcon(pm)
                                    val bitmap = drawableToBitmap(icon)
                                    // Scale down for list view efficiency
                                    val scaledBitmap = Bitmap.createScaledBitmap(bitmap, 100, 100, true)
                                    val byteArrayOutputStream = ByteArrayOutputStream()
                                    scaledBitmap.compress(Bitmap.CompressFormat.JPEG, 70, byteArrayOutputStream)
                                    val byteArray = byteArrayOutputStream.toByteArray()
                                    map["icon"] = Base64.encodeToString(byteArray, Base64.NO_WRAP)
                                    
                                    if (bitmap != scaledBitmap) bitmap.recycle()
                                } catch (e: Exception) {
                                    // Skip icon if error
                                }
                                
                                appList.add(map)
                                processedPackages.add(packageName)
                            }
                            
                            // Sort by name
                            appList.sortBy { it["appName"].toString().lowercase() }
                            
                            runOnUiThread {
                                result.success(appList)
                            }
                        } catch (e: Exception) {
                            Log.e(TAG, "Error getting installed apps: ${e.message}")
                            runOnUiThread {
                                result.error("GET_APPS_ERROR", e.message, null)
                            }
                        }
                    }.start()
                }

                "saveMonitoredApps" -> {
                    try {
                        val packages = call.argument<List<String>>("packages") ?: emptyList()
                        val prefs = getSharedPreferences("detection_settings", Context.MODE_PRIVATE)
                        prefs.edit().putStringSet("monitored_apps", packages.toSet()).apply()
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error saving monitored apps: ${e.message}")
                        result.error("SAVE_APPS_ERROR", e.message, null)
                    }
                }

                "getMonitoredApps" -> {
                    try {
                        val prefs = getSharedPreferences("detection_settings", Context.MODE_PRIVATE)
                        val packages = prefs.getStringSet("monitored_apps", emptySet()) ?: emptySet()
                        result.success(packages.toList())
                    } catch (e: Exception) {
                        Log.e(TAG, "Error getting monitored apps: ${e.message}")
                        result.error("GET_MONITORED_APPS_ERROR", e.message, null)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isNotificationServiceEnabled(): Boolean {
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        return flat?.contains(packageName) == true
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedComponentName = "$packageName/${TransactionAccessibilityService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
        return enabledServices?.contains(expectedComponentName) == true
    }

    override fun onResume() {
        super.onResume()
        KeepAliveService.startService(this)
        handleWidgetIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleWidgetIntent(intent)
    }

    private fun handleWidgetIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.action
        if (action == "ADD_INCOME" || action == "ADD_EXPENSE") {
            if (isDartReady) {
                handleAction(action)
            } else {
                pendingWidgetAction = action
            }
            intent.action = null
        }
    }

    private fun handleAction(action: String) {
        when (action) {
            "ADD_INCOME" -> channel.invokeMethod("showAddIncomeDialog", null)
            "ADD_EXPENSE" -> channel.invokeMethod("showAddExpenseDialog", null)
        }
    }

    override fun onPause() {
        super.onPause()
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable) {
            return drawable.bitmap
        }
        val bitmap = Bitmap.createBitmap(
            drawable.intrinsicWidth.coerceAtLeast(1),
            drawable.intrinsicHeight.coerceAtLeast(1),
            Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }
}
