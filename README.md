# Akylly Lukman

`Akylly Lukman` Flutter-da ýazylan mobil/desktop/web goşundy bolup, Türkmenistanyň dermanlyk ösümlikleri barada maglumat berýär we AI kömekçi bilen söhbet etmäge mümkinçilik berýär.

## Mümkinçilikler

- Dermanlyk ösümlikler katalogy (gözleg + filter)
- Ösümlik goşmak, redaktirlemek, pozmak (CRUD)
- AI söhbet bölümi (`Söhbet`)
- Sözlük bölümi (`Sözlük`)
- Halk lukmançylygy we reseptler bölümi (`Halk`)
- Chat sessiýalaryny ýerli bazada saklamak
- SQLite bazasyna başlangyç maglumatlary seed etmek

## Tehnologiýalar

- Flutter / Dart
- `sqflite`
- `google_generative_ai`
- `http`
- `image_picker`
- `path_provider`

## Proýekt Gurluşy

```text
lib/
  core/
    config/
      api_keys.dart
    services/
      ai_service.dart
      database_service.dart
    theme/
      app_theme.dart
  data/
    models/
      plant.dart
      recipe.dart
      compound.dart
      chat_message.dart
      chat_session.dart
  presentation/
    pages/
      chatbot_page.dart
      plants_page.dart
      plant_detail_page.dart
      plant_form_page.dart
      dictionary_page.dart
      folk_medicine_page.dart
      recipe_detail_page.dart
      main_layout.dart
    widgets/
      plant_image.dart
  main.dart
assets/
  data/
  images/
```

## Gurnama we Işletme

1. Dependensiýalary ýükläň:

```bash
flutter pub get
```

2. API açarlary sazlaň:

Faýl: `lib/core/config/api_keys.dart`

```dart
class ApiKeys {
  static const List<String> geminiKeys = [
    'YOUR_GEMINI_KEY_1',
    'YOUR_GEMINI_KEY_2',
  ];

  static const String openRouterKey = 'YOUR_OPENROUTER_KEY';
}
```

3. Proýekti işlediň:

```bash
flutter run
```

## Derňew we Test

```bash
flutter analyze
flutter test
```

## Howpsuzlyk

- Hakyky API açarlary repozitoriýa goşmaň.
- Açarlar üçin diňe lokal (gitignore edilen) konfigurasiýa ýa-da secret manager ulanyň.
- Eger açar öň push edilen bolsa, derrew rotate ediň.

## Bellik

Goşundynyň esasy dili Türkmen dilidir we AI kömekçi dermanlyk ösümlik temasy bilen çäklendirilendir.
