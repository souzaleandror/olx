import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:olx/main.dart';
import 'package:olx/models/anuncio.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalhesAnuncio extends StatefulWidget {
  final Anuncio anuncio;

  DetalhesAnuncio(this.anuncio);

  @override
  _DetalhesAnuncioState createState() => _DetalhesAnuncioState();
}

class _DetalhesAnuncioState extends State<DetalhesAnuncio> {
  Anuncio _anuncio;

  @override
  void initState() {
    super.initState();

    _anuncio = widget.anuncio;
  }

  List<Widget> _getListaImagens() {
    List<String> listUrlImagens = _anuncio.fotos;

    return listUrlImagens.map((url) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.fitWidth,
          ),
        ),
      );
    }).toList();
  }

  _ligarTelefone(String telefone) async {
    if (await canLaunch('tel:$telefone')) {
      await launch('tel:$telefone');
    } else {
      print('Nao pode fazer a ligacao');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anuncio'),
      ),
      body: Stack(
        children: [
          //Conteudos
          ListView(
            children: [
              SizedBox(
                height: 250,
                child: Carousel(
                  images: _getListaImagens(),
                  dotSize: 8,
                  dotBgColor: Colors.transparent,
                  dotColor: Colors.white,
                  autoplay: false,
                  dotIncreasedColor: Colors.purple,
                  dotIncreaseSize: 2.0,
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'R\$ ${_anuncio.preco}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: temaPadrao.primaryColor,
                      ),
                    ),
                    Text(
                      '${_anuncio.titulo}',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      child: Divider(),
                    ),
                    Text(
                      'Descricao: ${_anuncio.descricao}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      child: Divider(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 66),
                      child: Text('R\$ ${_anuncio.telefone}'),
                    ),
                  ],
                ),
              )
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: GestureDetector(
              onTap: _ligarTelefone(_anuncio.telefone),
              child: Container(
                child: Text(
                  'Ligar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                padding: EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: temaPadrao.primaryColor,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          )
          //Botao ligar
        ],
      ),
    );
  }
}
