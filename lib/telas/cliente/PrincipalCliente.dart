import 'package:app_barbearia/controller/Usuario.dart';
import 'package:app_barbearia/controller/cruds/selects/UsuarioFirebase.dart';
import 'package:app_barbearia/telas/cliente/Agendamentos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Barbearias.dart';

class PrincipalCliente extends StatefulWidget {
  @override
  _PrincipalClienteState createState() => _PrincipalClienteState();
}

class _PrincipalClienteState extends State<PrincipalCliente> {
  Usuario _usuario = Usuario();

  void _pegarUser() async {
    _usuario = await UsuarioFirebase.getUsuarioLogado() as Usuario;
    setState(() {
      _usuario;
    });
  }

  // _logout() async {
  //   FirebaseAuth auth = FirebaseAuth.instance;

  //   await auth.signOut();
  //   Navigator.pushReplacementNamed(context, "/");
  // }

  int _currentIndex = 0;
  final List<Widget> _children = [Barbearias(), Agendamentos()];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pegarUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              //decoration: BoxDecoration(color: Colors.red),
              accountName: Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text((_usuario.nome != null) ? _usuario.nome : "")),
              accountEmail: Padding(
                  padding: EdgeInsets.all(5),
                  child: Text((_usuario.email != null) ? _usuario.email : "")),
              currentAccountPicture: CircleAvatar(
                radius: 90,
                backgroundImage:
                    _usuario.foto != null ? NetworkImage(_usuario.foto) : null,
                backgroundColor: Colors
                    .white, //(( Theme.of(context).platform == TargetPlatform.iOS) ? Colors.blue : Colors.white),
                child: _usuario.foto == null
                    ? Text(
                        _usuario.nome != null
                            ? "${_usuario.nome.substring(0, 1)}"
                            : "",
                        style: TextStyle(fontSize: 40, color: Colors.black),
                      )
                    : null,
              ),
            ),
            ListTile(
              //hoverColor: Colors.black,
              title: Text(
                "Configurações",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, "/Configuracoes");
              },
            ),
            ListTile(
              //hoverColor: Colors.black,
              title: Text("Sair", style: TextStyle(color: Colors.white)),
              onTap: () => UsuarioFirebase.logout(context),
            )
          ],
        ),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex:
            _currentIndex, // this will be set when a new tab is tapped
        fixedColor: Colors.red,
        unselectedItemColor: Colors.white, //Cor das letras n selecionadas

        //selectedIconTheme: IconTheme(data: null, child: null),
        type: BottomNavigationBarType.fixed,
        iconSize: 20,

        selectedIconTheme: IconThemeData(color: Colors.red),

        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Menu',
          ),
          new BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Agendamentos'),
        ],
      ),
    );
  }
}
