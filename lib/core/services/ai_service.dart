import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static const List<String> _apiKeys = [
    'AIzaSyB-SiU9mnw_xIIgyTjw8djG3if1n8PBPck',
    'AIzaSyB4ECr5wMeu9ZPnHl-na3hUKqd6jAVbjgk',
    'AIzaSyAkV9_N0DNGjq0i6xvrtnIvM0gLN3V1j-4',
    'AIzaSyDjJQCx3Db_fRDI4HLgEqQquoqWR_STP28',
  ];
  static const String _modelName = 'gemini-3.1-flash-lite-preview';

  int _currentKeyIndex = 0;
  late GenerativeModel _model;
  late ChatSession _chat;

  AiService() {
    _initializeModel();
    _chat = _model.startChat();
  }

  void _initializeModel() {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: _apiKeys[_currentKeyIndex],
      systemInstruction: Content.system(
        'Sen Türkmenistanyň dermanlyk ösümlikleri boýunça hünärmen kömekçisi. '
        'Seniň esasy wezipäň Türkmenistanyň dermanlyk ösümlikleri, olaryň peýdalary, '
        'taýýarlanyş usullary we bu ugurda ýazylan kitaplar barada maglumat bermekdir. '
        '\n\nŞertler:'
        '\n1. Diňe dermanlyk ösümlikler we olar bilen baglanyşykly (lukmançylyk, kitaplar, taryh) soraglara jogap ber.'
        '\n2. Eger ulanyjy "Sen kim?" ýa-da "Seni kim döretdi?" ýaly soraglar berilse, hökman: '
        '"Höwesjeňler tarapyndan dermanlyk ösümlikleri boýunça jogap bermek üçin döredildim" diýip jogap ber.'
        '\n3. Dermanlyk ösümliklere degişli bolmadyk (mysal üçin: howa ýagdaýy, nahar reseptleri, syýasat, sport we ş.m.) '
        'soraglara sypaýyçylyk bilen jogap bermekden ýüz öwür we diňe ösümlikler barada kömek edip biljekdigiňi aýt.',
      ),
    );
  }

  Future<String> sendMessage(String message) async {
    try {
      // Rotate key for each message
      _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;

      // Save history and re-init model with new key
      final history = _chat.history.toList();
      _initializeModel();
      _chat = _model.startChat(history: history);

      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'Jogap alyp bolmady.';
    } catch (e) {
      return 'Ýalňyşlyk ýüze çykdy: $e';
    }
  }
}
