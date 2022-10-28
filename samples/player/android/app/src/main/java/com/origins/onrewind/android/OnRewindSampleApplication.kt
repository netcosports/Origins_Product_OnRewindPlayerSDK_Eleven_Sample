package com.origins.onrewind.android

import android.app.Application
import android.content.Context
import com.origins.onrewind.android.data.DemoApi

class OnRewindSampleApplication : Application() {

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
    }

    override fun onCreate() {
        super.onCreate()

        DemoApi.init(this)
    }
}