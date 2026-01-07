import 'package:sqflite/sqflite.dart';

import '../models/scan_result.dart';

class LocalDatabase {
  static const String _databaseName = 'platesnap.db';
  static const int _databaseVersion = 1;

  static const String tableScanHistory = 'scan_history';

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$_databaseName';

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableScanHistory (
        id TEXT PRIMARY KEY,
        plate_number TEXT NOT NULL,
        confidence REAL NOT NULL,
        vehicle_type TEXT NOT NULL,
        scanned_at TEXT NOT NULL,
        image_path TEXT
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_scanned_at ON $tableScanHistory (scanned_at DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_plate_number ON $tableScanHistory (plate_number)
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < 2) {
      // Migration for version 2
    }
  }

  // Insert scan result
  static Future<int> insertScanResult(ScanResult result) async {
    final db = await database;
    return await db.insert(
      tableScanHistory,
      result.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all scan results
  static Future<List<ScanResult>> getAllScanResults() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableScanHistory,
      orderBy: 'scanned_at DESC',
    );

    return List.generate(maps.length, (i) => ScanResult.fromJson(maps[i]));
  }

  // Get scan results with pagination
  static Future<List<ScanResult>> getScanResults({
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableScanHistory,
      orderBy: 'scanned_at DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) => ScanResult.fromJson(maps[i]));
  }

  // Search scan results by plate number
  static Future<List<ScanResult>> searchByPlateNumber(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableScanHistory,
      where: 'plate_number LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'scanned_at DESC',
    );

    return List.generate(maps.length, (i) => ScanResult.fromJson(maps[i]));
  }

  // Get scan result by ID
  static Future<ScanResult?> getScanResultById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableScanHistory,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ScanResult.fromJson(maps.first);
  }

  // Delete scan result by ID
  static Future<int> deleteScanResult(String id) async {
    final db = await database;
    return await db.delete(
      tableScanHistory,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all scan results
  static Future<int> deleteAllScanResults() async {
    final db = await database;
    return await db.delete(tableScanHistory);
  }

  // Get count of scan results
  static Future<int> getScanResultsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableScanHistory');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Delete old records to keep only the latest N records
  static Future<void> keepLatestRecords(int maxRecords) async {
    final db = await database;
    final count = await getScanResultsCount();

    if (count > maxRecords) {
      // Get IDs to keep
      final keepIds = await db.rawQuery('''
        SELECT id FROM $tableScanHistory
        ORDER BY scanned_at DESC
        LIMIT ?
      ''', [maxRecords]);

      final idsToKeep = keepIds.map((e) => "'${e['id']}'").join(',');

      // Delete records not in the keep list
      await db.rawDelete('''
        DELETE FROM $tableScanHistory
        WHERE id NOT IN ($idsToKeep)
      ''');
    }
  }

  // Close database
  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
