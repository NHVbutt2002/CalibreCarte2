import 'dart:math';

import 'package:buildtest/providers/color_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogoutButton extends StatelessWidget {
  Function() logout;
  LogoutButton(this.logout);
  @override
  Widget build(BuildContext context) {
    ColorTheme colorTheme = Provider.of(context);
    return Card(
      color: Colors.transparent,
      elevation: 0.0,
      child: InkWell(
        onTap: logout,
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.fromLTRB(46, 0, 20, 5),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.exit_to_app,
                    color: colorTheme.settingsIcon,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Logout",
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          color: colorTheme.headerText))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
