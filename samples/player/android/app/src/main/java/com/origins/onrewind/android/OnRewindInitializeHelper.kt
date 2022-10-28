package com.origins.onrewind.android

import android.content.Context
import com.origins.onrewind.OnRewind

object OnRewindInitializeHelper {

    @Throws(Exception::class)
    fun initializeIfNeeded(context: Context, baseUrl: String) {
        reset(baseUrl)
        OnRewind.initialize(
            OnRewind.InitParams.Builder()
                .setApplicationContext(context)
                .setBaseUrl(baseUrl)
                .build()
        )
    }

    @Throws(Exception::class)
    private fun reset(baseUrl: String) {
        val reset = OnRewind::class.java.getDeclaredMethod("reset", String::class.java)
        reset.isAccessible = true
        reset.invoke(OnRewind, baseUrl)
    }
}
