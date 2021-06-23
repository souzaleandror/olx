import 'package:flutter/material.dart';
import 'package:olx/models/anuncio.dart';

class ItemAnuncio extends StatelessWidget {
  Anuncio anuncio;
  VoidCallback onTapItem;
  VoidCallback onPressedremover;

  ItemAnuncio({
    @required this.anuncio,
    this.onTapItem,
    this.onPressedremover,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapItem,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              //Imagem
              SizedBox(
                width: 120,
                height: 120,
                child: Image.network(
                  anuncio.fotos.first,
                  fit: BoxFit.cover,
                ),
              ),
              //Titulo e preco
              Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          anuncio.titulo,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'R\$ ${anuncio.preco}',
                          style: TextStyle(),
                        ),
                      ],
                    ),
                  )),
              if (onPressedremover != null)
                Expanded(
                  flex: 1,
                  child: FlatButton(
                    color: Colors.red,
                    padding: EdgeInsets.all(10),
                    onPressed: onPressedremover,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                ),
              //Botao Remover
            ],
          ),
        ),
      ),
    );
  }
}
