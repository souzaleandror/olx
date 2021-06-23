import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx/models/anuncio.dart';
import 'package:olx/util/configuracoes.dart';
import 'package:olx/views/widget/botao_customizado.dart';
import 'package:olx/views/widget/input_costumizado.dart';
import 'package:validadores/Validador.dart';

class NovoAnuncio extends StatefulWidget {
  @override
  _NovoAnuncioState createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {
  final _formKey = GlobalKey<FormState>();
  BuildContext _dialogContext;

  Anuncio _anuncio;

  List<File> _listaImagens = [];
  List<DropdownMenuItem<String>> _listaItensDropEstados = List();
  List<DropdownMenuItem<String>> _listaItensDropCategorias = List();

  String _itemSelecionadoEstado;
  String _itemSelecionadoCategoria;

  void _selecionarImagemNaGaleria() async {
    File imagemSelecionada =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imagemSelecionada != null) {
      setState(() {
        _listaImagens.add(imagemSelecionada);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _anuncio = Anuncio.gerarId();
    _carregarItensDropDown();
  }

  _carregarItensDropDown() async {
    _listaItensDropEstados = Configuracoes.getEstados();

    _listaItensDropCategorias = Configuracoes.getCategorias();
  }

  void _salvarAnuncio() async {
    _abrirDialog(_dialogContext);
    //Upload das imagens no Storage
    await _uploadImagens();

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    String idUsuarioDoLogado = usuarioLogado.uid;

    //Salvar anuncio no Firestore
    Firestore db = Firestore.instance;
    db
        .collection('meus_anuncios')
        .document(idUsuarioDoLogado)
        .collection('anuncios')
        .document(_anuncio.id)
        .setData(_anuncio.toMap())
        .then((_) {
      db
          .collection('anuncios')
          .document(_anuncio.id)
          .setData(_anuncio.toMap())
          .then((_) {
        Navigator.pop(_dialogContext);

        Navigator.pop(context);
      });
    });
  }

  _abrirDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 20,
                ),
                Text('Salvando anuncio...'),
              ],
            ),
          );
        });
  }

  Future _uploadImagens() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();

    for (var imagem in _listaImagens) {
      print('imagem: $imagem');
      print('imagem path: ${imagem.path}');
      String nomeImage = DateTime.now().millisecondsSinceEpoch.toString();
      StorageReference arquivo =
          pastaRaiz.child('meus_anuncios').child(_anuncio.id).child(nomeImage);

      StorageUploadTask uploadTask = arquivo.putFile(imagem);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      _anuncio.fotos.add(url);

      print('URL: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo anuncio'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //area de imagens
                FormField<List>(
                  initialValue: _listaImagens,
                  validator: (imagens) {
                    if (imagens.length == 0) {
                      return 'Necessario selecionar uma imagem!';
                    }
                    return null;
                  },
                  builder: (state) {
                    return Column(
                      children: [
                        Container(
                          height: 100,
                          child: ListView.builder(
                            itemCount: _listaImagens.length + 1,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, indice) {
                              if (indice == _listaImagens.length) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      _selecionarImagemNaGaleria();
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey[400],
                                      radius: 50,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            'Adicionar',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                              if (_listaImagens.length > 0) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.file(_listaImagens[indice]),
                                              FlatButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _listaImagens
                                                        .removeAt(indice);
                                                    Navigator.of(context).pop();
                                                  });
                                                },
                                                child: Text('Excluir'),
                                                textColor: Colors.red,
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          FileImage(_listaImagens[indice]),
                                      child: Container(
                                        color:
                                            Color.fromRGBO(255, 255, 255, 0.4),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return Container();
                            },
                          ),
                        ),
                        if (state.hasError)
                          Container(
                            child: Text(
                              '[${state.errorText}]',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                //Menus Dropdown
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: DropdownButtonFormField(
                            onSaved: (estado) {
                              _anuncio.estado = estado;
                            },
                            validator: (valor) {
                              return Validador()
                                  .add(Validar.OBRIGATORIO,
                                      msg: 'Campo Obrigatorio')
                                  .valido(valor);
                            },
                            value: 'SP',
                            hint: Text(
                              'Estados',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                            items: _listaItensDropEstados,
                            onChanged: (value) {
                              print("Valor drop: $value");
                              setState(() {
                                _itemSelecionadoEstado = value;
                              });
                            }),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: DropdownButtonFormField(
                            onSaved: (categoria) {
                              _anuncio.categoria = categoria;
                            },
                            validator: (valor) {
                              return Validador()
                                  .add(Validar.OBRIGATORIO,
                                      msg: 'Campo Obrigatorio')
                                  .valido(valor);
                            },
                            hint: Text(
                              'Categorias',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                            items: _listaItensDropCategorias,
                            onChanged: (value) {
                              print("Valor drop: $value");
                              setState(() {
                                _itemSelecionadoCategoria = value;
                              });
                            }),
                      ),
                    ),
                  ],
                ),

                //Caixnas de textos e botoes
                Padding(
                  padding: EdgeInsets.only(bottom: 15, top: 15),
                  child: InputCustomizado(
                    controller: null,
                    onSaved: (titulo) {
                      _anuncio.titulo = titulo;
                    },
                    hint: 'Titulo',
                    validator: (valor) {
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: 'Campo Obrigatorio')
                          .valido(valor);
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    onSaved: (preco) {
                      _anuncio.preco = preco;
                    },
                    controller: null,
                    hint: 'Preco',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      RealInputFormatter(centavos: true),
                    ],
                    validator: (valor) {
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: 'Campo Obrigatorio')
                          .valido(valor);
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    onSaved: (telefone) {
                      _anuncio.telefone = telefone;
                    },
                    controller: null,
                    hint: 'Telefone',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TelefoneInputFormatter(),
                    ],
                    validator: (valor) {
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: 'Campo Obrigatorio')
                          .valido(valor);
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    onSaved: (descricao) {
                      _anuncio.descricao = descricao;
                    },
                    controller: null,
                    hint: 'Descricao',
                    maxLines: 5,
                    validator: (valor) {
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: 'Campo Obrigatorio')
                          .maxLength(200, msg: "Maximo de 200 caracteres")
                          .minLength(5, msg: 'Descricao min 5 caracteres')
                          .valido(valor);
                    },
                  ),
                ),

                BotaoCustomizado(
                  texto: 'Novo Anuncio',
                  onPressed: () {
                    _formKey.currentState.validate();

                    _dialogContext = context;

                    _formKey.currentState.save();

                    //Salvar Anuncio
                    _salvarAnuncio();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
