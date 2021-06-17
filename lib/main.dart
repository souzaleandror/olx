import 'package:flutter/material.dart';
import 'package:olx/route_generator.dart';
import 'package:olx/views/anuncios.dart';

final ThemeData temaPadrao =
    ThemeData(primaryColor: Color(0xff9c27b0), accentColor: Color(0xff7b1fa2));

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: temaPadrao,
    home: Anuncios(),
    initialRoute: '/',
    onGenerateRoute: RouteGenerator.generateRoute,
  ));
}
