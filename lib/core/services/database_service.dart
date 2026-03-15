import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/models/plant.dart';
import '../../data/models/compound.dart';
import '../../data/models/chat_message.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('plant_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE plants (
  id $idType,
  name $textType,
  scientificName $textType,
  description $textType,
  medicalUses $textType,
  preparationMethod $textType,
  relatedDiseases $textType,
  usedPart $textType,
  chemicalComposition $textType,
  contraindications $textType,
  imageUrl $textType
)
''');

    await db.execute('''
CREATE TABLE compounds (
  id $idType,
  name $textType,
  description $textType,
  sourcePlants $textType
)
''');

    await db.execute('''
CREATE TABLE chat_messages (
  id $idType,
  text $textType,
  isUser $boolType,
  timestamp $textType
)
''');

    await _seedData(db);
    await _seedCompounds(db);
  }

  Future<void> _seedData(Database db) async {
    final plants = [
      Plant(
        name: 'Balanat',
        scientificName: 'Glycyrrhiza glabra',
        description: 'Süýji kök (buyan) köpýyllyk ösümlikdir. Bu ösümlik Türkmenistanyň meýdanlarynda giňden ýaýrandyr.',
        medicalUses: 'Sowuklama, üsgülewük, aşgazan keselleri.',
        preparationMethod: 'Köküni gaýnadyp peýdalanmaly.',
        relatedDiseases: 'Sowuklama, aşgazan, bronhit',
        usedPart: 'Kök',
        chemicalComposition: 'Glisirrizin, flavonoidler, steroidler',
        contraindications: 'Gan basyşy ýokary adamlar ulanmaly däl.',
        imageUrl: 'https://images.unsplash.com/photo-1515255384510-333036986612',
      ),
      Plant(
        name: 'Adygeý',
        scientificName: 'Hypericum perforatum',
        description: 'Sary çopantelpek ösümligi. Nerw ulgamyny rahatlandyrmak üçin ulanylýar.',
        medicalUses: 'Nerw ulgamy, aşgazan, ýara bitirmek.',
        preparationMethod: 'Çay ýaly demläp içmeli.',
        relatedDiseases: 'Nerw, depressiýa, gastrit',
        usedPart: 'Gül, ýaprak',
        chemicalComposition: 'Giperisin, efir ýaglary',
        contraindications: 'Günüň aşagynda köp durmak maslahat berilmeýär.',
        imageUrl: 'https://images.unsplash.com/photo-1596708059441-26dd7dcf5145',
      ),
      Plant(
        name: 'Ýandak',
        scientificName: 'Alhagi maurorum',
        description: 'Tikenli ösümlik, çölde bitýär. Ýandak baly meşhurdyr.',
        medicalUses: 'Sowuklama, böwrek, iç sürji.',
        preparationMethod: 'Gülini we ýapragyny demlenmeli.',
        relatedDiseases: 'Böwrek, sowuklama, iç gatamak',
        usedPart: 'Gül, ýaprak',
        chemicalComposition: 'Saharoza, organiki kislotalar',
        contraindications: 'Ýokary şahsy duýgurlyk.',
        imageUrl: 'https://images.unsplash.com/photo-1588666309990-d68f08e3d4a6',
      ),
      Plant(
        name: 'Üzerlik',
        scientificName: 'Peganum harmala',
        description: 'Gadymy dermanlyk ösümlik. Esasan tüssesi bilen dezinfeksiýa edilýär.',
        medicalUses: 'Infeksiýalar, sowuklama, rinit.',
        preparationMethod: 'Tüssesini ulanmaly ýa-da demlenmeli.',
        relatedDiseases: 'Infeksiýa, rinit, revmatizm',
        usedPart: 'Tohum',
        chemicalComposition: 'Harmalin, garmon',
        contraindications: 'Göwreli aýallar ulanmaly däl.',
        imageUrl: 'https://images.unsplash.com/photo-1603507864264-7c18448ef039',
      ),
      Plant(
        name: 'Çopantelpek',
        scientificName: 'Matricaria chamomilla',
        description: 'Ak gülli ösümlik. Iň meşhur dermanlyk ösümlikleriň biridir.',
        medicalUses: 'Sowuklama, immunitet, köşeşdiriji.',
        preparationMethod: 'Güllerini demläp içmeli.',
        relatedDiseases: 'Immunitet, içge, sowuklama',
        usedPart: 'Gül',
        chemicalComposition: 'Hamazulen, efir ýaglary',
        contraindications: 'Allergiýa bolup biler.',
        imageUrl: 'https://images.unsplash.com/photo-1541832676-9b763b0239ab',
      ),
      Plant(
        name: 'Galkanota',
        scientificName: 'Achillea millefolium',
        description: 'Köpýyllyk dermanlyk ösümlik. Gany saklaýjy häsiýeti bar.',
        medicalUses: 'Gany saklamak, aşgazan, ýara bitirmek.',
        preparationMethod: 'Demleme görnüşinde.',
        relatedDiseases: 'Gan akma, sowuklama, gastrit',
        usedPart: 'Ýaprak, gül',
        chemicalComposition: 'Alkaloidler, witamin K',
        contraindications: 'Gany goýy adamlar üçin howply.',
        imageUrl: 'https://images.unsplash.com/photo-1596135392942-e1d9577963d3',
      ),
      Plant(
        name: 'Sena',
        scientificName: 'Cassia angustifolia',
        description: 'Tebigy iç sürji. Aşgazan-içge ulgamy öçön peýdaly.',
        medicalUses: 'Iç gatamak, horlanmak.',
        preparationMethod: 'Ýapraklaryny demlenmeli.',
        relatedDiseases: 'Aşgazan-içge, gemorroý',
        usedPart: 'Ýaprak',
        chemicalComposition: 'Antraglikozidler',
        contraindications: 'Içege sowuklamasynyň ýitileşmesi.',
        imageUrl: 'https://images.unsplash.com/photo-1563220318-ae78f6955a5b',
      ),
      Plant(
        name: 'Atgulak',
        scientificName: 'Plantago major',
        description: 'Giň ýaprakly ösümlik. Ýol kenarlarynda köp duş gelýär.',
        medicalUses: 'Ýara bitirmek, üsgülewük, gastrit.',
        preparationMethod: 'Ýapraklaryny ulanmaly.',
        relatedDiseases: 'Ýara, sowuklama, gastrit',
        usedPart: 'Ýaprak',
        chemicalComposition: 'Glikozidler, witamin C',
        contraindications: 'Aşkazan şiresi aşa ýokary bolanda.',
        imageUrl: 'https://images.unsplash.com/photo-1589139121708-3af7b886d389',
      ),
      Plant(
        name: 'Narpyz',
        scientificName: 'Mentha piperita',
        description: 'Hoşboý ysly ösümlik. Serginlediji we köşeşdiriji.',
        medicalUses: 'Nerw, aşgazan, ýürek bulaşma.',
        preparationMethod: 'Çayda demlenmeli.',
        relatedDiseases: 'Stres, sowuklama, gastrit',
        usedPart: 'Ýaprak',
        chemicalComposition: 'Mentol, efir ýaglary',
        contraindications: 'Ýürek keselleri bar bolsa.',
        imageUrl: 'https://images.unsplash.com/photo-1564506346410-6745166299f0',
      ),
      Plant(
        name: 'Boýbodran',
        scientificName: 'Tanacetum vulgare',
        description: 'Sary gülli ösümlik. Parazitlere garşy täsirli.',
        medicalUses: 'Parazitler, aşgazan, öt halta.',
        preparationMethod: 'Demleme.',
        relatedDiseases: 'Parazitler, infeksiýa, gepatit',
        usedPart: 'Gül',
        chemicalComposition: 'Efir ýaglary, terpenoidler',
        contraindications: 'Çagalar we göwreli aýallar üçin zyýanly.',
        imageUrl: 'https://images.unsplash.com/photo-1584344793237-7f938c037302',
      )
    ];

    for (var plant in plants) {
      await db.insert('plants', plant.toMap());
    }
  }

  Future<void> _seedCompounds(Database db) async {
    final compounds = [
      Compound(
        name: 'Alkaloid',
        description: 'Ösümliklerde duş gelýän azotly birleşmeler. Esasan dermanlyk häsiýete eýedirler.',
        sourcePlants: 'Üzerlik, Galkanota',
      ),
      Compound(
        name: 'Flavonoid',
        description: 'Ösümliklere reňk berýän we antioksidant häsiýetli birleşmeler.',
        sourcePlants: 'Balanat, Adygeý, Çopantelpek',
      ),
      Compound(
        name: 'Tanin',
        description: 'Iýiji häsiýetli birleşmeler, köp dermanlyk ösümlikleriň düzüminde bar.',
        sourcePlants: 'Ýandak, Atgulak',
      ),
      Compound(
        name: 'Saponin',
        description: 'Suw bilen garylanda köpürjik döredýän tebigy birleşmeler.',
        sourcePlants: 'Köküsiýji, Süýji kök',
      )
    ];

    for (var compound in compounds) {
      await db.insert('compounds', compound.toMap());
    }
  }

  Future<List<Plant>> searchPlants(String query) async {
    final db = await database;
    if (query.isEmpty) {
      final result = await db.query('plants');
      return result.map((json) => Plant.fromMap(json)).toList();
    }
    
    final result = await db.query(
      'plants',
      where: 'name LIKE ? OR medicalUses LIKE ? OR relatedDiseases LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return result.map((json) => Plant.fromMap(json)).toList();
  }

  Future<List<Compound>> searchCompounds(String query) async {
    final db = await database;
    if (query.isEmpty) {
      final result = await db.query('compounds', orderBy: 'name ASC');
      return result.map((json) => Compound.fromMap(json)).toList();
    }
    
    final result = await db.query(
      'compounds',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((json) => Compound.fromMap(json)).toList();
  }

  Future<void> saveChatMessage(ChatMessage message) async {
    final db = await database;
    await db.insert('chat_messages', message.toMap());
  }

  Future<List<ChatMessage>> getChatMessages() async {
    final db = await database;
    final result = await db.query('chat_messages', orderBy: 'timestamp ASC');
    return result.map((json) => ChatMessage.fromMap(json)).toList();
  }

  Future<void> close() async {
    final db = _database;
    await db?.close();
  }
}
