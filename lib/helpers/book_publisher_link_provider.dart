import 'package:buildtest/helpers/publishers_provider.dart';
import 'package:buildtest/helpers/ratings_provider.dart';
import 'package:buildtest/models/books.dart';
import 'package:buildtest/models/books_publishers_link.dart';
import 'package:buildtest/models/books_ratings_link.dart';
import 'package:buildtest/models/publishers.dart';
import 'package:buildtest/models/ratings.dart';
import 'package:sqflite/sqflite.dart';

import 'db_helper.dart';

class BooksPublisherLinkProvider {
  static String tableName = 'books_publishers_link';

  static Future<BooksRatingLink> getFirstBookLinkProvider() async {
    Database db = await DatabaseHelper.instance.db;
    List<Map<String, dynamic>> maps = await db.query(tableName);
    return BooksRatingLink.fromMapObject(maps.first);
  }

  static Future<Publishers?> getPublisherByBookID(int id) async {
//    print("book id $id");
    Database db = await DatabaseHelper.instance.db;
    try {
      List<Map<String, dynamic>> maps = await db.query(tableName,
          where: '${BooksRatingLink.columns[1]} = ?', whereArgs: [id]);
//      print(maps);
      if (maps == null) {
        return null;
      } else {
        BooksPublisherLink x = BooksPublisherLink.fromMapObject(maps.first);
//        print ("rating id ${x.rating}");
        Publishers? publishers =
            await PublishersProvider.getPublisherByID(x.publisher ?? 0, null);
        return publishers;
      }
    } catch (e) {
//      print("rating link error $e");
      return null;
    }
  }
}
