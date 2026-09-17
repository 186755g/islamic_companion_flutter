import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/egypt_governorates.dart';
import '../providers/prayer_provider.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedGovernorate;
  bool _showSearch = false;
  bool _adhanEnabled = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _adhanEnabled = StorageService.getAdhanEnabled();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EgyptGovernorate> get _filteredGovernorates {
    final query = _searchController.text.trim();
    if (query.isEmpty) return egyptGovernorates;
    return egyptGovernorates
        .where((item) => item.name.contains(query))
        .toList();
  }

  Future<void> _selectGovernorate(EgyptGovernorate governorate) async {
    setState(() => _selectedGovernorate = governorate.name);
    await context.read<PrayerProvider>().selectEgyptGovernorate(
          governorate: governorate.name,
          latitude: governorate.latitude,
          longitude: governorate.longitude,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('تم تحديث مواقيت الصلاة لمحافظة ${governorate.name}')),
      );
    }
  }

  Future<void> _useDeviceLocation() async {
    setState(() => _selectedGovernorate = null);
    await context.read<PrayerProvider>().requestLocationPermission();
    if (!mounted) return;
    final prayer = context.read<PrayerProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(prayer.locationNotice == null
            ? 'تم تحديث الموقع ومواقيت الصلاة'
            : prayer.locationNotice!),
      ),
    );
  }

  Future<void> _useMakkahLocation() async {
    setState(() => _selectedGovernorate = null);
    await context.read<PrayerProvider>().useMakkahAsDefault();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم استخدام مكة لحساب مواقيت الصلاة')),
    );
  }

  Future<void> _setAdhanEnabled(bool enabled) async {
    await StorageService.setAdhanEnabled(enabled);
    setState(() => _adhanEnabled = enabled);
    if (!mounted) return;
    final times = context.read<PrayerProvider>().times;
    if (times != null) {
      await NotificationService.scheduleDailyPrayerNotifications(times);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(enabled
            ? 'تم تفعيل صوت الأذان'
            : 'تم إيقاف صوت الأذان مع بقاء الإشعارات'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prayer = context.watch<PrayerProvider>();
    final selected =
        _selectedGovernorate ?? prayer.selectedGovernorate ?? 'اختر المحافظة';

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('موقع مواقيت الصلاة',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('اختر الدولة ثم المحافظة لحساب المواقيت المناسبة لموقعك.'),
          const SizedBox(height: 20),
          const InputDecorator(
            decoration: InputDecoration(
              labelText: 'الدولة',
              prefixIcon: Icon(Icons.public),
            ),
            child: Text('مصر'),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'مصدر الموقع',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'يمكنك استخدام موقع الهاتف الحالي أو اختيار موقع بديل.',
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: prayer.requestingLocationPermission
                        ? null
                        : _useDeviceLocation,
                    icon: prayer.requestingLocationPermission
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(prayer.locationPermissionPermanentlyDenied
                        ? 'فتح إعدادات الموقع'
                        : 'استخدام موقع الهاتف الحالي'),
                  ),
                  TextButton.icon(
                    onPressed: _useMakkahLocation,
                    icon: const Icon(Icons.location_city_outlined),
                    label: const Text('استخدام مكة كموقع افتراضي'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile.adaptive(
              value: _adhanEnabled,
              onChanged: _setAdhanEnabled,
              secondary: const Icon(Icons.volume_up_rounded,
                  color: AppColors.deepGreen),
              title: const Text('تشغيل صوت الأذان'),
              subtitle: const Text(
                  'صوت الفجر مستقل، وباقي الصلوات تستخدم صوت الأذان العام'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selected == 'اختر المحافظة' ? null : selected,
                  decoration: const InputDecoration(
                    labelText: 'المحافظة',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  hint: const Text('اختر المحافظة'),
                  items: egyptGovernorates
                      .map((item) => DropdownMenuItem(
                            value: item.name,
                            child: Text(item.name),
                          ))
                      .toList(),
                  onChanged: (name) {
                    if (name == null) return;
                    final governorate = egyptGovernorates
                        .firstWhere((item) => item.name == name);
                    _selectGovernorate(governorate);
                  },
                ),
              ),
              IconButton(
                tooltip: 'البحث عن المحافظة',
                icon: const Icon(Icons.search),
                onPressed: () => setState(() => _showSearch = !_showSearch),
              ),
            ],
          ),
          if (_showSearch) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'ابحث عن محافظة',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'مسح البحث',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            ..._filteredGovernorates.map(
              (item) => ListTile(
                title: Text(item.name),
                leading: const Icon(Icons.location_on_outlined),
                onTap: () => _selectGovernorate(item),
              ),
            ),
            if (_filteredGovernorates.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('لا توجد محافظة بهذا الاسم'),
              ),
          ],
        ],
      ),
    );
  }
}
