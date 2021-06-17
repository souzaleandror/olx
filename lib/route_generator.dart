import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:olx/views/anuncios.dart';
import 'package:olx/views/meus_anuncios.dart';
import 'package:olx/views/novo_anuncio.dart';

import 'login.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Anuncios());
        break;
      case '/login':
        return MaterialPageRoute(builder: (_) => Login());
        break;
      case '/meus-anuncios':
        return MaterialPageRoute(builder: (_) => MeusAnuncios());
        break;
      case '/novo-anuncio':
        return MaterialPageRoute(builder: (_) => NovoAnuncio());
        break;
      default:
        _erroRota();
        break;
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Tela nao encontrada',
            ),
          ),
          body: Container(
            child: Center(
              child: Text(
                'Tela nao encontrada',
              ),
            ),
          ),
        );
      },
    );
  }
}
