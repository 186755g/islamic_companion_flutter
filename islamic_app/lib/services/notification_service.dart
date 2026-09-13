import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../models/prayer_model.dart';

/// يحسب مواقيت الصلاة عبر مكتبة adhan_dart، ويجدول إشعارات محلية عند
/// دخول كل وقت (لا تحتاج إنترنت).
///
/// ⚠️ ملاحظة إصدار: تحقق دوماً من الاسم الفعلي لثوابت طريقة الحساب في
/// إصدار adhan_dart المثبَّت لديك عبر `flutter pub deps` أو ملفات الحزمة
/// في .pub-cache، لأن أسماء الـ API قد تختلف بين الإصدارات.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  static PrayerTimes calculateToday({
    required double latitude,
    required double longitude,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    // ⚠️ لم أستطع التحقق من هذا الاسم مقابل نسخة الحزمة الفعلية في بيئتك
    // (لا أملك وصولاً لمصدر الحزمة من هنا). إن فشل التحليل على هذا السطر،
    // نفّذ نفس الأمر الذي استخدمته سابقاً بنجاح لإيجاد الاسم الصحيح:
    //   grep -R "class CalculationMethod" -n ~/.pub-cache/hosted/pub.dev/adhan_dart-*/lib
    // وعدّل الاستدعاء أدناه ليطابق الـ API الفعلي المكتشف.
  final params = CalculationMethod.muslim_world_league();
    return PrayerTimes(
      coordinates: coordinates,
      date: DateTime.now(),
      calculationParameters: params,
    );
  }

  static Future<void> scheduleDailyPrayerNotifications(PrayerTimes times) async {
    await _plugin.cancelAll();

    final entries = <FardPrayer, DateTime>{
      FardPrayer.fajr: times.fajr!,
      FardPrayer.dhuhr: times.dhuhr!,
      FardPrayer.asr: times.asr!,
      FardPrayer.maghrib: times.maghrib!,
      FardPrayer.isha: times.isha!,
    };

    int id = 0;
    for (final entry in entries.entries) {
      if (entry.value.isAfter(DateTime.now())) {
        await _scheduleAt(
          id: id++,
          title: 'حان الآن وقت صلاة ${entry.key.arabicName}',
          body: 'حي على الصلاة، حي على الفلاح',
          dateTime: entry.value,
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
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
