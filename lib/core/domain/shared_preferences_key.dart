import 'package:japanana/core/domain/lecture.dart';

enum SharedPreferencesKey {
  needToRememberLectures,
  sessionWriting('session_writing'),
  sessionConversational('session_conversational'),
  sessionN2('session_n2'),
  sessionN3('session_n3'),
  sessionN4('session_n4'),
  sessionRemember('session_remember');

  const SharedPreferencesKey([this.key]);

  final String? key;

  static SharedPreferencesKey sessionKey(LectureType lectureType) {
    switch (lectureType) {
      case LectureType.writing:
        return SharedPreferencesKey.sessionWriting;
      case LectureType.conversational:
        return SharedPreferencesKey.sessionConversational;
      case LectureType.n2:
        return SharedPreferencesKey.sessionN2;
      case LectureType.n3:
        return SharedPreferencesKey.sessionN3;
      case LectureType.n4:
        return SharedPreferencesKey.sessionN4;
      case LectureType.remember:
        return SharedPreferencesKey.sessionRemember;
    }
  }

  String get value => key ?? name;
}
