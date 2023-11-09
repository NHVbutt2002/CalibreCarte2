import 'dart:io';
import 'package:buildtest/homepage.dart';
import 'package:buildtest/providers/book_details_navigation_provider.dart';
import 'package:buildtest/providers/color_theme_provider.dart';
import 'package:buildtest/providers/list_tile.dart';
import 'package:buildtest/providers/update_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? tokenExists;
  String? searchFilter;
  Future? myFuture;
  bool? darkMode;

  Future<void> getTokenAndSearchFromPreferences() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    darkMode = sp.getBool('darkMode') ?? false;
    tokenExists = sp.containsKey('token');
    searchFilter = sp.getString('searchFilter') ?? 'title';
    if (Platform.isIOS) return;
//    Set the default download directory here once if it not set already
    if (!sp.containsKey("downloaded_directory")) {
      Directory? defaultDownloadDirectory = await getExternalStorageDirectory();
//      Creating books if that doesn't exist
      if (!Directory("${defaultDownloadDirectory?.path}/books").existsSync()) {
        Directory("${defaultDownloadDirectory?.path}/books")
            .createSync(recursive: true);
      }

      sp.setString("downloaded_directory",
          defaultDownloadDirectory?.path ?? '' + "/books");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPermisstion();
    myFuture = getTokenAndSearchFromPreferences();
  }

  initPermisstion() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
    ].request();
    print(statuses[Permission.location]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: myFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => Update(tokenExists ?? false, searchFilter ?? ''),
              ),
              ChangeNotifierProvider(
                create: (_) => BookDetailsNavigation(),
              ),
              ChangeNotifierProvider(
                create: (_) => ColorTheme(darkMode ?? false),
              ),
              ChangeNotifierProvider(
                create: (_) => ListTileProvider(),
              )
            ],
            child: MaterialApp(
              title: "Calibre Carte",
              home: MyHomePage(),
            ),
          );
        } else {
          return Container(
              color: Colors.white, child: CircularProgressIndicator());
        }
      },
    );
  }
}

class PermissionGroup {}
