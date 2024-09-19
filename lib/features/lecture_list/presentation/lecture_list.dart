import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/features/lecture_list/presentation/widgets/lecture_list_card.dart';
import 'package:kana_kit/kana_kit.dart';

class LectureList extends HookConsumerWidget {
  const LectureList({super.key});

  void _onSearch({
    required List<Lecture> lectures,
    required ValueNotifier<List<Lecture>> currentLectures,
    required String query,
    required TextEditingController textEditingController,
  }) {
    if (query.isEmpty) {
      _resetSearch(
        lectures: lectures,
        currentLectures: currentLectures,
        textEditingController: textEditingController,
      );
      return;
    }

    _queryForResults(
      currentLectures: currentLectures,
      query: query,
      lectures: lectures,
    );
  }

  void _queryForResults({
    required List<Lecture> lectures,
    required String query,
    required ValueNotifier<List<Lecture>> currentLectures,
  }) {
    const kanaKit = KanaKit();
    final adjustedQuery = query.toLowerCase().trim();
    final adjustedQueryAsKana = kanaKit.toKana(query.toLowerCase().trim());

    currentLectures.value = lectures
        .where(
          (lecture) =>
              lecture.title.contains(adjustedQuery) ||
              lecture.usages.join().contains(adjustedQuery) ||
              lecture.title.contains(adjustedQueryAsKana) ||
              lecture.usages.join().contains(adjustedQueryAsKana),
        )
        .toList();
  }

  void _resetSearch({
    required List<Lecture> lectures,
    required ValueNotifier<List<Lecture>> currentLectures,
    required TextEditingController textEditingController,
  }) {
    currentLectures.value = lectures;
    textEditingController.clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSavedLectures = useState(false);
    final allLectures = ref.read(lectureProvider);
    final savedLectures = ref
        .read(lectureProvider)
        .where((element) => element.types.contains(LectureType.remember))
        .toList();
    final lectures = showSavedLectures.value ? savedLectures : allLectures;
    final currentAllLectures = useState(allLectures);
    final currentSavedLectures = useState(savedLectures);
    final currentLectures =
        showSavedLectures.value ? currentSavedLectures : currentAllLectures;
    final searchQueryController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.lectureList,
          style: context.textTheme.headlineLarge,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              color: context.colorScheme.secondaryContainer,
            ),
            onPressed: () => showSavedLectures.value = !showSavedLectures.value,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 8,
            ),
            child: SearchBar(
              onChanged: (value) => _onSearch(
                lectures: lectures,
                currentLectures: currentLectures,
                query: value,
                textEditingController: searchQueryController,
              ),
              controller: searchQueryController,
              trailing: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: context.colorScheme.secondaryContainer,
                  ),
                  onPressed: searchQueryController.text.isEmpty
                      ? null
                      : () => _resetSearch(
                            lectures: lectures,
                            currentLectures: currentLectures,
                            textEditingController: searchQueryController,
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListWheelScrollView(
        itemExtent: 150,
        squeeze: 0.9,
        diameterRatio: 3,
        children: currentLectures.value.indexed
            .map(
              (lectureWithIndex) => LectureListCard(
                lectureIndex: lectures.indexOf(lectureWithIndex.$2) + 1,
                lecture: lectureWithIndex.$2,
              ),
            )
            .toList(),
      ),
    );
  }
}
