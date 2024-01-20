import 'package:flutter/foundation.dart';
import 'package:hikou/features/review_setup/domain/review_options.dart';

typedef K = Keys;

class Keys {
  const Keys();

  static Key getReviewSelectItemTitleForReviewOption(ReviewOptions option) =>
      Key("review_select_item_title_${option.name}");
  static Key getInReviewAppTitleForReviewOption(ReviewOptions option) =>
      Key("in_review_app_title_${option.name}");
  static const reviewSetupAppTitle = Key('review_setup_app_title');
}
