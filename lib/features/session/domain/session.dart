import 'dart:convert';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';

class Session {
  const Session({
    required this.lectureType,
    required this.options,
    required this.completedLectureIds,
    required this.lastUpdated,
  });

  factory Session.fromMap(Map<String, dynamic> map) => Session(
        lectureType: LectureType.values.firstWhere(
          (e) => e.name == map['lectureType'] as String,
        ),
        options:
            ReviewSetupOptions.fromMap(map['options'] as Map<String, dynamic>),
        completedLectureIds:
            List<String>.from(map['completedLectureIds'] as List),
        lastUpdated: DateTime.parse(map['lastUpdated'] as String),
      );

  factory Session.fromJson(String source) =>
      Session.fromMap(json.decode(source) as Map<String, dynamic>);
  final LectureType lectureType;
  final ReviewSetupOptions options;
  final List<String> completedLectureIds;
  final DateTime lastUpdated;

  Session copyWith({
    LectureType? lectureType,
    ReviewSetupOptions? options,
    List<String>? completedLectureIds,
    DateTime? lastUpdated,
  }) =>
      Session(
        lectureType: lectureType ?? this.lectureType,
        options: options ?? this.options,
        completedLectureIds: completedLectureIds ?? this.completedLectureIds,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );

  Map<String, dynamic> toMap() => {
        'lectureType': lectureType.name,
        'options': options.toMap(),
        'completedLectureIds': completedLectureIds,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  String toJson() => json.encode(toMap());
}
