import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/models/anuncio.dart';
import 'package:olx/views/widget/item_anuncio.dart';

class MeusAnuncios extends StatefulWidget {
  @override
  _MeusAnunciosState createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {
  final controller = StreamController<QuerySnapshot>.broadcast();
  String idUsuarioLogado;

  recuperarDadosUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    idUsuarioLogado = usuarioLogado.uid;
  }

  Future<Stream<QuerySnapshot>> _adicionarListener() async {
    await recuperarDadosUsuarioLogado();
    Firestore db = Firestore.instance;

    Stream<QuerySnapshot> stream = db
        .collection('meus_anuncios')
        .document(idUsuarioLogado)
        .collection('anuncios')
        .snapshots();

    stream.listen((dados) {
      controller.add(dados);
    });
  }

  @override
  void initState() {
    super.initState();
    _adicionarListener();
  }

  void _removerAnuncio(String id) {
    Firestore db = Firestore.instance;
    db
        .collection('meus_anuncios')
        .document(idUsuarioLogado)
        .collection('anuncios')
        .document(id)
        .delete()
        .then((_) {
      db.collection('anuncios').document(id).delete();
    });
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
        title: Text('Meus Anuncios'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('Adicionar'),
        onPressed: () {
          Navigator.pushNamed(context, '/novo-anuncio');
        },
      ),
      body: StreamBuilder(
        stream: controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return carregandoDados;
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text('Erro ao carregar os dados');
              } else {
                QuerySnapshot querySnapshot = snapshot.data;

                return ListView.builder(
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, index) {
                      List<DocumentSnapshot> anuncios =
                          querySnapshot.documents.toList();
                      DocumentSnapshot documentSnapshot = anuncios[index];
                      Anuncio anuncio =
                          Anuncio.fromDocumentSnapshot(documentSnapshot);

                      return ItemAnuncio(
                        anuncio: anuncio,
                        onTapItem: () {},
                        onPressedremover: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Confirmar'),
                                  content: Text(
                                      'Deseja realmente excluir o anuncio ?'),
                                  actions: [
                                    FlatButton(
                                      child: Text(
                                        'Cancelar',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      color: Colors.red,
                                      child: Text(
                                        'Remover',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () {
                                        _removerAnuncio(anuncio.id);
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              });
                        },
                      );
                    });
              }
          }
          return Container();
        },
      ),
    );
  }
}
