import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/zikr_model.dart';
import '../providers/azkar_provider.dart';
import '../theme/app_theme.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});
  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.deepGreen,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.ivory,
            unselectedLabelColor: AppColors.lightGold.withValues(alpha: 0.6),
            tabs: const [Tab(text: 'أذكار الصباح'), Tab(text: 'أذكار المساء')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _AzkarList(category: AzkarCategory.morning),
              _AzkarList(category: AzkarCategory.evening),
            ],
          ),
        ),
      ],
    );
  }
}

class _AzkarList extends StatelessWidget {
  final AzkarCategory category;
  const _AzkarList({required this.category});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AzkarProvider>();
    final list = prov.byCategory(category);
    final progress = prov.progressFor(category);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.lightGold.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation(AppColors.success),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: () => prov.resetCategory(category), child: const Text('إعادة تعيين')),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: list.length,
            itemBuilder: (context, i) => _ZikrCard(zikr: list[i]),
          ),
        ),
      ],
    );
  }
}

class _ZikrCard extends StatelessWidget {
  final Zikr zikr;
  const _ZikrCard({required this.zikr});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<AzkarProvider>();
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => prov.tapZikr(zikr),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CounterBadge(zikr: zikr),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(zikr.arabicText, textAlign: TextAlign.right, style: const TextStyle(fontSize: 17, height: 1.8)),
                    const SizedBox(height: 6),
                    Text(zikr.source, textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterBadge extends StatelessWidget {
  final Zikr zikr;
  const _CounterBadge({required this.zikr});

  @override
  Widget build(BuildContext context) {
    if (zikr.isCompleted) {
      return const CircleAvatar(radius: 22, backgroundColor: AppColors.success, child: Icon(Icons.check, color: Colors.white));
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.gold.withValues(alpha: 0.15),
      child: Text('${zikr.currentCount}/${zikr.targetCount}',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.deepGreen)),
    );
  }
}
