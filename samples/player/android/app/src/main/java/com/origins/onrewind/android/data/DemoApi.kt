package com.origins.onrewind.android.data

import android.content.Context
import com.origins.onrewind.android.data.settings.Settings

object DemoApi {

    fun init(context: Context) {
        val prefs = context.getSharedPreferences("demo_settings", Context.MODE_PRIVATE)
        settings = Settings(prefs)
    }

    lateinit var settings: Settings
        private set

}