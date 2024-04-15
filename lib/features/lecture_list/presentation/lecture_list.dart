import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/features/lecture_list/presentation/widgets/lecture_list_card.dart';
import 'package:kana_kit/kana_kit.dart';

class LectureList extends HookWidget {
  const LectureList(this.lectures, {super.key});
  final List<Lecture> lectures;

  void _onSearch(
    ValueNotifier<List<Lecture>> currentLectures,
    String query,
    TextEditingController textEditingController,
  ) {
    if (query.isEmpty) {
      _resetSearch(
        currentLectures,
        textEditingController,
      );
      return;
    }

    _queryForResults(currentLectures, query);
  }

  void _queryForResults(
    ValueNotifier<List<Lecture>> currentLectures,
    String query,
  ) {
    const kanaKit = KanaKit();
    final adjustedQuery = query.toLowerCase().trim();
    final adjustedQueryAsKana = kanaKit.toKana(query.toLowerCase().trim());

    currentLectures.value = lectures
        .where((lecture) =>
            lecture.title.contains(adjustedQuery) ||
            lecture.usages.join("").contains(adjustedQuery) ||
            lecture.title.contains(adjustedQueryAsKana) ||
            lecture.usages.join("").contains(adjustedQueryAsKana))
        .toList();
  }

  void _resetSearch(
    ValueNotifier<List<Lecture>> currentLectures,
    TextEditingController textEditingController,
  ) {
    currentLectures.value = lectures;
    textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentLectures = useState(lectures);
    final searchQueryController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.lectureList,
          style: context.textTheme.headlineLarge,
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 8,
            ),
            child: SearchBar(
              onChanged: (value) => _onSearch(
                currentLectures,
                value,
                searchQueryController,
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
                            currentLectures,
                            searchQueryController,
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
