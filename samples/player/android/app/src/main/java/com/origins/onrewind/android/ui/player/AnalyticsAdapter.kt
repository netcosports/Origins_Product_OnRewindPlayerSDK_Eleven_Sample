package com.origins.onrewind.android.ui.player

import android.content.Context
import android.widget.ArrayAdapter
import com.origins.onrewind.android.R
import com.origins.onrewind.domain.analytics.AnalyticsEvent

class AnalyticsAdapter(context: Context) :
    ArrayAdapter<AnalyticsEvent>(context, R.layout.analytics_list_item)