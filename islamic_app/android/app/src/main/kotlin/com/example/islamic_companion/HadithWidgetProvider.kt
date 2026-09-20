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
    val start = LocalDate.of(LocalDate.now().year, 1, 1)
    val dayIndex = ChronoUnit.DAYS.between(start, LocalDate.now()).toInt()
    val index = if (count == 0) 0 else Math.floorMod(dayIndex, count)
    val text = widgetData.getString("hadith_${index}_text", "حديث اليوم") ?: "حديث اليوم"
    val source = widgetData.getString("hadith_${index}_source", "") ?: ""
    val narrator = widgetData.getString("hadith_${index}_narrator", "") ?: ""
    val attribution = listOf(source, narrator)
        .filter { it.isNotBlank() }
        .joinToString(" — ")
    val currentStreak = widgetData.getInt("streak_current", 0)
    val longestStreak = widgetData.getInt("streak_longest", 0)
    val totalActiveDays = widgetData.getInt("streak_total_days", 0)
    val activeToday = widgetData.getBoolean("streak_active_today", false)

    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.hadith_widget).apply {
        setTextViewText(R.id.widget_hadith_text, text)
        setTextViewText(R.id.widget_hadith_source, attribution)
        setTextViewText(
            R.id.widget_streak_value,
            if (currentStreak == 0) "ابدأ استريكك اليوم" else "$currentStreak يوم متواصل"
        )
        setTextViewText(
            R.id.widget_streak_meta,
            if (activeToday) {
              "تم تسجيل نشاط اليوم • أطول استريك: $longestStreak يوم"
            } else {
              "لم تسجل نشاط اليوم • إجمالي الأيام: $totalActiveDays"
            }
        )
        setProgressBar(R.id.widget_streak_progress, 7, Math.min(currentStreak, 7), false)
        val launchIntent =
            HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
        setOnClickPendingIntent(R.id.widget_hadith_container, launchIntent)
      }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
