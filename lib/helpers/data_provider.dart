import 'package:buildtest/models/data.dart';
import 'package:sqflite/sqflite.dart';

import 'db_helper.dart';

class DataProvider {
  static String tableName = 'data';

  static Future<List<Data>> getAllBooksData() async {
    Database db = await DatabaseHelper.instance.db;
    List<Map<String, dynamic>> maps = await db.query(tableName);

    List<Data> booksDataList = [];

    maps.forEach((element) {
      booksDataList.add(Data.fromMapObject(element));
    });

    return booksDataList;
  }

  static Future<List<Data>> getDataByBookID(int id) async {
    Database db = await DatabaseHelper.instance.db;
    List<Map<String, dynamic>> maps = await db
        .query(tableName, where: '${Data.columns[1]} = ?', whereArgs: [id]);

    List<Data> booksDataList = [];

    maps.forEach((element) {
      booksDataList.add(Data.fromMapObject(element));
    });

    return booksDataList;
  }
}
