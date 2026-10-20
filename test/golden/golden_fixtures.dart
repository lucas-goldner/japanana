import 'dart:convert';

import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/domain/mistake.dart';
import 'package:japanana/core/domain/shared_preferences_key.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';
import 'package:japanana/features/session/domain/session.dart';

final goldenLectures = [
  Lecture(
    id: 'n4-1',
    title: 'んです',
    usages: ['Asking the listener to confirm or giving a reason'],
    examples: ['雨が降っているんですか', 'バスが来なかったんです'],
    translations: ['Is it raining?', "...Because the bus didn't come"],
    extras: ['のです in writing.'],
    types: [LectureType.n4],
  ),
  Lecture(
    id: 'n4-2',
    title: '-ていただけませんか',
    usages: ['More polite than てください to ask for something'],
    examples: ['良い先生を紹介していただけませんか'],
    translations: [
      'Would you be so kind as to introduce me to a good teacher?',
    ],
    types: [LectureType.n4],
  ),
  Lecture(
    id: 'n4-3',
    title: '-たら良いですか',
    usages: ['Ask for advice or instructions'],
    examples: ['どこでカメラを買ったら良いですか'],
    translations: ['Where would be a good place to buy a camera?'],
    types: [LectureType.n4],
  ),
  Lecture(
    id: 'n3-1',
    title: 'わけがない',
    usages: ['Something is impossible or out of the question'],
    examples: ['彼が嘘をつくわけがない'],
    translations: ['There is no way he would lie'],
    types: [LectureType.n3],
  ),
  Lecture(
    id: 'n3-2',
    title: 'ようにする',
    usages: ['Making an effort to do something regularly'],
    examples: ['毎日野菜を食べるようにしている'],
    translations: ['I try to eat vegetables every day'],
    types: [LectureType.n3, LectureType.conversational],
  ),
  Lecture(
    id: 'n2-1',
    title: 'にもかかわらず',
    usages: ['Despite, in spite of'],
    examples: ['雨にもかかわらず、試合は行われた'],
    translations: ['Despite the rain, the match was held'],
    types: [LectureType.n2, LectureType.writing],
  ),
  Lecture(
    id: 'n2-2',
    title: 'に際して',
    usages: ['On the occasion of, when doing something formal'],
    examples: ['入学に際して、書類を提出してください'],
    translations: ['Please submit the documents upon enrollment'],
    types: [LectureType.n2, LectureType.writing],
  ),
];

/// Preferences that make the "remember" and "recent mistakes" books appear
/// and fill the statistics screen.
Map<String, Object> goldenMistakePreferences() {
  final now = DateTime.now();
  return {
    SharedPreferencesKey.needToRememberLectures.value: ['n3-1'],
    'mistakes': [
      Mistake(
        lectureId: 'n4-2',
        mistakeCount: 1,
        lastMistakeDate: now.subtract(const Duration(hours: 3)),
      ).toJson(),
      Mistake(
        lectureId: 'n2-1',
        mistakeCount: 3,
        lastMistakeDate: now.subtract(const Duration(days: 1, hours: 1)),
      ).toJson(),
      Mistake(
        lectureId: 'n4-1',
        mistakeCount: 7,
        lastMistakeDate: now.subtract(const Duration(days: 4, hours: 1)),
      ).toJson(),
    ],
  };
}

Map<String, Object> goldenSessionPreferences(LectureType type) => {
      SharedPreferencesKey.sessionKey(type).value: jsonEncode(
        Session(
          lectureType: type,
          options: const ReviewSetupOptions(
            randomize: true,
            repeatOnFalseCard: false,
          ),
          completedLectureIds: ['n4-1'],
          lastUpdated: DateTime(2025),
        ).toMap(),
      ),
    };
