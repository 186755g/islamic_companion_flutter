import 'dart:async';

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
  DailyPrayerLog _log = DailyPrayerLog(
    dateKey: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
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
  String? get selectedCountry => StorageService.getCountry();
  String? get selectedGovernorate => StorageService.getGovernorate();

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _init() async {
    try {
      _log = StorageService.getLogForDate(_todayKey);
      await _resolveLocationAndTimes();
    } catch (error, stackTrace) {
      debugPrint('PrayerProvider init failed: $error\n$stackTrace');
      _times ??= NotificationService.calculateToday(
        latitude: 21.4225,
        longitude: 39.8262,
      );
      _log = DailyPrayerLog(dateKey: _todayKey);
      _locationNotice ??=
          'تم استخدام مواقيت مكة مؤقتًا بسبب مشكلة في تحديد الموقع.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _resolveLocationAndTimes(
      {bool forceDeviceLocation = false}) async {
    double? lat =
        forceDeviceLocation ? null : StorageService.getLatitude();
    double? lng =
        forceDeviceLocation ? null : StorageService.getLongitude();

    if (lat == null || lng == null) {
      try {
        final permission = await Geolocator.checkPermission()
            .timeout(const Duration(seconds: 8));
        if (permission == LocationPermission.deniedForever) {
          _setLocationNotice(permanentlyDenied: true);
        } else if (permission == LocationPermission.denied) {
          final requestedPermission = await Geolocator.requestPermission()
              .timeout(const Duration(seconds: 8));
          if (requestedPermission == LocationPermission.deniedForever) {
            _setLocationNotice(permanentlyDenied: true);
          } else if (requestedPermission == LocationPermission.denied) {
            _setLocationNotice();
          }
        }

        final currentPermission = await Geolocator.checkPermission()
            .timeout(const Duration(seconds: 8));
        if (currentPermission == LocationPermission.denied ||
            currentPermission == LocationPermission.deniedForever) {
          throw StateError('Location permission was not granted');
        }

        final isEnabled = await Geolocator.isLocationServiceEnabled()
            .timeout(const Duration(seconds: 8));
        if (!isEnabled) {
          _locationNotice = 'فعّل خدمة الموقع لحساب المواقيت حسب مكانك.';
          throw StateError('Location service is disabled');
        }

        const locationSettings = LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        );
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        ).timeout(const Duration(seconds: 10));
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

    _times = await NotificationService.calculateTodayFromApi(
      latitude: lat,
      longitude: lng,
    ) ??
        NotificationService.calculateToday(
          latitude: lat,
          longitude: lng,
        );
    unawaited(_scheduleNotificationsSafely(_times!));
  }

  Future<void> _scheduleNotificationsSafely(PrayerTimes times) async {
    try {
      await NotificationService.scheduleDailyPrayerNotifications(times)
          .timeout(const Duration(seconds: 5));
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
      await _resolveLocationAndTimes(forceDeviceLocation: true);
    } catch (error, stackTrace) {
      debugPrint('Failed to request location permission: $error\n$stackTrace');
      _setLocationNotice();
    } finally {
      _requestingLocationPermission = false;
      notifyListeners();
    }
  }

  Future<void> useMakkahAsDefault() async {
    const makkahLat = 21.4225;
    const makkahLng = 39.8262;
    await StorageService.clearSelectedPlace();
    await StorageService.saveLocation(makkahLat, makkahLng);
    _locationNotice = null;
    _locationPermissionPermanentlyDenied = false;
    _times = await NotificationService.calculateTodayFromApi(
      latitude: makkahLat,
      longitude: makkahLng,
    ) ??
        NotificationService.calculateToday(
          latitude: makkahLat,
          longitude: makkahLng,
        );
    try {
      await NotificationService.scheduleDailyPrayerNotifications(_times!);
    } catch (error, stackTrace) {
      debugPrint(
          'Failed to schedule prayer notifications: $error\n$stackTrace');
    }
    notifyListeners();
  }

  Future<void> setManualLocation(double latitude, double longitude) async {
    final safeLat = latitude.clamp(-90.0, 90.0);
    final safeLng = longitude.clamp(-180.0, 180.0);
    await StorageService.clearSelectedPlace();
    await StorageService.saveLocation(safeLat, safeLng);
    _locationNotice = null;
    _locationPermissionPermanentlyDenied = false;
    _times = await NotificationService.calculateTodayFromApi(
      latitude: safeLat,
      longitude: safeLng,
    ) ??
        NotificationService.calculateToday(
          latitude: safeLat,
          longitude: safeLng,
        );
    try {
      await NotificationService.scheduleDailyPrayerNotifications(_times!);
    } catch (error, stackTrace) {
      debugPrint(
          'Failed to schedule prayer notifications: $error\n$stackTrace');
    }
    notifyListeners();
  }

  Future<void> selectEgyptGovernorate({
    required String governorate,
    required double latitude,
    required double longitude,
  }) async {
    await StorageService.saveSelectedPlace(
      country: 'مصر',
      governorate: governorate,
      latitude: latitude,
      longitude: longitude,
    );
    _locationNotice = null;
    _locationPermissionPermanentlyDenied = false;
    _times = await NotificationService.calculateTodayFromApi(
      latitude: latitude,
      longitude: longitude,
    ) ??
        NotificationService.calculateToday(
          latitude: latitude,
          longitude: longitude,
        );
    await _scheduleNotificationsSafely(_times!);
    notifyListeners();
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
