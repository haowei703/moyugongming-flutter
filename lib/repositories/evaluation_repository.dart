import 'package:moyugongming/repositories/repository.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<Database> getDatabase() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = join(directory.path, 'evaluation.db');

  return await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
    // 单词表
    await db.execute(
      'CREATE TABLE words(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, word TEXT NOT NULL, category_name TEXT)',
    );
    // 语句表
    await db.execute(
      'CREATE TABLE sentences(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, sentence TEXT NOT NULL, category_name TEXT)',
    );

    // 加载并执行 SQL 文件
    String sqlContent = await rootBundle.loadString('assets/sql/init_data.sql');
    List<String> queries = sqlContent.split(';');
    for (String query in queries) {
      if (query.trim().isNotEmpty) {
        await db.execute(query);
      }
    }
  });
}

class EvaluationRepository extends BaseRepository {
  EvaluationRepository(super.database);


  Future<void> addData() async {

  }

  @override
  Future<void> add(String table, Map<String, dynamic> data) async{

  }

  @override
  Future<Map<String, dynamic>> query(String table, int id) async{
    return super.query(table, id);
  }
 }
