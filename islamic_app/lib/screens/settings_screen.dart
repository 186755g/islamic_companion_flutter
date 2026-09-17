import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _adhanEnabled = true;
  double _adhanVolume = 1.0;
  String? _fajrAdhanPath;
  String? _regularAdhanPath;
  final _audioPlayer = AudioPlayer();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _adhanEnabled = StorageService.getAdhanEnabled();
    _adhanVolume = StorageService.getAdhanVolume();
    _fajrAdhanPath = StorageService.getFajrAdhanPath();
    _regularAdhanPath = StorageService.getRegularAdhanPath();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  List<EgyptGovernorate> get _filteredGovernorates {
    final query = _searchController.text.trim();
    if (query.isEmpty) return egyptGovernorates;
    return egyptGovernorates
        .where((item) => item.name.contains(query))
        .toList();
  }

  bool _matches(String value) {
    final query = _searchController.text.trim();
    return query.isEmpty || value.contains(query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
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

  Future<void> _setAdhanVolume(double value) async {
    setState(() => _adhanVolume = value);
    await StorageService.setAdhanVolume(value);
  }

  Future<void> _pickAdhanFile({required bool fajr}) async {
    final result = await FilePicker.pickFiles(
      type: FileType.audio,
    );
    final path = result.isEmpty ? null : result.first.path;
    if (path == null || path.isEmpty) return;

    if (fajr) {
      await StorageService.setFajrAdhanPath(path);
      setState(() => _fajrAdhanPath = path);
    } else {
      await StorageService.setRegularAdhanPath(path);
      setState(() => _regularAdhanPath = path);
    }

    if (!mounted) return;
    final times = context.read<PrayerProvider>().times;
    if (times != null) {
      await NotificationService.scheduleDailyPrayerNotifications(times);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(fajr
            ? 'تم اختيار أذان الفجر المخصص'
            : 'تم اختيار أذان الصلوات المخصص'),
      ),
    );
  }

  Future<void> _previewAdhan(String? path, {required bool fajr}) async {
    await _audioPlayer.stop();
    await _audioPlayer.setVolume(_adhanVolume);
    await _audioPlayer.play(
      path == null
          ? AssetSource(
              'android/app/src/main/res/raw/${fajr ? 'adhan_fajr' : 'adhan_regular'}.mp3')
          : DeviceFileSource(path),
    );
  }

  Future<void> _openContact(Uri uri, String errorMessage) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayer = context.watch<PrayerProvider>();
    final selected =
        _selectedGovernorate ?? prayer.selectedGovernorate ?? 'اختر المحافظة';
    final showLocationSection = _matches('الموقع مواقيت الصلاة مصر المحافظة');
    final showAudioSection = _matches('الصوت الإشعارات الأذان الفجر');
    final showRightsSection = _matches(
      'حقوق التطبيق صانع البرنامج المطور محمد احمد التواصل البريد الهاتف واتساب',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'ابحث في الإعدادات أو المحافظات',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'مسح البحث',
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          if (showLocationSection) ...[
            _sectionTitle(context, 'الموقع ومواقيت الصلاة', Icons.location_on),
            const SizedBox(height: 8),
            const Text('اختر مصدر الموقع لحساب المواقيت المناسبة لك.'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'الدولة',
                        prefixIcon: Icon(Icons.public),
                      ),
                      child: Text('مصر'),
                    ),
                    const SizedBox(height: 12),
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
            DropdownButtonFormField<String>(
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
                final governorate =
                    egyptGovernorates.firstWhere((item) => item.name == name);
                _selectGovernorate(governorate);
              },
            ),
            if (_searchController.text.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              ..._filteredGovernorates.map(
                (item) => Card(
                  child: ListTile(
                    title: Text(item.name),
                    leading: const Icon(Icons.location_on_outlined),
                    onTap: () => _selectGovernorate(item),
                  ),
                ),
              ),
              if (_filteredGovernorates.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('لا توجد محافظة بهذا الاسم'),
                ),
            ],
          ],
          if (showAudioSection) ...[
            const SizedBox(height: 24),
            _sectionTitle(context, 'الصوت والإشعارات', Icons.notifications),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      value: _adhanEnabled,
                      onChanged: _setAdhanEnabled,
                      secondary: const Icon(Icons.volume_up_rounded,
                          color: AppColors.deepGreen),
                      title: const Text('تشغيل صوت الأذان'),
                      subtitle: const Text(
                          'يمكنك تخصيص صوت الفجر وباقي الصلوات بشكل مستقل'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.tune),
                      title: const Text('مستوى صوت الأذان'),
                      subtitle: Slider(
                        value: _adhanVolume,
                        min: 0,
                        max: 1,
                        divisions: 20,
                        label: '${(_adhanVolume * 100).round()}%',
                        onChanged: _setAdhanVolume,
                      ),
                      trailing: Text('${(_adhanVolume * 100).round()}%'),
                    ),
                    const Divider(height: 1),
                    _adhanFileTile(
                      title: 'أذان الفجر',
                      path: _fajrAdhanPath,
                      fajr: true,
                    ),
                    _adhanFileTile(
                      title: 'أذان باقي الصلوات',
                      path: _regularAdhanPath,
                      fajr: false,
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        'يتم استخدام مستوى إشعارات الهاتف عند تشغيل الأذان في الخلفية.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (showRightsSection) ...[
            const SizedBox(height: 24),
            _sectionTitle(
                context, 'حقوق التطبيق والتواصل', Icons.verified_user),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.deepGreen.withValues(alpha: 0.12),
                      Theme.of(context).colorScheme.surface,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.deepGreen,
                        child: Icon(Icons.code, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'رفيق المسلم',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'جميع الحقوق محفوظة لصانع التطبيق',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      _contactTile(
                        icon: Icons.person_outline,
                        color: AppColors.deepGreen,
                        title: 'صانع التطبيق',
                        subtitle: 'محمد أحمد',
                      ),
                      _contactTile(
                        icon: Icons.email_outlined,
                        color: Colors.indigo,
                        title: 'البريد الإلكتروني',
                        subtitle: 'mohamedd0103319@gmail.com',
                        onTap: () => _openContact(
                          Uri(
                            scheme: 'mailto',
                            path: 'mohamedd0103319@gmail.com',
                            queryParameters: {
                              'subject': 'التواصل من تطبيق رفيق المسلم'
                            },
                          ),
                          'تعذر فتح تطبيق البريد الإلكتروني',
                        ),
                      ),
                      _contactTile(
                        icon: Icons.phone_outlined,
                        color: Colors.blue,
                        title: 'الهاتف',
                        subtitle: '01040937964',
                        onTap: () => _openContact(
                          Uri(scheme: 'tel', path: '01040937964'),
                          'تعذر فتح تطبيق الاتصال',
                        ),
                      ),
                      _contactTile(
                        icon: Icons.chat_rounded,
                        color: const Color(0xFF25D366),
                        title: 'واتساب',
                        subtitle: 'راسل صانع التطبيق عبر واتساب',
                        onTap: () => _openContact(
                          Uri.parse('https://wa.me/201040937964'),
                          'تعذر فتح واتساب',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (!showLocationSection && !showAudioSection && !showRightsSection)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('لا توجد إعدادات مطابقة للبحث'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.deepGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _adhanFileTile({
    required String title,
    required String? path,
    required bool fajr,
  }) {
    final fileName = path == null
        ? 'الصوت الافتراضي للتطبيق'
        : path.split(RegExp(r'[/\\]')).last;
    return ListTile(
      leading: Icon(fajr ? Icons.nightlight_round : Icons.mosque),
      title: Text(title),
      subtitle: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Wrap(
        spacing: 0,
        children: [
          IconButton(
            tooltip: 'تجربة الصوت',
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _previewAdhan(path, fajr: fajr),
          ),
          IconButton(
            tooltip: 'اختيار ملف صوتي',
            icon: const Icon(Icons.upload_file),
            onPressed: () => _pickAdhanFile(fajr: fajr),
          ),
        ],
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withValues(alpha: 0.16),
        highlightColor: color.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.14),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
