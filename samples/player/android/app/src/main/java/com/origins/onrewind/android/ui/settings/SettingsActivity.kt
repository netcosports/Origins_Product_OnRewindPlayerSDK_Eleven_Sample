package com.origins.onrewind.android.ui.settings

import android.os.Bundle
import android.view.View
import android.widget.CheckBox
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import com.origins.onrewind.android.R
import com.origins.onrewind.android.data.DemoApi

class SettingsActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_settings)

        findViewById<Toolbar>(R.id.toolbar).setNavigationOnClickListener {
            finish()
        }

        val analyticsOverlayCheckBox = findViewById<CheckBox>(R.id.analyticsOverlayCheckBox)
        analyticsOverlayCheckBox.isChecked = DemoApi.settings.isAnalyticsOverlayEnabled

        findViewById<View>(R.id.analyticsOverlayItem).setOnClickListener {
            analyticsOverlayCheckBox.toggle()
        }
        analyticsOverlayCheckBox.setOnCheckedChangeListener { _, isChecked ->
            DemoApi.settings.isAnalyticsOverlayEnabled = isChecked
        }
    }
}