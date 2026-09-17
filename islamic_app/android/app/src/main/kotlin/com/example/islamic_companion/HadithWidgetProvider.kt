package com.example.islamic_companion

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.time.LocalDate
import java.time.temporal.ChronoUnit

class HadithWidgetProvider : HomeWidgetProvider() {
  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    val count = widgetData.getInt("hadith_count", 0)
    if (count == 0) return

    val start = LocalDate.of(LocalDate.now().year, 1, 1)
    val dayIndex = ChronoUnit.DAYS.between(start, LocalDate.now()).toInt()
    val index = Math.floorMod(dayIndex, count)
    val text = widgetData.getString("hadith_${index}_text", "حديث اليوم") ?: "حديث اليوم"
    val source = widgetData.getString("hadith_${index}_source", "") ?: ""
    val narrator = widgetData.getString("hadith_${index}_narrator", "") ?: ""

    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.hadith_widget).apply {
        setTextViewText(R.id.widget_hadith_text, text)
        setTextViewText(R.id.widget_hadith_source, "$source — $narrator")
        val launchIntent =
            HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
        setOnClickPendingIntent(R.id.widget_hadith_container, launchIntent)
      }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
