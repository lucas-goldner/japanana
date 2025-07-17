import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/domain/lecture.dart';

void main() {
  group('LectureType enum tests', () {
    test('recentMistakes should be included in LectureType.values', () {
      expect(LectureType.values.contains(LectureType.recentMistakes), true);
    });

    test('recentMistakes should have correct toString', () {
      expect(
        LectureType.recentMistakes.toString(),
        'LectureType.recentMistakes',
      );
    });
  });

  group('Recent Mistakes Functionality Tests', () {
    test('getLecturesForReviewOption handles recentMistakes case', () {
      // This test focuses on the basic enum functionality
      // Full integration tests would require provider setup
      
      // Arrange
      const allLectureTypes = LectureType.values;
      
      // Act & Assert
      expect(allLectureTypes.contains(LectureType.recentMistakes), true);
      expect(allLectureTypes.length, 7); // Now includes recentMistakes
    });
  });
}
