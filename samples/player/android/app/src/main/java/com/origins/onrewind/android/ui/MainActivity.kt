package com.origins.onrewind.android.ui

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.google.android.gms.cast.framework.CastContext
import com.origins.onrewind.OnRewind
import com.origins.onrewind.analytics.OnRewindEventListener
import com.origins.onrewind.android.OnRewindInitializeHelper
import com.origins.onrewind.android.data.DemoApi
import com.origins.onrewind.android.data.entity.StreamItem
import com.origins.onrewind.android.ui.player.PlayerActivity2
import com.origins.onrewind.domain.analytics.AnalyticsEvent
import kotlinx.coroutines.Job


class MainActivity : AppCompatActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            CastContext.getSharedInstance(applicationContext)
        } catch (e: Throwable) {
            //some devices have broken gms, and cast sdk can't be initialized.
        }

        val item = StreamItem(
            title = "Eleven - Club Brugge (First Division A) Test Match",
            eventId = null,
            baseUrl = "https://dev-api-gateway.onrewind.tv/main-api/",
            eventConfigurationUrl = "https://dl.dropboxusercontent.com/s/gy6p16e0sfbjl38/eleven_demo_player_config.json",
            directVideoUrl = null,
            accountKey = "S1itgNWC9",
            heatmapUrl = "<iframe id=\"player\" type=\"text/html\" style=\"width:100%;height:100%;\" src=\"https://dev-eleven-heatmap.origins-digital.com/?extId=958085&season=2017&accountKey=B1oYoKWDK&env=production&isLive=false\" frameborder=\"0\"></iframe>",
            bettingUrl = "<iframe id=\"player\" type=\"text/html\" style=\"width:100%;height:100%;\" src=\"https://dev-eleven-heatmap.origins-digital.com/?extId=958085&season=2017&accountKey=B1oYoKWDK&env=production&isLive=false\" frameborder=\"0\"></iframe>"
        )

        OnRewindInitializeHelper.initializeIfNeeded(this, item.baseUrl)
        OnRewind.removeEventListener(testListener)
        OnRewind.addEventListener(testListener)

        val intent = Intent(this, PlayerActivity2::class.java)
            .putExtra(PlayerActivity2.EXTRA_SAMPLE_DATA, item)
        startActivity(intent)
    }

    companion object {
        private val testListener = TestListener()
    }
}

private class TestListener : OnRewindEventListener {
    override fun onEvent(event: AnalyticsEvent) {
        Log.i("AABBCC", "analytics event $event")
    }
}