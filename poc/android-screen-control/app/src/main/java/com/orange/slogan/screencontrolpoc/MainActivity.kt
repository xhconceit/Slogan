package com.orange.slogan.screencontrolpoc

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Process
import android.provider.Settings
import android.net.Uri
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.orange.slogan.screencontrolpoc.ui.theme.ScreenControlPOCTheme
import android.Manifest
import android.content.pm.PackageManager
class MainActivity : ComponentActivity() {
    private var hasUsageAccess by mutableStateOf(false)
    private var foregroundPackage by mutableStateOf<String?>(null)
    private var canDrawOverlays by mutableStateOf(false)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                100
            )
        }

        val keepAliveIntent =
            Intent(this, KeepAliveService::class.java)

        startForegroundService(keepAliveIntent)

        enableEdgeToEdge()

        setContent {
            ScreenControlPOCTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(innerPadding)
                            .padding(24.dp),
                        verticalArrangement = Arrangement.spacedBy(20.dp),
                    ) {
                        Text(
                            text = "Android Screen Control POC",
                            style = MaterialTheme.typography.headlineSmall,
                        )
                        Text(
                            if (hasUsageAccess) {
                                "使用情况权限：已授权"
                            } else {
                                "使用情况权限：未授权"
                            },
                        )
                        Text("最近前台 App：${foregroundPackage ?: "暂未检测到"}")
                        Text(
                            if (canDrawOverlays) {
                                "悬浮窗权限：已授权（小圆点应显示）"
                            } else {
                                "悬浮窗权限：未授权"
                            },
                        )
                        Button(onClick = ::openOverlaySettings) {
                            Text("打开悬浮窗权限")
                        }
                        Button(onClick = ::openUsageAccessSettings) {
                            Text("打开使用情况访问权限")
                        }
                        Button(onClick = ::refreshUsageState) {
                            Text("重新检测")
                        }

                        Text("当前验证模式：UsageStats + 悬浮窗（不使用无障碍）")
                    }
                }
            }
        }
    }

    // 是否权限
    private fun hasUsageStatsPermission(): Boolean {
        // 向 android 获取某一种系统权限
        val  appOps = getSystemService(
            Context.APP_OPS_SERVICE // App Operations 服务的名称常量
        ) as AppOpsManager
        // 是否允许执行某项特殊操作？
        val mode = appOps.checkOpNoThrow(
            // 读取 App 使用情况
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(), // 当前应用的 UID
            packageName // 当前应用的包名
        )
        // 权限情况。
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun openUsageAccessSettings() {
        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
    }

    private fun openOverlaySettings() {
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:$packageName"),
        )
        startActivity(intent)
    }

    private fun getForegroundPackageName(): String? {
        if (!hasUsageStatsPermission()) {
            return null
        }

        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val endTime = System.currentTimeMillis()
        val startTime = endTime - 10_000

        val usageEvents = usageStatsManager.queryEvents(startTime, endTime)
        val event = UsageEvents.Event()
        var latestPackage: String? = null

        while (usageEvents.hasNextEvent()){
            usageEvents.getNextEvent(event)

            val isForegroundEvent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                event.eventType == UsageEvents.Event.ACTIVITY_RESUMED
            } else {
                @Suppress("DEPRECATION")
                event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND
            }
            if (isForegroundEvent && event.packageName != packageName) {
                latestPackage = event.packageName
            }
        }

        return latestPackage
    }

    override fun onResume() {
        super.onResume()
        refreshUsageState()
    }

    private fun refreshUsageState() {
        hasUsageAccess = hasUsageStatsPermission()
        canDrawOverlays = Settings.canDrawOverlays(this)
        foregroundPackage = getForegroundPackageName()
    }
}
