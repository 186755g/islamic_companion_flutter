import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story_model.dart';
import '../providers/stories_provider.dart';
import '../providers/streak_provider.dart';
import '../theme/app_theme.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<StoriesProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('قصص الأنبياء والصحابة')),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _CategoryChip(label: 'الكل', selected: prov.activeCategory == null, onTap: () => prov.setCategory(null)),
                ...StoryCategory.values.map((c) => _CategoryChip(
                      label: c.arabicName,
                      selected: prov.activeCategory == c,
                      onTap: () => prov.setCategory(c),
                    )),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: prov.filtered.length,
              itemBuilder: (context, i) {
                final story = prov.filtered[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(story.title, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(story.summary, textAlign: TextAlign.right, style: TextStyle(color: Colors.grey.shade600)),
                    ),
                    trailing: const Icon(Icons.chevron_left, color: AppColors.gold),
                    onTap: () {
                      context.read<StreakProvider>().registerActivity();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => StoryDetailScreen(story: story)));
                    },
                  ),
                );
              },
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

class StoryDetailScreen extends StatelessWidget {
  final StoryModel story;
  const StoryDetailScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(story.title)),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          ...story.paragraphs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(p, textAlign: TextAlign.right, style: const TextStyle(fontSize: 16, height: 2.0)),
              )),
          if (story.lessonLearned != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.lightGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('العبرة والدرس', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepGreen)),
                  const SizedBox(height: 6),
                  Text(story.lessonLearned!, textAlign: TextAlign.right),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text('المصادر: ${story.sources.join('، ')}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }
}
