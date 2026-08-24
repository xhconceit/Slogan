package com.orange.slogan.screencontrolpoc

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.provider.Settings
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.TextView

class KeepAliveService: Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var lastDetectedPackageName: String? = null
    private var lastUsagePackageName: String? = null
    private var lastUsageQueryTime = System.currentTimeMillis() - INITIAL_QUERY_WINDOW
    private var overlayView: View? = null
    private var overlayMode: OverlayMode? = null
    private val windowManager by lazy {
        getSystemService(WINDOW_SERVICE) as WindowManager
    }
    private val restrictedPackageNames = setOf("com.tencent.mm")

    private val foregroundCheckTask = object : Runnable {
        override fun run() {
            checkForegroundPackage()
            handler.postDelayed(this, CHECK_INTERVAL)
        }
    }

    override fun onCreate() {
        super.onCreate()

        createNotificationChannel()

        val notification = Notification.Builder(
            this,
            CHANNEL_ID
        )
            .setContentTitle("再玩")
            .setContentText("App 限制监控正在运行")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else {
            startForeground(
                NOTIFICATION_ID,
                notification
            )
        }

        handler.post(foregroundCheckTask)
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "App 限制监控",
            NotificationManager.IMPORTANCE_LOW
        )

        val notificationManager =
            getSystemService(NotificationManager::class.java)

        notificationManager.createNotificationChannel(channel)
    }

    private fun checkForegroundPackage() {
        val currentPackageName = getLatestForegroundPackageName()
        if (currentPackageName == null) {
            showStatusDot()
            return
        }

        val preferences = getSharedPreferences(FOREGROUND_PREFERENCES, MODE_PRIVATE)

        if (currentPackageName in restrictedPackageNames) {
            showBlockingOverlay()

            preferences
                .edit()
                .putString(LAST_PACKAGE_KEY, currentPackageName)
                .putString(DETECTION_SOURCE_KEY, SOURCE_USAGE_STATS)
                .putLong(DETECTED_AT_KEY, System.currentTimeMillis())
                .putString(LAST_BLOCKED_PACKAGE_KEY, currentPackageName)
                .putLong(BLOCKED_AT_KEY, System.currentTimeMillis())
                .putBoolean(OVERLAY_BLOCKED_KEY, true)
                .commit()

            return
        }

        showStatusDot()

        if (currentPackageName == lastDetectedPackageName) {
            return
        }

        lastDetectedPackageName = currentPackageName

        if (currentPackageName == packageName) {
            return
        }

        preferences
            .edit()
            .putString(LAST_PACKAGE_KEY, currentPackageName)
            .putString(DETECTION_SOURCE_KEY, SOURCE_USAGE_STATS)
            .putLong(DETECTED_AT_KEY, System.currentTimeMillis())
            .commit()
    }

    private fun showStatusDot() {
        if (!Settings.canDrawOverlays(this)) {
            removeOverlay()
            return
        }

        if (overlayMode == OverlayMode.STATUS_DOT && overlayView != null) {
            return
        }

        removeOverlay()

        val size = (16 * resources.displayMetrics.density).toInt()
        val dot = View(this).apply {
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.rgb(255, 152, 0))
                setStroke(
                    (2 * resources.displayMetrics.density).toInt(),
                    Color.WHITE,
                )
            }
            contentDescription = "再玩悬浮窗诊断标记"
        }
        val layoutParams = WindowManager.LayoutParams(
            size,
            size,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.END
            x = (12 * resources.displayMetrics.density).toInt()
            y = (96 * resources.displayMetrics.density).toInt()
        }

        try {
            windowManager.addView(dot, layoutParams)
            overlayView = dot
            overlayMode = OverlayMode.STATUS_DOT
        } catch (_: RuntimeException) {
            overlayView = null
            overlayMode = null
        }
    }

    private fun showBlockingOverlay() {
        if (!Settings.canDrawOverlays(this)) {
            removeOverlay()
            return
        }

        if (overlayMode == OverlayMode.BLOCKING && overlayView != null) {
            return
        }

        removeOverlay()

        val blocker = TextView(this).apply {
            setBackgroundColor(Color.rgb(255, 248, 235))
            setTextColor(Color.rgb(35, 35, 35))
            textSize = 24f
            gravity = Gravity.CENTER
            text = "今天的任务还没有完成\n\n浏览器暂时不可使用\n\n点击返回桌面"
            setPadding(48, 48, 48, 48)
            setOnClickListener {
                startActivity(
                    Intent(Intent.ACTION_MAIN)
                        .addCategory(Intent.CATEGORY_HOME)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                )
            }
        }
        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
        }

        try {
            windowManager.addView(blocker, layoutParams)
            overlayView = blocker
            overlayMode = OverlayMode.BLOCKING
        } catch (_: RuntimeException) {
            overlayView = null
            overlayMode = null
        }
    }

    private fun removeOverlay() {
        val view = overlayView ?: return
        try {
            windowManager.removeView(view)
        } catch (_: RuntimeException) {
            // The system may already have removed the window after permission revocation.
        } finally {
            overlayView = null
            overlayMode = null
        }
    }

    private fun getLatestForegroundPackageName(): String? {
        val usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val endTime = System.currentTimeMillis()
        val events = usageStatsManager.queryEvents(lastUsageQueryTime, endTime)
        val event = UsageEvents.Event()

        while (events.hasNextEvent()) {
            events.getNextEvent(event)

            val isForegroundEvent =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    event.eventType == UsageEvents.Event.ACTIVITY_RESUMED
                } else {
                    @Suppress("DEPRECATION")
                    event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND
                }

            if (isForegroundEvent) {
                lastUsagePackageName = event.packageName
            }
        }

        lastUsageQueryTime = endTime
        return lastUsagePackageName
    }

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int
    ): Int {
        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(foregroundCheckTask)
        removeOverlay()
        super.onDestroy()
    }

    companion object {
        private const val CHANNEL_ID = "app_control_monitor"
        private const val NOTIFICATION_ID = 1001
        private const val CHECK_INTERVAL = 500L
        private const val INITIAL_QUERY_WINDOW = 60_000L
        private const val FOREGROUND_PREFERENCES = "foreground_polling"
        private const val LAST_PACKAGE_KEY = "last_package"
        private const val DETECTION_SOURCE_KEY = "detection_source"
        private const val DETECTED_AT_KEY = "detected_at"
        private const val LAST_BLOCKED_PACKAGE_KEY = "last_blocked_package"
        private const val BLOCKED_AT_KEY = "blocked_at"
        private const val OVERLAY_BLOCKED_KEY = "overlay_blocked"
        private const val SOURCE_USAGE_STATS = "usage_stats"
    }

    private enum class OverlayMode {
        STATUS_DOT,
        BLOCKING,
    }
}
