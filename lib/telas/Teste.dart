import 'package:app_barbearia/controller/Usuario.dart';
import 'package:app_barbearia/controller/cruds/selects/UsuarioFirebase.dart';
import 'package:app_barbearia/telas/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class Teste extends StatefulWidget {
  final Usuario user;

  Teste(@required this.user, {Key key}) : super(key: key);

  @override
  _TesteState createState() => _TesteState();
}

class _TesteState extends State<Teste> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: [
              Image.network(widget.user.foto),
              Text(widget.user.nome),
              ElevatedButton(onPressed: () => UsuarioFirebase.logout(context), child: Text("Sair"))
            ],
          ),
        ),
      ),
    );
  }
}
