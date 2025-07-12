import 'dart:convert';

class Mistake {
  final String lectureId;
  final int mistakeCount;
  final DateTime lastMistakeDate;

  const Mistake({
    required this.lectureId,
    required this.mistakeCount,
    required this.lastMistakeDate,
  });

  Mistake copyWith({
    String? lectureId,
    int? mistakeCount,
    DateTime? lastMistakeDate,
  }) {
    return Mistake(
      lectureId: lectureId ?? this.lectureId,
      mistakeCount: mistakeCount ?? this.mistakeCount,
      lastMistakeDate: lastMistakeDate ?? this.lastMistakeDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lectureId': lectureId,
      'mistakeCount': mistakeCount,
      'lastMistakeDate': lastMistakeDate.toIso8601String(),
    };
  }

  factory Mistake.fromMap(Map<String, dynamic> map) {
    return Mistake(
      lectureId: map['lectureId'] as String,
      mistakeCount: map['mistakeCount'] as int,
      lastMistakeDate: DateTime.parse(map['lastMistakeDate'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory Mistake.fromJson(String source) =>
      Mistake.fromMap(json.decode(source) as Map<String, dynamic>);
}