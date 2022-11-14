package com.origins.onrewind.android

import android.app.Application
import com.origins.onrewind.OnRewind


class OnRewindSampleApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        OnRewind.initialize(
            OnRewind.InitParams.Builder()
                .setApplicationContext(this)
                .setBaseUrl("https://dev-api-gateway.onrewind.tv/main-api/")
                .build()
        )
    }
}