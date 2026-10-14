import 'dart:convert';

class Mistake {
  const Mistake({
    required this.lectureId,
    required this.mistakeCount,
    required this.lastMistakeDate,
  });

  factory Mistake.fromMap(Map<String, dynamic> map) => Mistake(
        lectureId: map['lectureId'] as String,
        mistakeCount: map['mistakeCount'] as int,
        lastMistakeDate: DateTime.parse(map['lastMistakeDate'] as String),
      );

  factory Mistake.fromJson(String source) =>
      Mistake.fromMap(json.decode(source) as Map<String, dynamic>);
  final String lectureId;
  final int mistakeCount;
  final DateTime lastMistakeDate;

  Mistake copyWith({
    String? lectureId,
    int? mistakeCount,
    DateTime? lastMistakeDate,
  }) =>
      Mistake(
        lectureId: lectureId ?? this.lectureId,
        mistakeCount: mistakeCount ?? this.mistakeCount,
        lastMistakeDate: lastMistakeDate ?? this.lastMistakeDate,
      );

  Map<String, dynamic> toMap() => {
        'lectureId': lectureId,
        'mistakeCount': mistakeCount,
        'lastMistakeDate': lastMistakeDate.toIso8601String(),
      };

  String toJson() => json.encode(toMap());
}
