package com.origins.onrewind.android

import android.app.Application
import com.origins.eleven.OnRewindEleven


class OnRewindSampleApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        OnRewindEleven.initialize(
            OnRewindEleven.InitParams.Builder()
                .setApplicationContext(this)
                .setBaseUrl("https://dev-api-gateway.onrewind.tv/")
                .build()
        )
    }
}