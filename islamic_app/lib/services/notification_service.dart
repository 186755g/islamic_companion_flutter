import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../models/prayer_model.dart';

/// يحسب مواقيت الصلاة عبر مكتبة adhan_dart، ويجدول إشعارات محلية قبل الصلاة
/// بعشر دقائق وعند دخول وقتها (لا تحتاج إنترنت).
///
/// ⚠️ ملاحظة إصدار: تحقق دوماً من الاسم الفعلي لثوابت طريقة الحساب في
/// إصدار adhan_dart المثبَّت لديك عبر `flutter pub deps` أو ملفات الحزمة
/// في .pub-cache، لأن أسماء الـ API قد تختلف بين الإصدارات.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

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
    _initialized = true;
  }

  static PrayerTimes calculateToday({
    required double latitude,
    required double longitude,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethodParameters.muslimWorldLeague();
    return PrayerTimes(
      coordinates: coordinates,
      date: DateTime.now(),
      calculationParameters: params,
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
        );
      }

      final reminderTime = prayerTime.subtract(const Duration(minutes: 10));
      if (reminderTime.isAfter(now)) {
        await _scheduleAt(
          id: 100 + entry.key.index,
          title: 'اقتربت صلاة ${entry.key.arabicName}',
          body: 'تبقى 10 دقائق على دخول وقت الصلاة.',
          dateTime: reminderTime,
        );
      }
    }
  }

  static Future<void> _scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    // ⚠️ صوت الأذان: RawResourceAndroidNotificationSound('adhan') يشير إلى
    // ملف android/app/src/main/res/raw/adhan.mp3 غير مرفق افتراضياً. بدونه
    // يُستخدم صوت الإشعار الافتراضي للنظام (لا يسبب كراش)، لكن لن تسمع الأذان
    // الفعلي إلا بعد إضافة الملف الصوتي في المسار المذكور.
    const androidDetails = AndroidNotificationDetails(
      'prayer_times_channel',
      'مواقيت الصلاة',
      channelDescription: 'إشعارات دخول أوقات الصلاة',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(presentSound: true);
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
