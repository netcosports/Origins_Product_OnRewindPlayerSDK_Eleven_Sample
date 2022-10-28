package com.origins.onrewind.android.data.settings

import android.content.SharedPreferences

class Settings(private val preferences: SharedPreferences) {

    var isAnalyticsOverlayEnabled: Boolean
        get() {
            return preferences.getBoolean(KEY_IS_ANALYTICS_OVERLAY_ENABLED, false)
        }
        set(value) {
            preferences.edit()
                .putBoolean(KEY_IS_ANALYTICS_OVERLAY_ENABLED, value)
                .apply()
        }

    companion object {
        private const val KEY_IS_ANALYTICS_OVERLAY_ENABLED = "is_analytics_overlay_enabled"
    }
}