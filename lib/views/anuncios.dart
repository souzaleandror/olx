import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Anuncios extends StatefulWidget {
  @override
  _AnunciosState createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {
  List<String> itensMenu = [];

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verificarUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Text(
          'Anuncios',
        ),
      ),
    );
  }
}