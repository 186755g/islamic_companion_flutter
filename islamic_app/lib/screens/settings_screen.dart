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
  List<String> _fajrAdhanPaths = [];
  List<String> _regularAdhanPaths = [];
  String? _selectedFajrAdhanPath;
  String? _selectedRegularAdhanPath;
  String? _notificationSoundPath;
  String _prayerCardAnimation = 'slide';
  bool _savingAdhanSettings = false;
  final _audioPlayer = AudioPlayer();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _adhanEnabled = StorageService.getAdhanEnabled();
    _adhanVolume = StorageService.getAdhanVolume();
    _fajrAdhanPaths = StorageService.getFajrAdhanPaths();
    _regularAdhanPaths = StorageService.getRegularAdhanPaths();
    _selectedFajrAdhanPath = StorageService.getSelectedFajrAdhanPath();
    _selectedRegularAdhanPath = StorageService.getSelectedRegularAdhanPath();
    _notificationSoundPath = StorageService.getNotificationSoundPath();
    _prayerCardAnimation = StorageService.getPrayerCardAnimation();
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
    setState(() => _adhanEnabled = enabled);
    try {
      await StorageService.setAdhanEnabled(enabled);
      if (!mounted) return;
      final times = context.read<PrayerProvider>().times;
      if (times != null) {
        await NotificationService.scheduleDailyPrayerNotifications(times);
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to toggle adhan sound: $error\n$stackTrace');
      if (mounted) {
        setState(() => _adhanEnabled = !enabled);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تحديث حالة صوت الأذان')),
        );
      }
    }
  }

  Future<void> _setAdhanVolume(double value) async {
    setState(() => _adhanVolume = value);
  }

  Future<void> _setPrayerCardAnimation(String? value) async {
    if (value == null) return;
    setState(() => _prayerCardAnimation = value);
    await StorageService.setPrayerCardAnimation(value);
  }

  Future<void> _pickAdhanFile({required bool fajr}) async {
    final result = await FilePicker.pickFiles(
      type: FileType.audio,
    );
    final path = result.isEmpty ? null : result.first.path;
    if (path == null || path.isEmpty) return;

    setState(() {
      final paths = fajr ? _fajrAdhanPaths : _regularAdhanPaths;
      if (!paths.contains(path)) paths.add(path);
      if (fajr) {
        _selectedFajrAdhanPath = path;
      } else {
        _selectedRegularAdhanPath = path;
      }
    });
  }

  Future<void> _pickNotificationSound() async {
    final result = await FilePicker.pickFiles(type: FileType.audio);
    final path = result.isEmpty ? null : result.first.path;
    if (path != null && path.isNotEmpty) {
      setState(() => _notificationSoundPath = path);
    }
  }

  void _removeAdhanFile({required bool fajr, required String path}) {
    setState(() {
      final paths = fajr ? _fajrAdhanPaths : _regularAdhanPaths;
      paths.remove(path);
      if (fajr) {
        _selectedFajrAdhanPath = paths.isEmpty
            ? null
            : (_selectedFajrAdhanPath == path
                ? paths.first
                : _selectedFajrAdhanPath);
      } else {
        _selectedRegularAdhanPath = paths.isEmpty
            ? null
            : (_selectedRegularAdhanPath == path
                ? paths.first
                : _selectedRegularAdhanPath);
      }
    });
  }

  Future<void> _saveAdhanSettings() async {
    setState(() => _savingAdhanSettings = true);
    try {
      await StorageService.setAdhanEnabled(_adhanEnabled);
      await StorageService.setAdhanVolume(_adhanVolume);
      await StorageService.setFajrAdhanPaths(_fajrAdhanPaths);
      await StorageService.setRegularAdhanPaths(_regularAdhanPaths);
      await StorageService.setSelectedFajrAdhanPath(_selectedFajrAdhanPath);
      await StorageService.setSelectedRegularAdhanPath(
          _selectedRegularAdhanPath);
      await StorageService.setNotificationSoundPath(_notificationSoundPath);

      if (!mounted) return;
      final times = context.read<PrayerProvider>().times;
      if (times != null) {
        await NotificationService.scheduleDailyPrayerNotifications(times);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_adhanEnabled
              ? 'تم حفظ إعدادات صوت الأذان وتفعيله'
              : 'تم حفظ الإعدادات وإيقاف صوت الأذان'),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to save adhan settings: $error\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'تعذر حفظ إعدادات الأذان. تحقق من صلاحيات الإشعارات وحاول مجددًا.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _savingAdhanSettings = false);
    }
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

  Future<void> _togglePreview(String? path, {required bool fajr}) async {
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.stop();
      if (mounted) setState(() {});
      return;
    }
    await _previewAdhan(path, fajr: fajr);
    if (mounted) setState(() {});
  }

  Future<void> _toggleNotificationPreview() async {
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.stop();
    } else if (_notificationSoundPath != null) {
      await _audioPlayer.play(DeviceFileSource(_notificationSoundPath!));
    }
    if (mounted) setState(() {});
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
    final showPrayerDisplaySection = _matches(
      'شكل حركة التقليب الصلاة الصلوات الأسهم البطاقة',
    );
    final showRightsSection = _matches(
      'حقوق التطبيق صانع البرنامج المطور محمد احمد التواصل البريد واتساب',
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
                      title: Text(_adhanEnabled
                          ? 'صوت الأذان يعمل'
                          : 'صوت الأذان متوقف'),
                      subtitle: const Text(
                          'فعّل أو أوقف الصوت ثم اضغط حفظ الإعدادات'),
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
                    _soundLibrarySection(
                      title: 'أصوات أذان الفجر',
                      paths: _fajrAdhanPaths,
                      selectedPath: _selectedFajrAdhanPath,
                      fajr: true,
                    ),
                    _soundLibrarySection(
                      title: 'أصوات أذان باقي الصلوات',
                      paths: _regularAdhanPaths,
                      selectedPath: _selectedRegularAdhanPath,
                      fajr: false,
                    ),
                    _notificationSoundTile(),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        'يتم استخدام مستوى إشعارات الهاتف عند تشغيل الأذان في الخلفية.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed:
                              _savingAdhanSettings ? null : _saveAdhanSettings,
                          icon: _savingAdhanSettings
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(_savingAdhanSettings
                              ? 'جارٍ الحفظ...'
                              : 'حفظ إعدادات الأذان'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (showPrayerDisplaySection) ...[
            const SizedBox(height: 24),
            _sectionTitle(context, 'عرض بطاقات الصلاة', Icons.view_carousel),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: DropdownButtonFormField<String>(
                  initialValue: _prayerCardAnimation,
                  decoration: const InputDecoration(
                    labelText: 'حركة التقليب بين الصلوات',
                    prefixIcon: Icon(Icons.animation),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'slide',
                      child: Text('انزلاق سلس مع تلاشي'),
                    ),
                    DropdownMenuItem(
                      value: 'fade',
                      child: Text('تلاشي ناعم'),
                    ),
                    DropdownMenuItem(
                      value: 'scale',
                      child: Text('تكبير لطيف'),
                    ),
                    DropdownMenuItem(
                      value: 'rotation',
                      child: Text('دوران خفيف'),
                    ),
                  ],
                  onChanged: _setPrayerCardAnimation,
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

  Widget _soundLibrarySection({
    required String title,
    required List<String> paths,
    required String? selectedPath,
    required bool fajr,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              IconButton(
                tooltip: 'إضافة صوت',
                onPressed: () => _pickAdhanFile(fajr: fajr),
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.deepGreen),
              ),
            ],
          ),
          if (paths.isEmpty)
            Text('لم تتم إضافة أصوات مخصصة',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12))
          else
            ...paths.map(
              (path) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(path.split(RegExp(r'[/\\]')).last,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  tooltip: 'تشغيل / إيقاف',
                  icon: Icon(
                    _audioPlayer.state == PlayerState.playing &&
                            (fajr
                                    ? _selectedFajrAdhanPath
                                    : _selectedRegularAdhanPath) ==
                                path
                        ? Icons.stop_circle_outlined
                        : Icons.play_circle_outline,
                    color: AppColors.gold,
                  ),
                  onPressed: () => _togglePreview(path, fajr: fajr),
                ),
                onTap: () {
                  setState(() {
                    if (fajr) {
                      _selectedFajrAdhanPath = path;
                    } else {
                      _selectedRegularAdhanPath = path;
                    }
                  });
                },
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (selectedPath == path)
                      const Text('مستخدم حاليًا',
                          style: TextStyle(
                              color: AppColors.success, fontSize: 11)),
                    TextButton(
                      onPressed: () => _removeAdhanFile(fajr: fajr, path: path),
                      child: const Text('حذف الصوت'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _notificationSoundTile() {
    final name = _notificationSoundPath == null
        ? 'بدون صوت مخصص'
        : _notificationSoundPath!.split(RegExp(r'[/\\]')).last;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Card(
        margin: EdgeInsets.zero,
        color: AppColors.softGreen.withValues(alpha: .55),
        child: ListTile(
          leading: const Icon(Icons.notifications_active_outlined,
              color: AppColors.deepGreen),
          title: const Text('صوت الإشعارات',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(name,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            tooltip: 'تشغيل / إيقاف أو اختيار صوت',
            onPressed: _notificationSoundPath == null
                ? _pickNotificationSound
                : _toggleNotificationPreview,
            icon: Icon(
              _audioPlayer.state == PlayerState.playing
                  ? Icons.stop_circle_outlined
                  : Icons.audio_file_outlined,
            ),
          ),
          onTap: _pickNotificationSound,
        ),
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
