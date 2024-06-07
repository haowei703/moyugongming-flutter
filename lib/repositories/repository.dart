import 'package:sqflite/sqflite.dart';

class BaseRepository {
  final Database database;

  BaseRepository(this.database);


  Future<void> add(String table, Map<String, dynamic> data) async {
    await database.insert(table, data);
  }

  Future<void> delete(String table, int id) async {
    await database.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update(String table, Map<String, dynamic> data) async {
    int id = data['id'];
    await database.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>> query(String table, int id) async {
    List<Map<String, dynamic>> maps =
        await database.query(table, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    throw Exception('Item not found!');
  }
}
