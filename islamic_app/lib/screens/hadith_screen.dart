import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hadith_model.dart';
import '../providers/hadith_provider.dart';
import '../providers/streak_provider.dart';
import '../theme/app_theme.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<HadithProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('أحاديث المعاملات والأخلاق')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث في الأحاديث...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
              ),
              onChanged: prov.setQuery,
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _CategoryChip(label: 'الكل', selected: prov.activeCategory == null, onTap: () => prov.setCategory(null)),
                ...HadithCategory.values.map((c) => _CategoryChip(
                      label: c.arabicName,
                      selected: prov.activeCategory == c,
                      onTap: () => prov.setCategory(c),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: prov.filtered.length,
              itemBuilder: (context, i) => _HadithCard(hadith: prov.filtered[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.deepGreen,
        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textDark, fontSize: 12),
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  final HadithModel hadith;
  const _HadithCard({required this.hadith});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.read<StreakProvider>().registerActivity(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.lightGold.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(hadith.category.arabicName, style: const TextStyle(fontSize: 11)),
              ),
              const SizedBox(height: 8),
              Text(hadith.text, textAlign: TextAlign.right, style: const TextStyle(fontSize: 16, height: 1.8)),
              const SizedBox(height: 8),
              Text('${hadith.source} — ${hadith.narrator}',
                  textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              if (hadith.briefExplanation != null) ...[
                const Divider(height: 16),
                Text(hadith.briefExplanation!,
                    textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
