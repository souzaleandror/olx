import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/views/widget/botao_customizado.dart';
import 'package:olx/views/widget/input_costumizado.dart';

import 'models/usuario.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool cadastrar = false;
  String msgError = '';
  String textoButton = 'Entrar';

  TextEditingController _controllerEmail =
      TextEditingController(text: 'mama@gmail.com');
  TextEditingController _controllerPassword =
      TextEditingController(text: '123123');

  _cadastrarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .createUserWithEmailAndPassword(
      email: usuario.email,
      password: usuario.senha,
    )
        .then((firebaseUser) {
      //redicionar para tela principal
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  _logarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .signInWithEmailAndPassword(
      email: usuario.email,
      password: usuario.senha,
    )
        .then((firebaseUser) {
      //redicionar para tela principal
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  _validarCampos() {
    String email = _controllerEmail.text;
    String pass = _controllerPassword.text;

    if (email.isNotEmpty && email.contains('@')) {
      if (pass.isNotEmpty && pass.length >= 6) {
        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = pass;

        if (cadastrar) {
          _cadastrarUsuario(usuario);
        } else {
          _logarUsuario(usuario);
        }
      } else {
        setState(() {
          msgError = 'Senha invalida';
        });
      }
    } else {
      setState(() {
        msgError = 'Email invalido';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    'imagens/logo.png',
                    width: 200,
                    height: 150,
                  ),
                ),
                InputCustomizado(
                  autoFocus: true,
                  controller: _controllerEmail,
                  hint: 'Email',
                  obscure: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                InputCustomizado(
                  autoFocus: false,
                  controller: _controllerPassword,
                  hint: 'Password',
                  maxLines: 1,
                  obscure: true,
                  keyboardType: TextInputType.text,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Logar'),
                    Switch(
                      value: cadastrar,
                      onChanged: (bool valor) {
                        setState(() {
                          cadastrar = valor;
                          if (cadastrar) {
                            textoButton = 'Cadastrar';
                          } else {
                            textoButton = 'Entrar';
                          }
                        });
                      },
                    ),
                    Text('Cadastrar'),
                  ],
                ),
                BotaoCustomizado(
                  texto: textoButton,
                  corTexto: Colors.white,
                  onPressed: _validarCampos,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    msgError,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
