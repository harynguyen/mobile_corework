import 'dart:convert';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTable(sql.Database database) async {
    await database.execute("""
      CREATE TABLE IF NOT EXISTS dataInfo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        date TEXT NOT NULL,
        parkingAvailable TEXT NOT NULL,
        length TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        description TEXT
      )
    """);
    await database.execute("""
      CREATE TABLE IF NOT EXISTS observation(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        dataInfoId INTEGER,
        observation TEXT,
        time TEXT,
        comment TEXT,  
        image TEXT,
        FOREIGN KEY (dataInfoId) REFERENCES dataInfo(id)
      )
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase('database_name.db', version: 5,
        onCreate: (sql.Database database, int version) async {
      await createTable(database);
    });
  }

  static Future<List<Map<String, dynamic>>> getDataFromDatabase() async {
    final db = await SQLHelper.db();
    final List<Map<String, dynamic>> data = await db.query('dataInfo');
    return data;
  }

  static Future<List<Map<String, dynamic>>>
      getDataFromDatabaseObservation() async {
    final db = await SQLHelper.db();
    final List<Map<String, dynamic>> data = await db.query('observation');
    return data;
  }

  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await SQLHelper.db();
    await createTable(db);
    return db.query('dataInfo', orderBy: 'id');
    // bug
  }

static Future<List<Map<String, dynamic>>> getAllDataWithObservations() async {
  final db = await SQLHelper.db();
  await createTable(db);
  return db.rawQuery('''
    SELECT dataInfo.id AS dataInfoId, dataInfo.name, dataInfo.location, dataInfo.date,
      observation.id AS observationId, observation.observation, observation.time, observation.comment, observation.image
    FROM dataInfo
    LEFT JOIN observation ON dataInfo.id = observation.dataInfoId
    ORDER BY dataInfo.id, observation.id
  ''');
}

  static Future<int> createHikeInfo(
    String name,
    String location,
    String date,
    String parkingAvailable,
    String length,
    String difficulty,
    String? description,
  ) async {
    final db = await SQLHelper.db();
    final data = {
      'name': name,
      'location': location,
      'date': date,
      'parkingAvailable': parkingAvailable,
      'length': length,
      'difficulty': difficulty,
      'description': description,
    };
    final id = await db.insert('dataInfo', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> updateHikeInfo(
    int id,
    String name,
    String location,
    String date,
    String parkingAvailable,
    String length,
    String difficulty,
    String? description,
  ) async {
    final db = await SQLHelper.db();
    final data = {
      'name': name,
      'location': location,
      'date': date,
      'parkingAvailable': parkingAvailable,
      'length': length,
      'difficulty': difficulty,
      'description': description,
    };
    final result =
        await db.update('dataInfo', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteDataInfo(int id) async {
    final db = await SQLHelper.db();
    try {
      final dataInfo =
          await db.query('dataInfo', where: "id = ?", whereArgs: [id]);
      if (dataInfo.isNotEmpty) {
        final dataInfoId = dataInfo[0]['id'];
        await db.delete('observation',
            where: "dataInfoId = ?", whereArgs: [dataInfoId]);
        await db.delete('dataInfo', where: "id = ?", whereArgs: [id]);
      }
    } catch (e) {
      print("Error deleting dataInfo: $e");
    }
  }

  static Future<int> createDataObservation(
    int dataInfoId,
  String observation,
  String time,
  String comment,
  Uint8List _image,
  // Thêm tham số dataInfoId vào hàm
) async {
  final db = await SQLHelper.db();
  final imageString = base64Encode(_image);
  final data = {
    'dataInfoId': dataInfoId,
    'observation': observation,
    'time': time,
    'comment': comment,
    'image': imageString,
      // Đặt giá trị cho cột dataInfoId
  };
  final id = await db.insert('observation', data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace);
  return id;
}

  static Future<int> updateDataObservation(int id, String observation,
      String time, String comment, String imageString) async {
    final db = await SQLHelper.db();
    final data = {
      'observation': observation,
      'time': time,
      'comment': comment,
      'image': imageString,
    };
    final result =
        await db.update('observation', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteDataObservation(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('observation', where: "id = ?", whereArgs: [id]);
    } catch (e) {}
  }
}
