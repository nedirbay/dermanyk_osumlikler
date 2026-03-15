import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../data/models/plant.dart';
import '../../data/models/compound.dart';
import '../../data/models/chat_message.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  static Future<Database>? _initializationFuture;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Prevent parallel initialization
    _initializationFuture ??= _initDB('plant_database.db');
    _database = await _initializationFuture;
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );

    // Check if we need to re-seed compounds (handle duplicates from previous bug)
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM compounds'));
    if (count != null && (count <= 4 || count > 500)) {
      await db.delete('compounds');
      await _seedCompounds(db);
    }

    // Check if we need to re-seed plants (ensure 20 plants are loaded)
    final plantCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM plants'));
    if (plantCount != null && plantCount < 20) {
      await db.delete('plants');
      await _seedData(db);
    }

    return db;
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
  }

  Future<void> _seedData(Database db) async {
    final plants = [
      Plant(
        name: 'Balanat (Buyan)',
        scientificName: 'Glycyrrhiza glabra',
        description: 'Köpýyllyk dermanlyk ösümlik. Köküniň süýji tagamy bar.',
        medicalUses: 'Sowuklama, üsgülewük, aşgazan ýarasy.',
        preparationMethod: '1 nahar çemçesi köküni 200ml suwda 15 minut gaýnatmaly.',
        relatedDiseases: 'Sowuklama, gastrit, bronhit',
        usedPart: 'Kök',
        chemicalComposition: 'Glisirrizin, flavonoidler',
        contraindications: 'Gipertoniýa, göwrelilik.',
        imageUrl: 'assets/images/plants/buyan.jpg',
      ),
      Plant(
        name: 'Sary çopantelpek',
        scientificName: 'Hypericum perforatum',
        description: 'Güýçli dermanlyk häsiýeti bolan ösümlik.',
        medicalUses: 'Nerw ulgamy, aşgazan, öt, ýara bitirmek.',
        preparationMethod: 'Gülleri demlenip içilýär.',
        relatedDiseases: 'Depressiýa, gastrit, ýara',
        usedPart: 'Gül, ýaprak',
        chemicalComposition: 'Giperisin, efir ýaglary',
        contraindications: 'Günüň şöhlesine duýgurlyk.',
        imageUrl: 'assets/images/plants/sary_çopantelpek.jpg',
      ),
      Plant(
        name: 'Ýandak',
        scientificName: 'Alhagi maurorum',
        description: 'Tikenli ösümlik, çöl şertlerine çydamly.',
        medicalUses: 'Iç sürji, böwrek, sowuklama.',
        preparationMethod: 'Ýapraklary we gülleri demlenme görnüşinde.',
        relatedDiseases: 'Böwrek daşy, sowuklama',
        usedPart: 'Ýaprak, gül',
        chemicalComposition: 'Flavonoidler, witaminler',
        contraindications: 'Aşgazan ýarasy ýitileşende.',
        imageUrl: 'assets/images/plants/ýandak.jpg',
      ),
      Plant(
        name: 'Üzerlik',
        scientificName: 'Peganum harmala',
        description: 'Gadymy dermanlyk ösümlik, dezinfeksiýa üçin ulanylýar.',
        medicalUses: 'Nerw, revmatizm, infeksiýalar.',
        preparationMethod: 'Tüssesi dezinfeksiýa üçin, demi sowuklama üçin.',
        relatedDiseases: 'Sowuklama, infeksiýa',
        usedPart: 'Tohum',
        chemicalComposition: 'Alkaloidler (garmalin)',
        contraindications: 'Aşa köp ulanmak zäherli bolup biler.',
        imageUrl: 'assets/images/plants/üzerlik.jpg',
      ),
      Plant(
        name: 'Ak çopantelpek',
        scientificName: 'Matricaria chamomilla',
        description: 'Iň köp ulanylýan köşeşdiriji ösümlikleriň biri.',
        medicalUses: 'Sowuklama, aşgazan, ukusyzlyk.',
        preparationMethod: 'Gülleri demlenip içilýär.',
        relatedDiseases: 'Stres, sowuklama, içge',
        usedPart: 'Gül',
        chemicalComposition: 'Hamazulen, efir ýaglary',
        contraindications: 'Indiwidual duýgurlyk.',
        imageUrl: 'assets/images/plants/ak_çopantelpek.jpg',
      ),
      Plant(
        name: 'Galkanota',
        scientificName: 'Achillea millefolium',
        description: 'Gany saklaýjy häsiýeti bolan dermanlyk ösümlik.',
        medicalUses: 'Gan akma, aşgazan, sowuklama.',
        preparationMethod: '1 nahar çemçesi demlenmeli.',
        relatedDiseases: 'Gan akma, gastrit',
        usedPart: 'Gül, ýaprak',
        chemicalComposition: 'Alkaloidler, witamin K',
        contraindications: 'Gan goýulygy ýokary bolanda.',
        imageUrl: 'assets/images/plants/galkanota.jpg',
      ),
      Plant(
        name: 'Sena (Mekge ýapragy)',
        scientificName: 'Cassia angustifolia',
        description: 'Iç sürji häsiýetli dermanlyk ösümlik.',
        medicalUses: 'Iç gatamak, horlanmak.',
        preparationMethod: 'Ýapraklary demlenmeli (giçlik).',
        relatedDiseases: 'Iç gatamak',
        usedPart: 'Ýaprak',
        chemicalComposition: 'Antraglikozidler',
        contraindications: 'Içege sowuklamasynyň ýitileşmesi.',
        imageUrl: 'assets/images/plants/sena.jpg',
      ),
      Plant(
        name: 'Atgulak',
        scientificName: 'Plantago major',
        description: 'Giň ýaprakly, ýölaýrytlarda bitýän ösümlik.',
        medicalUses: 'Ýara bitirmek, üsgülewük, gastrit.',
        preparationMethod: 'Ýaprak şiresi ýa-da demlenme.',
        relatedDiseases: 'Üsgülewük, gastrit, ýara',
        usedPart: 'Ýaprak',
        chemicalComposition: 'Hatarin, witamin C',
        contraindications: 'Aşgazan şiresi köp bolanda.',
        imageUrl: 'assets/images/plants/atgulak.jpg',
      ),
      Plant(
        name: 'Narpyz (Narpyz)',
        scientificName: 'Mentha piperita',
        description: 'Hoşboý ysly, serginlediji dermanlyk ösümlik.',
        medicalUses: 'Nerw, ýürek bulaşma, aşgazan.',
        preparationMethod: 'Ýapraklaryny demläp içmeli.',
        relatedDiseases: 'Ukusyzlyk, nerw, gastrit',
        usedPart: 'Ýaprak',
        chemicalComposition: 'Mentol, efir ýaglary',
        contraindications: 'Pes gan basyşy.',
        imageUrl: 'assets/images/plants/narpyz.jpg',
      ),
      Plant(
        name: 'Boýbodran',
        scientificName: 'Tanacetum vulgare',
        description: 'Parazitlere garşy ulanylýan sary gülli ösümlik.',
        medicalUses: 'Parazitler, öt, aşgazan.',
        preparationMethod: 'Gülleri demlenme görnüşinde.',
        relatedDiseases: 'Gelmintozlar, gepatit',
        usedPart: 'Gül',
        chemicalComposition: 'Terpenoidler',
        contraindications: 'Göwrelilik, çagalara bolmaýar.',
        imageUrl: 'assets/images/plants/boýbodran.jpg',
      ),
      Plant(
        name: 'Itburun (Rosa)',
        scientificName: 'Rosa canina',
        description: 'Witaminlere, esasan witamin C-e örän baý miweli ösümlik.',
        medicalUses: 'Immunitet, aşgazan, böwrek.',
        preparationMethod: 'Miweleri termosa demlenmeli.',
        relatedDiseases: 'Witamin ýetmezçiligi, sowuklama',
        usedPart: 'Miwe',
        chemicalComposition: 'Witamin C, B2, K, P',
        contraindications: 'Diş emaly üçin zyýanly bolup biler.',
        imageUrl: 'assets/images/plants/itburun.jpg',
      ),
      Plant(
        name: 'Šalfeý',
        scientificName: 'Salvia officinalis',
        description: 'Sowuklama garşy güýçli dermanlyk ösümlik.',
        medicalUses: 'Bogaz agyry, diş etiniň sowuklamasy.',
        preparationMethod: 'Bogaz çaýkamak üçin demlenme.',
        relatedDiseases: 'Angina, stomatit',
        usedPart: 'Ýaprak',
        chemicalComposition: 'Efir ýaglary, taninler',
        contraindications: 'Ýiti böwrek sowuklamasy.',
        imageUrl: 'assets/images/plants/šalfeý.jpg',
      ),
      Plant(
        name: 'Balan (Kalina)',
        scientificName: 'Viburnum opulus',
        description: 'Gany saklaýjy we köşeşdiriji häsiýetli gyzyl miweli ösümlik.',
        medicalUses: 'Gan basyşy, sowuklama, nerw.',
        preparationMethod: 'Miwesi we gabygy demlenilýär.',
        relatedDiseases: 'Gipertoniýa, sowuklama',
        usedPart: 'Miwe, gabyk',
        chemicalComposition: 'Witamin C, witamin K',
        contraindications: 'Ganyň lagtalanmasy ýokary bolanda.',
        imageUrl: 'assets/images/plants/balan.jpg',
      ),
      Plant(
        name: 'Ewkalit',
        scientificName: 'Eucalyptus globulus',
        description: 'Bakteriýalara garşy güýçli täsirli agaç ösümligi.',
        medicalUses: 'Sowuklama, bronhit, bogaz agyry.',
        preparationMethod: 'Degerli ýerlere bug bermek (ingalýasiýa).',
        relatedDiseases: 'Bronhit, dümew',
        usedPart: 'Ýaprak',
        chemicalComposition: 'Ewkaliptol',
        contraindications: 'Bronhial astma ýitileşende.',
        imageUrl: 'assets/images/plants/ewkalipt.jpg',
      ),
      Plant(
        name: 'Waleriýana',
        scientificName: 'Valeriana officinalis',
        description: 'Köşeşdiriji we ukladyjy dermanlyk ösümlik.',
        medicalUses: 'Ukusyzlyk, nerw, ýürek urşunyň bozulmagy.',
        preparationMethod: 'Köküni demlemeli.',
        relatedDiseases: 'Nerw, ukusyzlyk',
        usedPart: 'Kök',
        chemicalComposition: 'Efir ýaglary, alkaloidler',
        contraindications: 'Uzak wagt ulanmak bolmaýar.',
        imageUrl: 'assets/images/plants/waleriýana.jpg',
      ),
      Plant(
        name: 'Kalendula',
        scientificName: 'Calendula officinalis',
        description: 'Sary we mämişi gülli, ýara bitiriji ösümlik.',
        medicalUses: 'Ýara bitirmek, bogaz, aşgazan.',
        preparationMethod: 'Demleme we ýaglary ulanylýar.',
        relatedDiseases: 'Aşgazan ýarasy, stomatit',
        usedPart: 'Gül',
        chemicalComposition: 'Karotinoidler, flavonoidler',
        contraindications: 'Past gan basyşy.',
        imageUrl: 'assets/images/plants/kalendula.jpg',
      ),
      Plant(
        name: 'Arça',
        scientificName: 'Juniperus',
        description: 'Hemişe gök ösümlik, havany temizleýji häsiýeti bar.',
        medicalUses: 'Böwrek, sowuklama, revmatizm.',
        preparationMethod: 'Gozalary demlenmeli.',
        relatedDiseases: 'Sowuklama, böwrek',
        usedPart: 'Goza',
        chemicalComposition: 'Witamin C, efir ýaglary',
        contraindications: 'Ýiti nefrit.',
        imageUrl: 'assets/images/plants/arça.jpg',
      ),
      Plant(
        name: 'Kekre (Polyn)',
        scientificName: 'Artemisia absinthium',
        description: 'Aşgazan şiresini bölüp çykarmak içun peýdaly ajy ösümlik.',
        medicalUses: 'Išdä açmak, aşgazan, öt.',
        preparationMethod: 'Az mukdarda demlenme.',
        relatedDiseases: 'Anoreksiýa, gastrit',
        usedPart: 'Ýaprak',
        chemicalComposition: 'Abisintin, efir ýaglary',
        contraindications: 'Göwrelilik, içege ýarasy.',
        imageUrl: 'assets/images/plants/kekre.jpg',
      ),
      Plant(
        name: 'Gara turp',
        scientificName: 'Raphanus sativus',
        description: 'Üsgülewüge garşy tebigy derman miwesi.',
        medicalUses: 'Üsgülewük, sowuklama, öt.',
        preparationMethod: 'Bal bilen garyp şiresi içilýär.',
        relatedDiseases: 'Üsgülewük, sowuklama',
        usedPart: 'Miwe',
        chemicalComposition: 'Glikozidler, witaminler',
        contraindications: 'Ýürek we aşgazan ýarasy.',
        imageUrl: 'assets/images/plants/gara_turp.jpg',
      ),
      Plant(
        name: 'Boran (Lobelia)',
        scientificName: 'Lobelia inflata',
        description: 'Dem alyş ýollaryna täsir edýän dermanlyk ösümlik.',
        medicalUses: 'Bronhial astma, üsgülewük.',
        preparationMethod: 'Lekarstwolaryň düzüminde ulanylýar.',
        relatedDiseases: 'Astma, bronhit',
        usedPart: 'Oty',
        chemicalComposition: 'Lobelin alkaloidi',
        contraindications: 'Ýiti ýürek ýetmezçiligi.',
        imageUrl: 'assets/images/plants/boran.jpg',
      )
    ];

    for (var plant in plants) {
      await db.insert('plants', plant.toMap());
    }
  }

  Future<void> _seedCompounds(Database db) async {
    try {
      final String content = await rootBundle.loadString('assets/data/sozluk.txt');
      final List<String> lines = content.split('\n');
      
      final batch = db.batch();
      for (String line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) continue;
        
        // The format is "Word-Description"
        final separatorIndex = trimmedLine.indexOf('-');
        if (separatorIndex != -1) {
          final name = trimmedLine.substring(0, separatorIndex).trim();
          final description = trimmedLine.substring(separatorIndex + 1).trim();
          
          if (name.isNotEmpty && description.isNotEmpty) {
            batch.insert('compounds', {
              'name': name,
              'description': description,
              'sourcePlants': 'Sözlük',
            });
          }
        }
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print('Error seeding compounds: $e');
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

  Future<int> insertPlant(Plant plant) async {
    final db = await database;
    return await db.insert('plants', plant.toMap());
  }

  Future<int> updatePlant(Plant plant) async {
    final db = await database;
    return await db.update(
      'plants',
      plant.toMap(),
      where: 'id = ?',
      whereArgs: [plant.id],
    );
  }

  Future<int> deletePlant(int id) async {
    final db = await database;
    return await db.delete(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );
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
