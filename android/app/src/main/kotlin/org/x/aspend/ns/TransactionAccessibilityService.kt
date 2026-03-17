package org.x.aspend.ns

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import android.content.Context
import android.graphics.Bitmap
import android.os.Build
import android.view.Display
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.Executor

class TransactionAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "TxAccessibilityService"
        private var channel: MethodChannel? = null
        private var lastProcessedTime: Long = 0
        private const val THROTTLE_MS = 500L // Process at most every 500ms
        private var lastTextHash: Int = 0

        fun setMethodChannel(methodChannel: MethodChannel) {
            channel = methodChannel
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED ||
            event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
        ) {
            val rootNode = rootInActiveWindow ?: return
            
            // Read target packages from SharedPreferences
            val prefs = getSharedPreferences("detection_settings", Context.MODE_PRIVATE)
            val configuredPackages = prefs.getStringSet("monitored_apps", emptySet()) ?: emptySet()
            
            val targetPackages = if (configuredPackages.isNotEmpty()) {
                configuredPackages.toList()
            } else {
                // Default fallback if nothing configured
                listOf(
                    "com.google.android.apps.nbu.paisa.user", // Google Pay
                    "com.phonepe.app",                       // PhonePe
                    "net.one97.paytm",                       // Paytm
                    "in.amazon.mShop.android.shopping",      // Amazon Pay
                    "com.axis.mobile",                       // Axis Bank
                    "com.hdfcbank.smartbuy"                  // HDFC
                )
            }

            if (targetPackages.contains(event.packageName)) {
                val currentTime = System.currentTimeMillis()
                
                // Throttle content changes, but always process window state changes (new screens)
                if (event.eventType == AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED) {
                    if (currentTime - lastProcessedTime < THROTTLE_MS) {
                        return 
                    }
                }
                
                lastProcessedTime = currentTime
                
                val extractedText = StringBuilder()
                try {
                    traverseNodes(rootNode, extractedText)
                    
                    val text = extractedText.toString()
                    val textHash = text.hashCode()
                    
                    if (textHash == lastTextHash) {
                        return // Content hasn't changed
                    }
                    lastTextHash = textHash
                    
                    if (text.isNotBlank()) {
                        Log.d(TAG, "Detected interaction in payment app: ${event.packageName}")
                        
                        // Check for success markers
                        val isSuccess = isSuccessScreen(text)
                        
                        if (isSuccess && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                            captureScreenshot(event.packageName.toString(), text)
                        } else {
                            sendAccessibilityEvent(event.packageName.toString(), text)
                        }
                    }
                } finally {
                    rootNode.recycle() // CRITICAL: Recycle the root node
                }
            } else {
                rootNode.recycle() // Recycle if we don't care about this package
            }
        }
    }

    private fun isSuccessScreen(text: String): Boolean {
        val markers = listOf(
            "payment successful", "transaction successful", "successful", "paid",
            "sent successfully", "money sent", "payment complete", "payment done"
        )
        val lowerText = text.lowercase()
        return markers.any { lowerText.contains(it) }
    }

    private fun captureScreenshot(packageName: String, text: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            takeScreenshot(Display.DEFAULT_DISPLAY, mainExecutor, object : TakeScreenshotCallback {
                override fun onSuccess(screenshotResult: ScreenshotResult) {
                    val bitmap = Bitmap.wrapHardwareBuffer(screenshotResult.hardwareBuffer, screenshotResult.colorSpace)
                    if (bitmap != null) {
                        val path = saveScreenshot(bitmap)
                        sendAccessibilityEvent(packageName, text, path)
                    } else {
                        sendAccessibilityEvent(packageName, text)
                    }
                }

                override fun onFailure(errorCode: Int) {
                    Log.e(TAG, "Screenshot failed with error code: $errorCode")
                    sendAccessibilityEvent(packageName, text)
                }
            })
        }
    }

    private fun saveScreenshot(bitmap: Bitmap): String? {
        return try {
            val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
            val fileName = "tx_success_$timeStamp.jpg"
            val dir = File(getExternalFilesDir(null), "screenshots")
            if (!dir.exists()) dir.mkdirs()
            val file = File(dir, fileName)
            FileOutputStream(file).use { out ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, 90, out)
            }
            file.absolutePath
        } catch (e: Exception) {
            Log.e(TAG, "Error saving screenshot: ${e.message}")
            null
        }
    }

    private fun sendAccessibilityEvent(packageName: String, text: String, imagePath: String? = null) {
        val methodChannel = channel
        if (methodChannel != null) {
            val data = mutableMapOf(
                "text" to text,
                "packageName" to packageName
            )
            if (imagePath != null) {
                data["imagePath"] = imagePath
            }
            methodChannel.invokeMethod("onAccessibilityEvent", data)
        } else {
            Log.w(TAG, "MethodChannel not initialized. Queuing accessibility event.")
            queueEvent(packageName, text, imagePath)
        }
    }

    private fun queueEvent(packageName: String, text: String, imagePath: String? = null) {
        try {
            val prefs = getSharedPreferences("pending_notifications", Context.MODE_PRIVATE)
            val queue = prefs.getStringSet("queue", mutableSetOf()) ?: mutableSetOf()
            val entry = "{\"type\":\"ACCESSIBILITY\",\"text\":\"${text.replace("\"", "\\\"")}\",\"packageName\":\"${packageName.replace("\"", "\\\"")}\",\"timestamp\":${System.currentTimeMillis()},\"imagePath\":\"${(imagePath ?: "").replace("\"", "\\\"")}\"}"
            queue.add(entry)
            prefs.edit().putStringSet("queue", queue).apply()
        } catch (e: Exception) {
            Log.e(TAG, "Error queuing accessibility event: ${e.message}")
        }
    }

    private fun traverseNodes(node: AccessibilityNodeInfo?, sb: StringBuilder) {
        if (node == null) return
        
        try {
            // Only process visible nodes to reduce noise
            if (!node.isVisibleToUser) return

            if (node.text != null && node.text.isNotBlank()) {
                val nodeText = node.text.toString().trim()
                // Check if this text is already mostly repeated to avoid duplicates in scroll views
                if (!sb.contains(nodeText)) {
                    sb.append(nodeText).append("\n") // Use newline for structural separation
                }
            }
            
            for (i in 0 until node.childCount) {
                val child = node.getChild(i)
                if (child != null) {
                    traverseNodes(child, sb)
                    // We don't recycle here because traverseNodes is recursive 
                    // and we handle child recycling in the loop usually or by the caller.
                    // Actually, the best practice is to recycle EVERY node retrieved.
                    child.recycle() 
                }
            }
        } catch (e: Exception) {
            // Ignore node state exceptions
        }
    }

    override fun onInterrupt() {
        Log.d(TAG, "Service interrupted")
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "Service connected")
    }
}
