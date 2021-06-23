import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/models/anuncio.dart';
import 'package:olx/util/configuracoes.dart';
import 'package:olx/views/widget/item_anuncio.dart';

class Anuncios extends StatefulWidget {
  @override
  _AnunciosState createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {
  final controller = StreamController<QuerySnapshot>.broadcast();

  List<String> itensMenu = [];
  String itemSelecionadoEstado;
  String itemSelecionadoCategoria;

  List<DropdownMenuItem<String>> _listaItensDropEstados = List();
  List<DropdownMenuItem<String>> _listaItensDropCategorias = List();

  _escolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case "Meus Anuncios":
        Navigator.pushNamed(context, '/meus-anuncios');
        break;
      case "Entrar / Cadastrar":
        Navigator.pushNamed(context, '/login');
        break;
      case "Deslogar":
        _deslogarUsuario();
        break;
    }
  }

  _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushNamed(context, '/login');
  }

  Future _verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    if (usuarioLogado == null) {
      itensMenu = ['Entrar / Cadastrar'];
    } else {
      itensMenu = ['Meus Anuncios', "Deslogar"];
    }
  }

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncio() async {
    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db.collection('anuncios').snapshots();

    stream.listen((dados) {
      controller.add(dados);
    });
  }

  Future<Stream<QuerySnapshot>> filtrarAnuncioListenerAnuncio() async {
    Firestore db = Firestore.instance;
    Query query = db.collection('anuncios');

    if (itemSelecionadoEstado != null) {
      query = query.where('estado', isEqualTo: itemSelecionadoEstado);
    }
    if (itemSelecionadoCategoria != null) {
      query = query.where('categoria', isEqualTo: itemSelecionadoCategoria);
    }

    Stream<QuerySnapshot> stream = query.snapshots();

    stream.listen((dados) {
      controller.add(dados);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _carregarItensDropDown();
    _verificarUsuarioLogado();
    _adicionarListenerAnuncio();
  }

  _carregarItensDropDown() async {
    _listaItensDropEstados = Configuracoes.getEstados();

    _listaItensDropCategorias = Configuracoes.getCategorias();
  }

  @override
  Widget build(BuildContext context) {
    var carregandoDados = Center(
      child: Column(
        children: [
          Text('Carregando anuncios'),
          CircularProgressIndicator(),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'OLX',
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context) {
              return itensMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            //Filtros
            Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: Center(
                      child: DropdownButton(
                        iconEnabledColor: Colors.purple,
                        value: itemSelecionadoEstado,
                        items: _listaItensDropEstados,
                        style: TextStyle(fontSize: 22, color: Colors.black),
                        onChanged: (estado) {
                          setState(() {
                            itemSelecionadoEstado = estado;
                            filtrarAnuncioListenerAnuncio();
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey[200],
                  width: 4,
                  height: 60,
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: Center(
                      child: DropdownButton(
                        iconEnabledColor: Colors.purple,
                        value: itemSelecionadoCategoria,
                        items: _listaItensDropCategorias,
                        style: TextStyle(fontSize: 22, color: Colors.black),
                        onChanged: (categoria) {
                          setState(() {
                            itemSelecionadoCategoria = categoria;
                            filtrarAnuncioListenerAnuncio();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //Listagem de anuncios
            StreamBuilder(
              stream: controller.stream,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return carregandoDados;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    QuerySnapshot querySnapshot = snapshot.data;

                    if (querySnapshot.documents.length == 0) {
                      return Container(
                        padding: EdgeInsets.all(25),
                        child: Text(
                          'Nenhum Anuncio',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      );
                    } else {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: querySnapshot.documents.length,
                          itemBuilder: (_, index) {
                            List<DocumentSnapshot> anuncios =
                                querySnapshot.documents.toList();
                            DocumentSnapshot documentSnapshot = anuncios[index];
                            Anuncio anuncio =
                                Anuncio.fromDocumentSnapshot(documentSnapshot);
                            return ItemAnuncio(
                              anuncio: anuncio,
                              onTapItem: () {
                                Navigator.pushNamed(
                                  context,
                                  '/detalhes-anuncio',
                                  arguments: anuncio,
                                );
                              },
                              onPressedremover: null,
                            );
                          },
                        ),
                      );
                    }
                }
                return Container();
              },
            )
          ],
        ),
      ),
    );
  }
}
