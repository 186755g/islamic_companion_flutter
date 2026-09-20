package com.example.islamic_companion

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.islamic_companion/adhan"
    private val fajrChannelId = "prayer_times_fajr_v3_alarm"
    private val regularChannelId = "prayer_times_regular_v3_alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "prepareAdhanChannels" -> {
                        prepareAdhanChannels()
                        result.success(null)
                    }
                    "openAdhanPolicySettings" -> {
                        startActivity(
                            Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun prepareAdhanChannels() {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .build()

        listOf(
            fajrChannelId to "أذان الفجر",
            regularChannelId to "الأذان"
        ).forEach { (id, name) ->
            val channel = manager.getNotificationChannel(id)
                ?: NotificationChannel(id, name, NotificationManager.IMPORTANCE_HIGH)
            channel.setBypassDnd(true)
            channel.setSound(
                android.net.Uri.parse(
                    "android.resource://$packageName/raw/" +
                        if (id == fajrChannelId) "adhan_fajr" else "adhan_regular"
                ),
                audioAttributes
            )
            manager.createNotificationChannel(channel)
        }
    }
}
