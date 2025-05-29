// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get helloWorld => 'Hallo Welt!';

  @override
  String get appTitle => 'Japanana';

  @override
  String get n2Grammar => 'N2 Grammatik';

  @override
  String get n3Grammar => 'N3 Grammatik';

  @override
  String get n4Grammar => 'N4 Grammatik';

  @override
  String get conversational => 'Grammatik für Konversation';

  @override
  String get writing => 'Grammatik wichtig für Texte schreiben';

  @override
  String get randomizeCards => 'Zufällige Karten';

  @override
  String get repeatFailedCards => 'Karten bei Fehler wiederholen';

  @override
  String get startReview => 'Lerneinheit starten';

  @override
  String get usages => 'Brauchweise';

  @override
  String get examples => 'Beispiele';

  @override
  String get translations => 'Übersetzungen';

  @override
  String get extras => 'Extras';

  @override
  String congratsOnFinising(String review) {
    return 'Klasse du hast $review beendet!';
  }

  @override
  String get startNextReview => 'Nächste Lerneinheit starten';

  @override
  String get lectureList => 'Lerneinheitenliste';

  @override
  String get next => 'Nächstes';

  @override
  String get richtig => 'Richtig';

  @override
  String get falsch => 'Falsch';

  @override
  String get remember => 'Speichern';

  @override
  String get rememberedSection => 'Gespeicherte Grammatik';

  @override
  String get forget => 'Vergessen';
}
