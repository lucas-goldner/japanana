import 'package:flutter/foundation.dart';
import 'package:hikou/features/review_selection/domain/review_sections.dart';

typedef K = Keys;

class Keys {
  const Keys();

  static Key getReviewSelectionItemTitleForReviewOption(
          ReviewSections option) =>
      Key("review_select_item_title_${option.name}");
  static Key getInReviewAppTitleForReviewOption(ReviewSections option) =>
      Key("in_review_app_title_${option.name}");
  static const reviewSetupAppTitle = Key('review_setup_app_title');
  static const startReviewButton = Key('review_setup_start_review_button');
  static const reviewSelectionAppTitle = Key('review_selection_app_title');
  static const inReviewCardStack = Key('in_review_card_stack');
  static const lectureCard = Key('in_review_lecture_card');
  static const lectureCardTitle = Key('in_review_lecture_card_title');
  static Key getReviewLectureCardExpandedContent(int taps) =>
      Key('in_review_lecture_card_expanded_content_${taps}');
  static const progressIndicator = Key('in_review_progress_indicator');
  static const progressIndicatorLabel =
      Key('in_review_progress_indicator_label');
}
