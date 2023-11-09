import 'package:buildtest/helpers/book_author_link_provider.dart';
import 'package:buildtest/models/books_authors_link.dart';
import 'package:buildtest/providers/update_provider.dart';
import 'package:buildtest/widgets/books_view_widgets/books_grid_view.dart';
import 'package:buildtest/widgets/books_view_widgets/books_list_view.dart';
import 'package:flutter/material.dart';
import 'package:buildtest/helpers/authors_provider.dart';
import 'package:buildtest/helpers/books_provider.dart';
import 'package:buildtest/models/authors.dart';
import 'package:buildtest/models/books.dart';
import 'package:provider/provider.dart';

class BooksView extends StatefulWidget {
  final String layout;
  final String filter;
  final String sortOption;
  final String sortDirection;
  final Update update;

  BooksView(this.layout, this.filter,
      {required this.sortOption,
      required this.sortDirection,
      required this.update});

  @override
  _BooksViewState createState() => _BooksViewState();
}

class _BooksViewState extends State<BooksView> {
  Future bookDetails = Future(() => null);
  Future afterSorting = Future(() => null);
  List<Books> books = [];
  List<Map<String, String>> authorNames = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBooks().then((_) {
      setState(() {
        afterSorting = sortBooks();
      });
    });
  }

  @override
  void didUpdateWidget(BooksView oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.update.shouldDoUpdate == true) {
      getBooks().then((_) {
        setState(() {
          afterSorting = sortBooks();
        });
      });

      widget.update.shouldDoUpdateFalse();
    }
    if (oldWidget.sortOption == widget.sortOption &&
        oldWidget.sortDirection == widget.sortDirection) {
      return;
    }
    afterSorting = sortBooks();
  }

  Future<void> sortBooks() async {
    if (widget.sortOption == 'author') {
      books.sort((a, b) {
        return a.author_sort!
            .toLowerCase()
            .compareTo(b.author_sort!.toLowerCase());
      });
    } else if (widget.sortOption == 'title') {
      books.sort((a, b) {
        return a.title!.toLowerCase().compareTo(b.title!.toLowerCase());
      });
    } else {
      books.sort((a, b) {
        return a.title!.toLowerCase().compareTo(b.title!.toLowerCase());
      });
    }

    if (widget.sortDirection == 'desc') {
      books = books.reversed.toList();
    }
  }

  //aggregates all the data to display
  Future<void> getBooks() async {
    String? authorText;
    books = await BooksProvider.getAllBooks(widget.update.shouldDoUpdate);
    for (int i = 0; i < books.length; i++) {
      List<BooksAuthorsLink> bookAuthorsLinks =
          await BooksAuthorsLinksProvider.getAuthorsByBookID(books[i].id ?? 0);
      List<String> authors = [];
      for (int i = 0; i < bookAuthorsLinks.length; i++) {
        int authorID = bookAuthorsLinks[i].author ?? 0;
        Authors? author = await AuthorsProvider.getAuthorByID(authorID, null);
        authors.add(author!.name ?? '');

        authorText = authors.reduce((v, e) {
          return v + ', ' + e;
        });
      }
      books[i].author_sort = authorText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: afterSorting,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return widget.layout == "list"
                ? BooksListView(widget.filter, books)
                : (widget.layout == "grid"
                    ? BooksGridView(widget.filter, books)
                    : BooksListView(widget.filter, books));
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
