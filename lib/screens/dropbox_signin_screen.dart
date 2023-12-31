import 'dart:async';
import 'dart:io';

import 'package:buildtest/helpers/metadata_cacher.dart';
import 'package:buildtest/providers/update_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart';

class DropboxAuthentication extends StatefulWidget {
  final String selectedUrl;
  final BuildContext? oldContext;

  DropboxAuthentication({required this.selectedUrl, this.oldContext});

  @override
  _DropboxAuthenticationState createState() =>
      _DropboxAuthenticationState(selectedUrl);
}

class _DropboxAuthenticationState extends State<DropboxAuthentication> {
  final url;
  // final Completer<WebViewController> webViewcontroller =
  //     Completer<WebViewController>();
  final WebViewController webViewcontroller = WebViewController();
  bool isLoadingPage = false;
  final key = UniqueKey();
  int _stackToView = 1;

  StreamSubscription? _sub;

  _makePostRequest(token) async {
//    print(token);
    // set up POST request arguments
    String url = 'https://api.dropboxapi.com/2/files/search_v2';
    Map<String, String> headers = {
      "Authorization": "Bearer $token",
      "Content-type": "application/json"
    };
    String json =
        '{"query": "metadata.db", "options":{"filename_only":true, "file_extensions":["db"]}}'; // make POST request
    Response response =
        await post(Uri(path: url), headers: headers, body: json);
    int statusCode = response.statusCode;
    String body = response.body;
    return response;
  }

  Future<Null> initUniLinks() async {
    // ... check initialLink

    // Attach a listener to the stream
    _sub = getLinksStream().listen((String? link) {
      //Although this is not needed now, but Google actually recommends against using a webview for,
      //So assuming in future we need to do it the url_launcher way then we would have to use this method
//      print(link);
      //So, just keeping it here.
      // Parse the link and warn the user, if it is not correct
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });

    // NOTE: Don't forget to call _sub.cancel() in dispose()
  }

  //Let's try and figure out if I can attach a listener and then parse and do something when I finally get a URL back

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _sub?.cancel();
  }

  void _handleLoad(String value) {
    setState(() {
      _stackToView = 0;
    });
  }

  _DropboxAuthenticationState(this.url);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoadingPage = true;
    webViewcontroller..setJavaScriptMode(JavaScriptMode.unrestricted);
//     ..
//             initialUrl: widget.selectedUrl,
//             onWebViewCreated: (WebViewController webViewController) {
//               webViewcontroller.complete(webViewController);
//             },
//             onavigationDelegate: (NavigationRequest request) {
//               if (request.url.startsWith('calibrecarte://dropbox')) {
// //                _launchURL(request.url);
//                 //Here you parse the url and get back the token value and send it wherever or store it in some state
//                 //List opf things to do
//                 // 1. Parse the token from the url. 2. Store the token in shared prefs
//                 // 3. Do a search for calibre libs
//                 // 4. Store all the information on calibre libs like number, and paths
//                 // 5. If less than 1, make that the selected lib and pop this page
//                 // 6. If more than 1, display a popUp telling the user to choose a default one
//                 // 7. When user has selected the library to show, store the information in calibre_selcted_lib
//                 // 8. Finally pop this page
//                 var uri = Uri.parse(request.url);
//                 // Step 1. Parse the token
//                 String? token;
//                 var tempUri = Uri.parse('http://test.com?${uri.fragment}');
//                 tempUri.queryParameters.forEach((k, v) {
// //                  print(k);
//                   if (k == "access_token") {
//                     token = v;
//                   }
//                 });
//                 // Step 2: Storing token in shared prefs. Remember this is async so, the next statement would be executed immediately
//                 // Step 3 Make a call to search for calibre libs
//                 Map<String, String> pathNameMap = Map();
//                 _makePostRequest(token).then((response) {
//                   //Make a map Map<String, String> First value is the base path in lower case
//                   // Second Value is the name of the Folder(Library)
//                   // I have to convert string response.body to json
//                   Map<String, dynamic> responseJson = jsonDecode(response.body);
//                   if (responseJson['matches'].length != 0) {
//                     responseJson['matches'].forEach((element) {
//                       if (element["metadata"]["metadata"]["name"] ==
//                           "metadata.db") {
//                         String libPath =
//                             element["metadata"]["metadata"]["path_display"];
//                         libPath = libPath.replaceAll('metadata.db', "");
//                         List<String> directories = element["metadata"]
//                                 ["metadata"]["path_display"]
//                             .split('/');
//                         String libName =
//                             directories.elementAt(directories.length - 2);
//                         pathNameMap.putIfAbsent(libPath, () => libName);
// //                        print(pathNameMap);
//                       }
//                     });
//                     storeIntInSharedPrefs(
//                         'noOfCalibreLibs', pathNameMap.length);
//                     pathNameMap.keys.toList().asMap().forEach((index, path) {
//                       String keyName = 'calibre_lib_path_$index';
//                       String libName = 'calibre_lib_name_$index';
//                       storeStringInSharedPrefs(keyName, path);
//                       storeStringInSharedPrefs(libName, pathNameMap[path]);
//                     });

//                     // TODO: Default selection
//                     storeStringInSharedPrefs(
//                       'selected_calibre_lib_path',
//                       pathNameMap.keys.first,
//                     );
//                     storeStringInSharedPrefs(
//                       'selected_calibre_lib_name',
//                       pathNameMap.values.first,
//                     );
//                     if (pathNameMap.length > 1) {
//                       // First set the no of libraries in shared prefs
//                       // Show a pop up which displays the list of libraries
// //                      print('I have come inside the popup dispaly htingy');
//                       List<Widget> columnChildren =
//                           pathNameMap.keys.toList().map((element) {
//                         return InkWell(
//                             onTap: () {
//                               _showLoading(context);
//                               selectingCalibreLibrary(
//                                   element, pathNameMap[element], update, token);
//                             },
//                             child: Container(
//                               padding: EdgeInsets.all(8),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: <Widget>[
//                                   Icon(
//                                     Icons.folder,
//                                     color: Color(0xffFED962),
//                                   ),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
//                                   Text(
//                                     pathNameMap[element] ?? '',
//                                     style: TextStyle(
//                                         fontSize: 15,
//                                         fontFamily: 'Montserrat',
//                                         color: Color(0xff002242)),
//                                   )
//                                 ],
//                               ),
//                             ));
//                       }).toList();
//                       showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return WillPopScope(
//                               onWillPop: () async {
//                                 _showLoading(context);
//                                 await MetadataCacher()
//                                     .downloadAndCacheMetadata(token: token)
//                                     .then((val) {
//                                   if (val == 1) {
//                                     storeStringInSharedPrefs('token', token);
//                                     update.changeTokenState(true);
//                                     update.updateFlagState(true);
//                                   }
//                                   Navigator.of(context).pop();
//                                   Navigator.of(context).pop();
//                                 });
//                                 return true;
//                               },
//                               child: AlertDialog(
//                                 contentPadding: EdgeInsets.all(10),
//                                 content: Container(
//                                   width: 300,
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: <Widget>[
//                                       Container(
//                                           child: Text(
//                                         'Select Library',
//                                         style: TextStyle(
//                                             fontSize: 20,
//                                             fontFamily: 'Montserrat',
//                                             color: Color(0xff002242)),
//                                       )),
//                                       SizedBox(
//                                         height: 20,
//                                       ),
//                                       Column(children: columnChildren)
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           });
//                     } else {
//                       _showLoading(context);
//                       storeStringInSharedPrefs(
//                           'selected_calibre_lib_path', pathNameMap.keys.first);
//                       storeStringInSharedPrefs('selected_calibre_lib_name',
//                           pathNameMap.values.first);
//                       MetadataCacher()
//                           .downloadAndCacheMetadata(token: token)
//                           .then((val) {
//                         if (val == 1) {
// //                          print("storing token");
//                           storeStringInSharedPrefs('token', token);
// //                          print("stored token");
//                           update.changeTokenState(true);
//                           update.updateFlagState(true);
//                         }
//                         Navigator.of(context).pop();
//                         Navigator.of(context).pop();
//                       });
//                       // Her we have only one library so we make that the default
//                     }
//                   } else {
//                     ScaffoldMessenger.of(widget.oldContext ?? context)
//                         .showSnackBar(SnackBar(
//                       content: Text("No Calibre libraries found"),
//                     ));
//                     Navigator.of(context).pop();
//                     // Show the bottom snack bar that no libraries found and Pop out of this context
//                   }
//                 });
// //                Navigator.pop(context);
//                 return NavigationDecision.prevent;
//               }

// //              print('allowing navigation to $request');
//               return NavigationDecision.navigate;
//             },
//             onPageFinished: _handleLoad,
    initUniLinks();
  }

  Future<void> storeStringInSharedPrefs(key, val) async {
//    print("Storing token");
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(key, val);
  }

  Future<void> storeIntInSharedPrefs(key, val) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setInt(key, val);
  }

  selectingCalibreLibrary(key, val, update, token) {
    storeStringInSharedPrefs('selected_calibre_lib_path', key);
    storeStringInSharedPrefs('selected_calibre_lib_name', val);
    MetadataCacher().downloadAndCacheMetadata(token: token).then((val) {
      if (val == 1) {
//        print("storing token");
        storeStringInSharedPrefs('token', token);
//        print("stored token");
        update.changeTokenState(true);
        update.updateFlagState(true);
      }
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    });
  }

  _showLoading(BuildContext context) {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: UniqueKey(),
                  backgroundColor: Colors.black54,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Loading Calibre library",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      ]),
                    )
                  ]));
        });
  }

  @override
  Widget build(BuildContext context) {
    Update update = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff002242),
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text('Dropbox Login',
            style: TextStyle(fontFamily: 'Montserrat', color: Colors.white)),
      ),
      body: IndexedStack(
        index: _stackToView,
        children: <Widget>[
          Text('Redirecting to dropbox'),
          WebViewWidget(key: key, controller: webViewcontroller),
          Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
