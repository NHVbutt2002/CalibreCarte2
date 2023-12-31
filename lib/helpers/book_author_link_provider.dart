import 'package:buildtest/models/books_authors_link.dart';
import 'package:sqflite/sqflite.dart';

import 'db_helper.dart';

class BooksAuthorsLinksProvider {
  static String tableName = 'books_authors_link';

  static Future<BooksAuthorsLink> getFirstBookAuthorProvider() async {
    Database db = await DatabaseHelper.instance.db;
    List<Map<String, dynamic>> maps = await db.query(tableName);
    return BooksAuthorsLink.fromMapObject(maps.first);
  }

  static Future<List<BooksAuthorsLink>> getAuthorsByBookID(int id) async {
    Database db = await DatabaseHelper.instance.db;
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: '${BooksAuthorsLink.columns[1]} = ?', whereArgs: [id]);

    List<BooksAuthorsLink> bals = [];
    maps.forEach((mapObject) {
      BooksAuthorsLink x = BooksAuthorsLink.fromMapObject(mapObject);
      bals.add(x);
    });

    return bals;
  }
}
