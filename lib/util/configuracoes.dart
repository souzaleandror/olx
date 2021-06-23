import 'package:brasil_fields/modelos/estados.dart';
import 'package:flutter/material.dart';

class Configuracoes {
  static List<DropdownMenuItem<String>> getCategorias() {
    List<DropdownMenuItem<String>> _listaItensDropCategorias = [];

    _listaItensDropCategorias.add(
      DropdownMenuItem(
        child: Text(
          'Categorias',
          style: TextStyle(
            color: Colors.purple,
          ),
        ),
        value: null,
      ),
    );

    _listaItensDropCategorias.add(
      DropdownMenuItem(
        child: Text('Automovel'),
        value: 'auto',
      ),
    );
    _listaItensDropCategorias.add(
      DropdownMenuItem(
        child: Text('Imovel'),
        value: 'imovel',
      ),
    );
    _listaItensDropCategorias.add(
      DropdownMenuItem(
        child: Text('Moda'),
        value: 'moda',
      ),
    );
    _listaItensDropCategorias.add(
      DropdownMenuItem(
        child: Text('Eletronico'),
        value: 'eletronico',
      ),
    );
    _listaItensDropCategorias.add(
      DropdownMenuItem(
        child: Text('Sport'),
        value: 'sport',
      ),
    );

    return _listaItensDropCategorias;
  }

  static List<DropdownMenuItem<String>> getEstados() {
    List<DropdownMenuItem<String>> _listaItensDropEstados = [];

    _listaItensDropEstados.add(
      DropdownMenuItem(
        child: Text(
          'Regiao',
          style: TextStyle(
            color: Colors.purple,
          ),
        ),
        value: null,
      ),
    );

    for (var estado in Estados.listaEstadosAbrv) {
      _listaItensDropEstados.add(
        DropdownMenuItem(
          child: Text(estado),
          value: estado,
        ),
      );
    }

    return _listaItensDropEstados;
  }
}
