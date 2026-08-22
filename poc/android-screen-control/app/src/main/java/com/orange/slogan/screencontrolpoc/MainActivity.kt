package com.orange.slogan.screencontrolpoc

import android.app.AppOpsManager
import android.content.Context
import android.os.Bundle
import android.os.Process
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.orange.slogan.screencontrolpoc.ui.theme.ScreenControlPOCTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            ScreenControlPOCTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    Greeting(
                        name = "Android",
                        modifier = Modifier.padding(innerPadding)
                    )
                }
            }
        }
    }

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

    }


}

@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    Text(
        text = "Hello $name!",
        modifier = modifier
    )
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    ScreenControlPOCTheme {
        Greeting("Android")
    }
}