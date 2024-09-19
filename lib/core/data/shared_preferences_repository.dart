import 'package:japanana/core/domain/shared_preferences_key.dart';

abstract class SharedPreferencesRepository {
  void writeListOfStringToSharedPreferences(
    SharedPreferencesKey key,
    List<String> value,
  );
  List<String> getListStringOfSharedPreferences(
    SharedPreferencesKey key,
  );
}
