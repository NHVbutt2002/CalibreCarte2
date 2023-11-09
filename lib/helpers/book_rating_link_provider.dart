import 'package:buildtest/helpers/ratings_provider.dart';
import 'package:buildtest/models/books.dart';
import 'package:buildtest/models/books_ratings_link.dart';
import 'package:buildtest/models/ratings.dart';
import 'package:sqflite/sqflite.dart';

import 'db_helper.dart';

class BooksRatingLinkProvider {
  static String tableName = 'books_ratings_link';

  static Future<BooksRatingLink> getFirstBookLinkProvider() async {
    Database db = await DatabaseHelper.instance.db;
    List<Map<String, dynamic>> maps = await db.query(tableName);
    return BooksRatingLink.fromMapObject(maps.first);
  }

  static Future<Ratings?> getRatingByBookID(int id) async {
//    print("book id $id");
    Database db = await DatabaseHelper.instance.db;
    try {
      List<Map<String, dynamic>> maps = await db.query(tableName,
          where: '${BooksRatingLink.columns[1]} = ?', whereArgs: [id]);
//      print(maps);
      if (maps == null) {
        return null;
      } else {
        BooksRatingLink x = BooksRatingLink.fromMapObject(maps.first);
//        print ("rating id ${x.rating}");
        Ratings? rating =
            await RatingsProvider.getRatingByID(x.rating ?? 0, null);
        return rating;
      }
    } catch (e) {
//      print("rating link error $e");
      return null;
    }
  }
}
