package com.origins.onrewind.android.data.entity

import java.io.Serializable

data class StreamItem(
    val title: String,
    val eventId: String?,
    val baseUrl: String,
    val eventConfigurationUrl: String?,
    val directVideoUrl: String?,
    val accountKey: String?,
    val heatmapUrl: String?,
    val bettingUrl: String?
) : Serializable {

    override fun toString(): String {
        return title
    }
}