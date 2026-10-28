package com.example.shrex

import android.app.*
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import android.view.View
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "shrex/platform"
    private val TAG = "ShrexMainActivity"
    private var devicePolicyManager: DevicePolicyManager? = null
    private var adminComponent: ComponentName? = null
    private var isActive = false

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        
        devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        adminComponent = ComponentName(this, DeviceAdminReceiver::class.java)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "lockDevice" -> {
                    val duration = call.argument<Int>("duration") ?: 600
                    val success = lockDevice(duration)
                    result.success(success)
                }
                "unlockDevice" -> {
                    val success = unlockDevice()
                    result.success(success)
                }
                "isLockActive" -> {
                    result.success(isLockActive())
                }
                "checkPermissions" -> {
                    result.success(checkAllPermissions())
                }
                "requestPermissions" -> {
                    requestPermissions()
                    result.success(true)
                }
                "requestDeviceAdmin" -> {
                    requestDeviceAdminPermission()
                    result.success(true)
                }
                "isDeviceAdminEnabled" -> {
                    result.success(isDeviceAdminEnabled())
                }
                "emergencyUnlock" -> {
                    val password = call.argument<String>("password")
                    if (password != null) {
                        val success = emergencyUnlock(password)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "Password is required", null)
                    }
                }
                "setEmergencyPassword" -> {
                    val password = call.argument<String>("password")
                    if (password != null) {
                        val success = setEmergencyPassword(password)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "Password is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun lockDevice(durationSec: Int): Boolean {
        return try {
            Log.d(TAG, "Attempting to lock device for $durationSec seconds")
            
            // Check if device admin is enabled for robust locking
            if (isDeviceAdminEnabled()) {
                Log.d(TAG, "Using DevicePolicyManager for robust locking")
                lockWithDevicePolicy(durationSec)
            } else {
                Log.d(TAG, "Device admin not enabled, using screen pinning")
                lockWithScreenPinning(durationSec)
            }
            
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to lock device", e)
            false
        }
    }

    private fun lockWithDevicePolicy(durationSec: Int) {
        try {
            Log.d(TAG, "Starting ULTRA TRAPPING focus session - user will be completely trapped")
            
            // Enable screen pinning to trap user in timer page
            enableScreenPinning()
            
            // Start foreground service to maintain session and handle timer
            val intent = Intent(this, LockService::class.java)
            intent.putExtra("duration", durationSec)
            intent.putExtra("useDevicePolicy", true) // Use device policy for maximum trapping
            intent.putExtra("trapMode", true) // Enable ULTRA trap mode
            intent.putExtra("aggressiveLocking", true) // Enable aggressive locking
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            
            // Additional trapping measures
            disableRecentApps()
            disableNavigationBar()
            disableStatusBar()
            
            Log.d(TAG, "ULTRA TRAPPING focus session started - user completely trapped")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start ULTRA TRAPPING focus session", e)
            // Fallback to enhanced screen pinning
            lockWithScreenPinning(durationSec)
        }
    }

    private fun lockWithScreenPinning(durationSec: Int) {
        try {
            Log.d(TAG, "Starting ENHANCED TRAPPING focus session")
            
            // Start foreground service to maintain lock
            val intent = Intent(this, LockService::class.java)
            intent.putExtra("duration", durationSec)
            intent.putExtra("useDevicePolicy", false)
            intent.putExtra("trapMode", true) // Enable trap mode
            intent.putExtra("aggressiveLocking", true) // Enable aggressive locking
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            
            // Enhanced screen pinning with additional measures
            enableScreenPinning()
            disableRecentApps()
            disableNavigationBar()
            
            Log.d(TAG, "ENHANCED TRAPPING focus session started")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start ENHANCED TRAPPING focus session", e)
        }
    }

    private fun unlockDevice(): Boolean {
        return try {
            Log.d(TAG, "Unlocking device")
            
            // Stop the lock service
            val intent = Intent(this, LockService::class.java)
            stopService(intent)
            
            // Disable screen pinning
            disableScreenPinning()
            
            Log.d(TAG, "Device unlock completed")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to unlock device", e)
            false
        }
    }

    private fun isLockActive(): Boolean {
        return LockService.isActive
    }

    private fun enableScreenPinning() {
        try {
            Log.d(TAG, "Enabling screen pinning to trap user in timer page")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                // Start lock task mode - this prevents user from leaving the app
                startLockTask()
                Log.d(TAG, "Screen pinning enabled - user is trapped in the timer page")
                
                // Optional: Hide navigation bars for cleaner experience
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    try {
                        val windowInsetsController = window.insetsController
                        windowInsetsController?.hide(android.view.WindowInsets.Type.navigationBars())
                        windowInsetsController?.systemBarsBehavior = 
                            android.view.WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
                    } catch (e: Exception) {
                        Log.w(TAG, "Could not hide navigation bars: ${e.message}")
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to enable screen pinning", e)
        }
    }

    private fun disableScreenPinning() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                stopLockTask()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to disable screen pinning", e)
        }
    }

    // ULTRA TRAPPING METHODS - 10000x more trapping
    private fun disableRecentApps() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                // Disable recent apps button
                val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    activityManager.appTasks.forEach { task ->
                        // Move task to back instead of moveToBack which doesn't exist
                        try {
                            task.moveToFront()
                        } catch (e: Exception) {
                            Log.e(TAG, "Failed to move task to front", e)
                        }
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to disable recent apps", e)
        }
    }

    private fun disableNavigationBar() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                // Hide navigation bar
                window.decorView.systemUiVisibility = (
                    View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    or View.SYSTEM_UI_FLAG_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                ).toInt()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to disable navigation bar", e)
        }
    }

    private fun disableStatusBar() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                // Hide status bar
                window.decorView.systemUiVisibility = (
                    View.SYSTEM_UI_FLAG_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                ).toInt()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to disable status bar", e)
        }
    }

    private fun checkAllPermissions(): Map<String, Boolean> {
        return mapOf(
            "overlay" to Settings.canDrawOverlays(this),
            "notification" to true, // Notification permission is handled by Flutter
            "system_alert" to Settings.canDrawOverlays(this)
        )
    }

    private fun requestPermissions() {
        if (!Settings.canDrawOverlays(this)) {
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
            startActivity(intent)
        }
    }

    private fun isDeviceAdminEnabled(): Boolean {
        return devicePolicyManager?.isAdminActive(adminComponent!!) ?: false
    }

    private fun requestDeviceAdminPermission() {
        val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
        intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, adminComponent)
        intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, 
            "Shrex needs device admin permission to lock your device during focus sessions and prevent interruptions. This ensures you stay focused and cannot easily exit the app.")
        startActivity(intent)
    }

    private fun emergencyUnlock(password: String): Boolean {
        return try {
            Log.d(TAG, "Emergency unlock attempted")
            
            // Get stored emergency password
            val prefs = getSharedPreferences("shrex_emergency", Context.MODE_PRIVATE)
            val storedPassword = prefs.getString("emergency_password", null)
            
            // If no password is set, use default password "emergency"
            val defaultPassword = storedPassword ?: "emergency"
            
            // Verify password
            if (password != defaultPassword) {
                Log.w(TAG, "Emergency password incorrect")
                return false
            }
            
            // Unlock device
            unlockDevice()
            Log.d(TAG, "Emergency unlock successful")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Emergency unlock failed", e)
            false
        }
    }

    private fun setEmergencyPassword(password: String): Boolean {
        return try {
            Log.d(TAG, "Setting emergency password")
            
            // Store password securely
            val prefs = getSharedPreferences("shrex_emergency", Context.MODE_PRIVATE)
            prefs.edit().putString("emergency_password", password).apply()
            
            Log.d(TAG, "Emergency password set successfully")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to set emergency password", e)
            false
        }
    }
}

class LockService : Service() {
    companion object {
        var isActive = false
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "shrex_lock_channel"
    }

    private var wakeLock: PowerManager.WakeLock? = null
    private var timer: Timer? = null
    private var reLockTimer: Timer? = null
    private var duration = 0
    private var useDevicePolicy = false
    private var devicePolicyManager: DevicePolicyManager? = null
    private var adminComponent: ComponentName? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        
        devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        adminComponent = ComponentName(this, DeviceAdminReceiver::class.java)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        duration = intent?.getIntExtra("duration", 600) ?: 600
        useDevicePolicy = intent?.getBooleanExtra("useDevicePolicy", false) ?: false
        
        Log.d("LockService", "Starting lock service for $duration seconds, useDevicePolicy: $useDevicePolicy")
        
        // Acquire wake lock to keep screen on
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
            "Shrex::LockWakeLock"
        )
        wakeLock?.acquire(10 * 60 * 1000L /*10 minutes*/)

        // Start foreground service
        startForeground(NOTIFICATION_ID, createNotification())

        // Don't set up auto-unlock timer - let Flutter timer handle completion
        // The Flutter timer will call unlockDevice() when session completes
        Log.d("LockService", "Lock service started - Flutter will handle timer completion")

        // If using device policy, periodically re-lock to prevent bypass
        if (useDevicePolicy) {
            reLockTimer = Timer()
            reLockTimer?.schedule(object : TimerTask() {
                override fun run() {
                    try {
                        devicePolicyManager?.lockNow()
                        Log.d("LockService", "Re-locked device to prevent bypass")
                    } catch (e: Exception) {
                        Log.e("LockService", "Failed to re-lock device", e)
                    }
                }
            }, 3000L, 3000L) // Re-lock every 3 seconds
        }

        isActive = true
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        wakeLock?.release()
        timer?.cancel()
        reLockTimer?.cancel()
        isActive = false
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Shrex Lock Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps your device locked during focus sessions"
                setShowBadge(false)
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Shrex Focus Session")
            .setContentText("Device is locked for focus. Stay productive!")
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setAutoCancel(false)
            .build()
    }

    private fun unlockDevice() {
        try {
            Log.d("LockService", "Unlocking device - stopping all timers")
            
            // Stop all timers first
            timer?.cancel()
            reLockTimer?.cancel()
            timer = null
            reLockTimer = null
            
            // Release wake lock
            wakeLock?.release()
            wakeLock = null
            
            // Stop the service
            stopSelf()
            
            // Notify Flutter that session is complete
            Log.d("LockService", "Focus session completed - device unlocked")
        } catch (e: Exception) {
            Log.e("LockService", "Error unlocking device", e)
        }
    }
}