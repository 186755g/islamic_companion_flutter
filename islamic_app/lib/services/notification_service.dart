import 'dart:convert';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../models/prayer_model.dart';
import 'storage_service.dart';

/// يجلب مواقيت الصلاة من خدمة موثوقة عند توفر الإنترنت، ويستخدم مكتبة
/// adhan_dart كحل احتياطي محلي، ثم يجدول إشعارات الصلاة.
///
/// ⚠️ ملاحظة إصدار: تحقق دوماً من الاسم الفعلي لثوابت طريقة الحساب في
/// إصدار adhan_dart المثبَّت لديك عبر `flutter pub deps` أو ملفات الحزمة
/// في .pub-cache، لأن أسماء الـ API قد تختلف بين الإصدارات.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _exactAlarmsAllowed = false;

  static const _fajrChannelId = 'prayer_times_fajr_v2';
  static const _regularChannelId = 'prayer_times_regular_v2';
  static const _silentChannelId = 'prayer_times_silent_v2';

  static Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);
    final initialized = await _plugin.initialize(initSettings);
    if (initialized != true) return;

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();
    _exactAlarmsAllowed =
        await androidImpl?.canScheduleExactNotifications() ?? false;
    await _createNotificationChannels(androidImpl);
    _initialized = true;
  }

  static Future<void> _createNotificationChannels(
      AndroidFlutterLocalNotificationsPlugin? androidImpl) async {
    if (androidImpl == null) return;

    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        _fajrChannelId,
        'أذان الفجر',
        description: 'صوت أذان الفجر عند دخول وقته',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('adhan_fajr'),
      ),
    );
    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        _regularChannelId,
        'الأذان',
        description: 'صوت الأذان عند دخول وقت الصلاة',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('adhan_regular'),
      ),
    );
    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        _silentChannelId,
        'تذكير الصلاة',
        description: 'تذكير صامت قبل دخول وقت الصلاة',
        importance: Importance.high,
        playSound: false,
      ),
    );
  }

  static String _customChannelId(String prefix, String path) {
    var hash = 0;
    for (final codeUnit in path.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return '${prefix}_custom_$hash';
  }

  static Future<void> _createCustomChannel({
    required String channelId,
    required String name,
    required String path,
  }) async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      AndroidNotificationChannel(
        channelId,
        name,
        description: 'صوت أذان مخصص',
        importance: Importance.max,
        playSound: true,
        sound: UriAndroidNotificationSound(Uri.file(path).toString()),
      ),
    );
  }

  static PrayerTimes calculateToday({
    required double latitude,
    required double longitude,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethodParameters.muslimWorldLeague();
    final times = PrayerTimes(
      coordinates: coordinates,
      date: DateTime.now(),
      calculationParameters: params,
    );
    return _convertUtcTimesToLocal(times);
  }

  static PrayerTimes _convertUtcTimesToLocal(PrayerTimes times) {
    times.fajr = times.fajr.toLocal();
    times.sunrise = times.sunrise.toLocal();
    times.dhuhr = times.dhuhr.toLocal();
    times.asr = times.asr.toLocal();
    times.maghrib = times.maghrib.toLocal();
    times.isha = times.isha.toLocal();
    times.ishaBefore = times.ishaBefore.toLocal();
    times.fajrAfter = times.fajrAfter.toLocal();
    return times;
  }

  /// Fetches today's times from AlAdhan using Egypt's official calculation
  /// method. The local Adhan calculation remains the offline fallback.
  static Future<PrayerTimes?> calculateTodayFromApi({
    required double latitude,
    required double longitude,
  }) async {
    final date = DateTime.now();
    final dateValue =
        '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    final uri = Uri.https('api.aladhan.com', '/v1/timings/$dateValue', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'method': '5',
      'school': '0',
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body);
      if (body is! Map || body['code'] != 200) return null;
      final timings = body['data']?['timings'];
      if (timings is! Map) return null;

      final times = calculateToday(
        latitude: latitude,
        longitude: longitude,
      );
      times.fajr = _apiTime(timings['Fajr'], date);
      times.sunrise = _apiTime(timings['Sunrise'], date);
      times.dhuhr = _apiTime(timings['Dhuhr'], date);
      times.asr = _apiTime(timings['Asr'], date);
      times.maghrib = _apiTime(timings['Maghrib'], date);
      times.isha = _apiTime(timings['Isha'], date);
      return times;
    } catch (_) {
      return null;
    }
  }

  static DateTime _apiTime(Object? value, DateTime date) {
    final raw = value?.toString().split(' ').first ?? '';
    final parts = raw.split(':');
    if (parts.length != 2) {
      throw const FormatException('Invalid prayer time from API');
    }
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  static Future<void> scheduleDailyPrayerNotifications(
      PrayerTimes times) async {
    if (!_initialized) return;
    await _plugin.cancelAll();

    final entries = <FardPrayer, DateTime>{
      FardPrayer.fajr: times.fajr,
      FardPrayer.dhuhr: times.dhuhr,
      FardPrayer.asr: times.asr,
      FardPrayer.maghrib: times.maghrib,
      FardPrayer.isha: times.isha,
    };

    final now = DateTime.now();
    for (final entry in entries.entries) {
      final prayerTime = entry.value;
      if (prayerTime.isAfter(now)) {
        await _scheduleAt(
          id: entry.key.index,
          title: 'حان الآن وقت صلاة ${entry.key.arabicName}',
          body: 'حي على الصلاة، حي على الفلاح',
          dateTime: prayerTime,
          prayer: entry.key,
          isAdhan: true,
        );
      }

      final reminderTime = prayerTime.subtract(const Duration(minutes: 10));
      if (reminderTime.isAfter(now)) {
        await _scheduleAt(
          id: 100 + entry.key.index,
          title: 'اقتربت صلاة ${entry.key.arabicName}',
          body: 'تبقى 10 دقائق على دخول وقت الصلاة.',
          dateTime: reminderTime,
          prayer: entry.key,
          isAdhan: false,
        );
      }
    }
  }

  static Future<void> _scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    required FardPrayer prayer,
    required bool isAdhan,
  }) async {
    final customPath = prayer == FardPrayer.fajr
        ? StorageService.getFajrAdhanPath()
        : StorageService.getRegularAdhanPath();
    final sound = isAdhan && StorageService.getAdhanEnabled()
        ? customPath == null
            ? RawResourceAndroidNotificationSound(
                prayer == FardPrayer.fajr ? 'adhan_fajr' : 'adhan_regular')
            : UriAndroidNotificationSound(Uri.file(customPath).toString())
        : null;
    final channelId = sound == null
        ? _silentChannelId
        : customPath == null
            ? prayer == FardPrayer.fajr
                ? _fajrChannelId
                : _regularChannelId
            : _customChannelId(
                prayer == FardPrayer.fajr ? 'prayer_fajr' : 'prayer_regular',
                customPath,
              );
    if (customPath != null && sound != null) {
      await _createCustomChannel(
        channelId: channelId,
        name: prayer == FardPrayer.fajr ? 'أذان فجر مخصص' : 'أذان مخصص',
        path: customPath,
      );
    }
    final androidDetails = AndroidNotificationDetails(
      channelId,
      'مواقيت الصلاة',
      channelDescription: 'إشعارات دخول أوقات الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      playSound: sound != null,
      sound: sound,
    );
    final iosDetails = DarwinNotificationDetails(
      presentSound: StorageService.getAdhanEnabled(),
    );
    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      details,
      androidScheduleMode: _exactAlarmsAllowed
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
