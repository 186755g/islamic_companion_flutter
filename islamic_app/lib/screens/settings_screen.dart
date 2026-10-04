import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
  double _fontScale = 1.0;
  ThemeMode _themeMode = ThemeMode.light;
  bool _savingAdhanSettings = false;
  AdhanStatus? _adhanStatus;
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
    _fontScale = StorageService.getFontScale();
    _themeMode = StorageService.getThemeModeSetting();
    _refreshAdhanStatus();
    Future<void>.delayed(const Duration(seconds: 2), _refreshAdhanStatus);
  }

  Future<void> _refreshAdhanStatus() async {
    final status = await NotificationService.getAdhanStatus();
    if (mounted) setState(() => _adhanStatus = status);
  }

  void _showAdhanStatus() {
    final status = _adhanStatus;
    if (status == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(status.message),
        backgroundColor:
            status.isHealthy ? AppColors.deepGreen : Colors.red.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
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
      await _refreshAdhanStatus();
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

  Future<void> _setFontScale(double value) async {
    setState(() => _fontScale = value);
    await StorageService.setFontScale(value);
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
      await _refreshAdhanStatus();
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
    final query = _searchController.text.trim().toLowerCase();

    final sections = <_SettingsSectionData>[
      _SettingsSectionData(
        title: 'الصلاة',
        icon: Icons.mosque_rounded,
        rows: [
          _SettingRowData(
            title: 'الموقع',
            searchText: 'الموقع الحالي مكة المحافظة',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('حدد مصدر حساب مواقيت الصلاة', textAlign: TextAlign.right),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: prayer.requestingLocationPermission
                            ? null
                            : _useDeviceLocation,
                        icon: const Icon(Icons.my_location_rounded),
                        label: const Text('موقع الهاتف'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _useMakkahLocation,
                        icon: const Icon(Icons.location_city_rounded),
                        label: const Text('مكة'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _SettingRowData(
            title: 'المحافظة',
            searchText: 'المحافظة مصر القاهرة',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: selected == 'اختر المحافظة' ? null : selected,
                  decoration: const InputDecoration(
                    labelText: 'المحافظة',
                    prefixIcon: Icon(Icons.location_city_rounded),
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
                    (item) => ListTile(
                      dense: true,
                      title: Text(item.name, textAlign: TextAlign.right),
                      leading: const Icon(Icons.location_on_outlined),
                      onTap: () => _selectGovernorate(item),
                    ),
                  ),
                ],
              ],
            ),
          ),
          _SettingRowData(
            title: 'تنبيهات الصلاة',
            searchText: 'تنبيهات الصلاة الإشعارات الأذان',
            content: SwitchListTile.adaptive(
              value: _adhanEnabled,
              onChanged: _setAdhanEnabled,
              title: const Text('تنبيهات الصلاة'),
              subtitle: const Text('تشغيل أو إيقاف صوت الأذان والتذكير التلقائي.'),
            ),
          ),
        ],
      ),
      _SettingsSectionData(
        title: 'الأذان',
        icon: Icons.notifications_active_rounded,
        rows: [
          _SettingRowData(
            title: 'مستوى الصوت',
            searchText: 'الأذان مستوى الصوت',
            content: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _showAdhanStatus,
                      icon: const Icon(Icons.info_outline_rounded),
                      label: const Text('حالة الأذان'),
                    ),
                    Text('${(_adhanVolume * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: _adhanVolume,
                  min: 0,
                  max: 1,
                  divisions: 20,
                  label: '${(_adhanVolume * 100).round()}%',
                  onChanged: _setAdhanVolume,
                ),
              ],
            ),
          ),
          _SettingRowData(
            title: 'حفظ الإعدادات',
            searchText: 'حفظ إعدادات الأذان',
            content: FilledButton.icon(
              onPressed: _savingAdhanSettings ? null : _saveAdhanSettings,
              icon: const Icon(Icons.save_alt_rounded),
              label: Text(_savingAdhanSettings ? 'جارٍ الحفظ...' : 'حفظ إعدادات الأذان'),
            ),
          ),
          _SettingRowData(
            title: 'أذان الفجر',
            searchText: 'أذان الفجر صوت',
            content: _soundLibrarySection(
              title: 'أذان الفجر',
              paths: _fajrAdhanPaths,
              selectedPath: _selectedFajrAdhanPath,
              fajr: true,
            ),
          ),
          _SettingRowData(
            title: 'أذان الصلوات',
            searchText: 'أذان الصلوات صوت',
            content: _soundLibrarySection(
              title: 'أذان الصلوات',
              paths: _regularAdhanPaths,
              selectedPath: _selectedRegularAdhanPath,
              fajr: false,
            ),
          ),
          _SettingRowData(
            title: 'صوت الإشعارات',
            searchText: 'صوت الإشعارات',
            content: _notificationSoundTile(),
          ),
        ],
      ),
      _SettingsSectionData(
        title: 'المظهر',
        icon: Icons.palette_rounded,
        rows: [
          _SettingRowData(
            title: 'النمط',
            searchText: 'المظهر فاتح داكن حسب النظام',
            content: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: _themeMode,
                  title: const Text('فاتح'),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _themeMode = value);
                    StorageService.setThemeModeSetting(value);
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: _themeMode,
                  title: const Text('داكن'),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _themeMode = value);
                    StorageService.setThemeModeSetting(value);
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: _themeMode,
                  title: const Text('حسب النظام'),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _themeMode = value);
                    StorageService.setThemeModeSetting(value);
                  },
                ),
              ],
            ),
          ),
          _SettingRowData(
            title: 'حجم الخط',
            searchText: 'حجم الخط القراءة',
            content: Column(
              children: [
                Slider(
                  value: _fontScale,
                  min: 0.85,
                  max: 1.35,
                  divisions: 10,
                  label: '${(_fontScale * 100).round()}%',
                  onChanged: _setFontScale,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${(_fontScale * 100).round()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          _SettingRowData(
            title: 'حركة بطاقات الصلاة',
            searchText: 'حركة بطاقات الصلاة انزلاق تلاشي',
            content: DropdownButtonFormField<String>(
              value: _prayerCardAnimation,
              decoration: const InputDecoration(
                labelText: 'حركة بطاقات الصلاة',
                prefixIcon: Icon(Icons.animation_rounded),
              ),
              items: const [
                DropdownMenuItem(value: 'slide', child: Text('انزلاق')),
                DropdownMenuItem(value: 'fade', child: Text('تلاشي')),
                DropdownMenuItem(value: 'scale', child: Text('تكبير')),
                DropdownMenuItem(value: 'rotation', child: Text('دوران')),
              ],
              onChanged: _setPrayerCardAnimation,
            ),
          ),
        ],
      ),
      _SettingsSectionData(
        title: 'القرآن والأذكار',
        icon: Icons.menu_book_rounded,
        rows: [
          _SettingRowData(
            title: 'إعدادات القراءة',
            searchText: 'القرآن قراءة النص',
            content: ListTile(
              title: const Text('إعدادات القراءة'),
              subtitle: const Text('حجم الخط وتباعد النص يتم ضبطهما من المظهر العام.'),
              leading: const Icon(Icons.chrome_reader_mode_rounded),
            ),
          ),
          _SettingRowData(
            title: 'إعدادات الأذكار',
            searchText: 'الأذكار حفظ تقدم الأذكار',
            content: ListTile(
              title: const Text('إعدادات الأذكار'),
              subtitle: const Text('يتم حفظ التقدم تلقائيًا داخل التطبيق عند كل تغيير.'),
              leading: const Icon(Icons.auto_awesome_rounded),
            ),
          ),
        ],
      ),
      _SettingsSectionData(
        title: 'التطبيق',
        icon: Icons.info_outline_rounded,
        rows: [
          _SettingRowData(
            title: 'الخصوصية',
            searchText: 'الخصوصية بيانات محلية',
            content: ListTile(
              title: const Text('الخصوصية'),
              subtitle: const Text('يتم حفظ البيانات محليًا داخل التطبيق دون مشاركة خارجية.'),
              leading: const Icon(Icons.privacy_tip_outlined),
            ),
          ),
          _SettingRowData(
            title: 'عن التطبيق',
            searchText: 'عن التطبيق وصف',
            content: ListTile(
              title: const Text('عن التطبيق'),
              subtitle: const Text('رفيق المسلم — تطبيق إسلامي لمتابعة الصلاة، الأذكار، والقرآن.'),
              leading: const Icon(Icons.info_rounded),
            ),
          ),
          _SettingRowData(
            title: 'التواصل',
            searchText: 'التواصل البريد واتساب',
            content: ListTile(
              title: const Text('التواصل'),
              subtitle: const Text('mohamedd0103319@gmail.com'),
              leading: const Icon(Icons.email_outlined),
              onTap: () => _openContact(
                Uri(
                  scheme: 'mailto',
                  path: 'mohamedd0103319@gmail.com',
                  queryParameters: {'subject': 'التواصل من تطبيق رفيق المسلم'},
                ),
                'تعذر فتح تطبيق البريد الإلكتروني',
              ),
            ),
          ),
          _SettingRowData(
            title: 'إصدار التطبيق',
            searchText: 'إصدار التطبيق نسخة',
            content: const ListTile(
              title: Text('إصدار التطبيق'),
              subtitle: Text('1.0.0+1'),
              leading: Icon(Icons.app_registration_rounded),
            ),
          ),
        ],
      ),
    ];

    final visibleSections = sections.where((section) {
      if (query.isEmpty) return true;
      final titleMatch = section.title.toLowerCase().contains(query);
      final rowMatch = section.rows.any(
        (row) => row.searchText.toLowerCase().contains(query),
      );
      return titleMatch || rowMatch;
    }).toList();

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
              hintText: 'ابحث في الإعدادات...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: _clearSearch,
                    ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          if (visibleSections.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('لا توجد إعدادات مطابقة للبحث'),
              ),
            )
          else
            ...visibleSections.map(
              (section) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.deepGreen.withValues(alpha: 0.15),
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    title: Row(
                      children: [
                        Icon(section.icon, color: AppColors.deepGreen),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            section.title,
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    children: section.rows
                        .map(
                          (row) => Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(bottom: 8),
                            child: row.content,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _soundLibrarySection({
    required String title,
    required List<String> paths,
    required String? selectedPath,
    required bool fajr,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softGreen.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(14),
      ),
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
                onPressed: () => _pickAdhanFile(fajr: fajr),
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.deepGreen),
              ),
            ],
          ),
          if (paths.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'لم تتم إضافة أصوات مخصصة',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            )
          else
            ...paths.map((path) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    path.split(RegExp(r'[/\\]')).last,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    onPressed: () => _togglePreview(path, fajr: fajr),
                    icon: Icon(
                      _audioPlayer.state == PlayerState.playing &&
                              (fajr ? _selectedFajrAdhanPath : _selectedRegularAdhanPath) ==
                                  path
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline_rounded,
                      color: AppColors.gold,
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (selectedPath == path)
                        const Text('مستخدم حاليًا',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                            )),
                      TextButton(
                        onPressed: () => _removeAdhanFile(fajr: fajr, path: path),
                        child: const Text('حذف'),
                      ),
                    ],
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
                )),
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
}

class _SettingsSectionData {
  final String title;
  final IconData icon;
  final List<_SettingRowData> rows;

  const _SettingsSectionData({
    required this.title,
    required this.icon,
    required this.rows,
  });
}

class _SettingRowData {
  final String title;
  final String searchText;
  final Widget content;

  const _SettingRowData({
    required this.title,
    required this.searchText,
    required this.content,
  });
}
