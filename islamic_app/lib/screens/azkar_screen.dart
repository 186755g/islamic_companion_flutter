import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/zikr_model.dart';
import '../providers/azkar_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/islamic_ornament.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});
  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const IslamicOrnamentDivider(height: 20),
        Container(
          color: AppColors.deepGreen,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.ivory,
            dividerColor: Colors.transparent,
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
            unselectedLabelColor: AppColors.lightGold.withValues(alpha: 0.7),
            tabs: const [
              Tab(text: 'الصباح'),
              Tab(text: 'المساء'),
              Tab(text: 'الصلاة'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _AzkarList(category: AzkarCategory.morning),
              _AzkarList(category: AzkarCategory.evening),
              _AzkarList(category: AzkarCategory.prayer),
            ],
          ),
        ),
      ],
    );
  }
}

class _AzkarList extends StatefulWidget {
  final AzkarCategory category;
  const _AzkarList({required this.category});

  @override
  State<_AzkarList> createState() => _AzkarListState();
}

class _AzkarListState extends State<_AzkarList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goToNextItem(int currentIndex, List<Zikr> list) {
    if (currentIndex >= list.length - 1) return;
    final target = currentIndex + 1;
    final offset = math.min(
      _scrollController.offset + 220,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      offset + (target * 80.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AzkarProvider>();
    final list = prov.byCategory(widget.category);
    final progress = prov.progressFor(widget.category);

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'التقدم',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.deepGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation(AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => prov.resetCategory(widget.category),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('إعادة التعيين'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.deepGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: list.length,
              itemBuilder: (context, index) => _ZikrCard(
                zikr: list[index],
                index: index,
                total: list.length,
                onNext: () => _goToNextItem(index, list),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZikrCard extends StatelessWidget {
  final Zikr zikr;
  final int index;
  final int total;
  final VoidCallback onNext;

  const _ZikrCard({
    required this.zikr,
    required this.index,
    required this.total,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.read<AzkarProvider>();
    final remaining = math.max(zikr.targetCount - zikr.currentCount, 0);
    final completed = zikr.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: AppColors.divider, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${index + 1} / $total',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'ذكر',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.deepGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              zikr.arabicText,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 28,
                height: 1.9,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                fontFamilyFallback: ['Noto Sans Arabic', 'Arial', 'sans-serif'],
              ),
            ),
            if (zikr.source.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                zikr.source,
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: index < total - 1 ? onNext : null,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('التالي'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.deepGreen,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _CounterBadge(
                  zikr: zikr,
                  remaining: remaining,
                  completed: completed,
                  onTap: completed ? null : () => prov.tapZikr(zikr),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => prov.resetZikr(zikr),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('إعادة التعيين'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterBadge extends StatelessWidget {
  final Zikr zikr;
  final int remaining;
  final bool completed;
  final VoidCallback? onTap;

  const _CounterBadge({
    required this.zikr,
    required this.remaining,
    required this.completed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: completed
          ? 'تم إكمال الذكر'
          : 'المتبقي $remaining من ${zikr.targetCount}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: completed
                ? AppColors.success.withValues(alpha: 0.12)
                : AppColors.gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: completed ? AppColors.success : AppColors.gold,
              width: 1.5,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              child: child,
            ),
            child: completed
                ? const Icon(
                    Icons.check_rounded,
                    key: ValueKey('completed'),
                    color: AppColors.success,
                    size: 36,
                  )
                : Column(
                    key: ValueKey(remaining),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$remaining',
                        style: const TextStyle(
                          color: AppColors.deepGreen,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          fontFamilyFallback: ['Noto Sans Arabic', 'Arial', 'sans-serif'],
                        ),
                      ),
                      const Text(
                        'متبقي',
                        style: TextStyle(
                          color: AppColors.deepGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
