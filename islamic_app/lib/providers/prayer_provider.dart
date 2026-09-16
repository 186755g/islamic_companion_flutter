import 'package:flutter/foundation.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../models/prayer_model.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import 'points_provider.dart';

class PrayerProvider extends ChangeNotifier {
  final PointsProvider pointsProvider;
  PrayerProvider({required this.pointsProvider}) {
    _init();
  }

  PrayerTimes? _times;
  late DailyPrayerLog _log;
  bool _loading = true;
  bool _requestingLocationPermission = false;
  String? _locationNotice;
  bool _locationPermissionPermanentlyDenied = false;

  PrayerTimes? get times => _times;
  DailyPrayerLog get log => _log;
  bool get loading => _loading;
  String? get locationNotice => _locationNotice;
  bool get requestingLocationPermission => _requestingLocationPermission;
  bool get locationPermissionPermanentlyDenied =>
      _locationPermissionPermanentlyDenied;

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _init() async {
    _log = StorageService.getLogForDate(_todayKey);
    await _resolveLocationAndTimes();
    _loading = false;
    notifyListeners();
  }

  Future<void> _resolveLocationAndTimes() async {
    double? lat = StorageService.getLatitude();
    double? lng = StorageService.getLongitude();

    if (lat == null || lng == null) {
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.deniedForever) {
          _setLocationNotice(permanentlyDenied: true);
        } else if (permission == LocationPermission.denied) {
          final requestedPermission = await Geolocator.requestPermission();
          if (requestedPermission == LocationPermission.deniedForever) {
            _setLocationNotice(permanentlyDenied: true);
          } else if (requestedPermission == LocationPermission.denied) {
            _setLocationNotice();
          }
        }

        final currentPermission = await Geolocator.checkPermission();
        if (currentPermission == LocationPermission.denied ||
            currentPermission == LocationPermission.deniedForever) {
          throw StateError('Location permission was not granted');
        }

        if (!await Geolocator.isLocationServiceEnabled()) {
          _locationNotice = 'فعّل خدمة الموقع لحساب المواقيت حسب مكانك.';
          throw StateError('Location service is disabled');
        }

        final pos = await Geolocator.getCurrentPosition();
        lat = pos.latitude;
        lng = pos.longitude;
        await StorageService.saveLocation(lat, lng);
      } catch (_) {
        lat = 21.4225;
        lng = 39.8262;
        _locationNotice ??=
            'تم استخدام مواقيت مكة مؤقتًا. اسمح بالوصول إلى موقعك لحساب المواقيت بدقة.';
      }
    }

    _times = NotificationService.calculateToday(latitude: lat, longitude: lng);
    try {
      await NotificationService.scheduleDailyPrayerNotifications(_times!);
    } catch (error, stackTrace) {
      debugPrint(
          'Failed to schedule prayer notifications: $error\n$stackTrace');
    }
  }

  Future<void> requestLocationPermission() async {
    if (_requestingLocationPermission) return;

    _requestingLocationPermission = true;
    notifyListeners();
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        _locationPermissionPermanentlyDenied = true;
        _locationNotice =
            'تم رفض الموقع نهائيًا. افتح إعدادات التطبيق واسمح بالوصول إلى الموقع.';
        await Geolocator.openAppSettings();
        return;
      }

      final requestedPermission = permission == LocationPermission.denied
          ? await Geolocator.requestPermission()
          : permission;
      if (requestedPermission == LocationPermission.deniedForever) {
        _locationPermissionPermanentlyDenied = true;
        _locationNotice =
            'تم رفض الموقع نهائيًا. افتح إعدادات التطبيق واسمح بالوصول إلى الموقع.';
        await Geolocator.openAppSettings();
        return;
      }
      if (requestedPermission == LocationPermission.denied) {
        _setLocationNotice();
        return;
      }

      _locationNotice = null;
      _locationPermissionPermanentlyDenied = false;
      await _resolveLocationAndTimes();
    } catch (error, stackTrace) {
      debugPrint('Failed to request location permission: $error\n$stackTrace');
      _setLocationNotice();
    } finally {
      _requestingLocationPermission = false;
      notifyListeners();
    }
  }

  void _setLocationNotice({bool permanentlyDenied = false}) {
    _locationPermissionPermanentlyDenied = permanentlyDenied;
    _locationNotice = permanentlyDenied
        ? 'تم رفض الموقع نهائيًا. اسمح بالوصول إليه من إعدادات التطبيق.'
        : 'اسمح بالوصول إلى موقعك لحساب مواقيت الصلاة بدقة.';
  }

  bool isFardUnlocked(FardPrayer prayer) {
    if (_times == null) return false;
    final DateTime? entryTime = _timeFor(prayer);
    if (entryTime == null) return false;
    return DateTime.now().isAfter(entryTime);
  }

  DateTime? timeFor(FardPrayer prayer) {
    if (_times == null) return null;
    return _timeFor(prayer);
  }

  DateTime? _timeFor(FardPrayer p) {
    switch (p) {
      case FardPrayer.fajr:
        return _times!.fajr;
      case FardPrayer.dhuhr:
        return _times!.dhuhr;
      case FardPrayer.asr:
        return _times!.asr;
      case FardPrayer.maghrib:
        return _times!.maghrib;
      case FardPrayer.isha:
        return _times!.isha;
    }
  }

  Future<void> toggleFard(FardPrayer prayer) async {
    if (!isFardUnlocked(prayer)) return;
    final key = prayer.name;
    final wasChecked = _log.fardStatus[key] ?? false;
    _log.fardStatus[key] = !wasChecked;
    await StorageService.saveLog(_log);

    final delta =
        !wasChecked ? PointsConfig.fardPoints : -PointsConfig.fardPoints;
    await pointsProvider.addPoints(delta);
    notifyListeners();
  }

  Future<void> toggleSunnah(SunnahPrayer sunnah) async {
    if (!isFardUnlocked(sunnah.relatedFard)) return;
    final key = sunnah.name;
    final wasChecked = _log.sunnahStatus[key] ?? false;
    _log.sunnahStatus[key] = !wasChecked;
    await StorageService.saveLog(_log);

    final delta =
        !wasChecked ? PointsConfig.sunnahPoints : -PointsConfig.sunnahPoints;
    await pointsProvider.addPoints(delta);
    notifyListeners();
  }

  bool fardChecked(FardPrayer p) => _log.fardStatus[p.name] ?? false;
  bool sunnahChecked(SunnahPrayer s) => _log.sunnahStatus[s.name] ?? false;
}
