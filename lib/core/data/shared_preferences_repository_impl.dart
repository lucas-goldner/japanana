import 'package:japanana/core/data/shared_preferences_repository.dart';
import 'package:japanana/core/domain/shared_preferences_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesRepositoryImpl implements SharedPreferencesRepository {
  const SharedPreferencesRepositoryImpl(this.preferences);
  final SharedPreferences preferences;

  @override
  List<String> getListStringOfSharedPreferences(
    SharedPreferencesKey key,
  ) =>
      preferences
          .getStringList(SharedPreferencesKey.needToRememberLectures.name) ??
      [];

  @override
  void writeListOfStringToSharedPreferences(
    SharedPreferencesKey key,
    List<String> value,
  ) =>
      preferences.setStringList(
        SharedPreferencesKey.needToRememberLectures.name,
        Set<String>.from(value).toList(),
      );
}
