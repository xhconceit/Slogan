package com.orange.slogan.screencontrolpoc

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class AppControlAccessibilityService : AccessibilityService() {
    override fun onServiceConnected() {
        super.onServiceConnected()
        connectedService = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) = Unit

    override fun onInterrupt() = Unit

    override fun onUnbind(intent: Intent?): Boolean {
        if (connectedService === this) {
            connectedService = null
        }

        return super.onUnbind(intent)
    }

    companion object {
        @Volatile
        private var connectedService: AppControlAccessibilityService? = null

        fun returnToHome(): Boolean {
            return connectedService?.performGlobalAction(GLOBAL_ACTION_HOME) ?: false
        }

        fun activePackageName(): String? {
            return connectedService
                ?.rootInActiveWindow
                ?.packageName
                ?.toString()
        }
    }
}
