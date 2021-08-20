import 'package:app_barbearia/controller/Usuario.dart';
import 'package:app_barbearia/controller/cruds/selects/UsuarioFirebase.dart';
import 'package:app_barbearia/telas/barbeiro/AgendamentosDia.dart';
import 'package:app_barbearia/telas/cliente/Agendamentos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_boom_menu/flutter_boom_menu.dart';
import 'AgendamentosBarber.dart';
import 'Calendario.dart';

class PrincipalBarber extends StatefulWidget {
  @override
  _PrincipalBarberState createState() => _PrincipalBarberState();
}

class _PrincipalBarberState extends State<PrincipalBarber> {
  ScrollController _scrollController;
  Usuario _usuario;
  bool _scrollVisible;
  Icon _icone;

  int _currentIndex = 0;
  final List<Widget> _children = [
    AgendamentosDia(),
    AgendamentosBarber(),
    Calendario()
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _pegarUser() async {
    _usuario = await UsuarioFirebase.getUsuarioLogado();

    setState(() {
      _usuario;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollVisible = true;
    _pegarUser();
    _icone = Icon(Icons.add);
    _scrollController = ScrollController()
      ..addListener(() {
        setDialVisible(_scrollController.position.userScrollDirection ==
            ScrollDirection.forward);
      });
  }

  void setDialVisible(bool value) {
    setState(() {
      _scrollVisible = value;
    });
  }

  Widget buildBody() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: 30,
      itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
    );
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
                  child: Text((_usuario != null) ? _usuario.nome : "")),
              accountEmail: Padding(
                  padding: EdgeInsets.all(5),
                  child: Text((_usuario != null) ? _usuario.email : "")),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors
                    .white, //(( Theme.of(context).platform == TargetPlatform.iOS) ? Colors.blue : Colors.white),
                backgroundImage: (_usuario.foto != null
                    ? NetworkImage(
                        "https://cdn.pixabay.com/photo/2017/10/06/08/03/beard-2822208_960_720.png")
                    : null),
                child: (_usuario.foto != null
                    ? Text(
                        "R",
                        style: TextStyle(fontSize: 40, color: Colors.black),
                      )
                    : null),
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
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => null));
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
      floatingActionButton: (_currentIndex == 0)
          ? BoomMenu(
              backgroundColor: Colors.deepOrange,
              // animatedIcon: AnimatedIcons.menu_close,
              animatedIconTheme: IconThemeData(size: 22.0),
              child: _icone,
              onOpen: () {
                setState(() {
                  _icone = Icon(Icons.close);
                });
              },
              onClose: () {
                setState(() {
                  _icone = Icon(Icons.add);
                });
              },
              scrollVisible: _scrollVisible,
              overlayColor: Colors.black,
              overlayOpacity: 0.8,
              title: "Titulo?",
              fabAlignment: Alignment.bottomRight,
              marginBottom: 5,
              titleColor: Colors.red,
              children: [
                  // Text("Test")
                  MenuItem(
                    //          child: Icon(Icons.accessibility, color: Colors.black, size: 40,),
                    title: "Adcionar serviço realizado",
                    titleColor: Colors.grey[850],
                    subtitle: "Adicionar novo corte feito",
                    subTitleColor: Colors.grey[850],
                    backgroundColor: Colors.grey[50],
                    elevation: 20,
                    child: Icon(Icons.room_service_outlined),
                    onTap: () => Navigator.pushNamed(context, "/AddServico"),
                  ),
                  //
                  MenuItem(
                    //          child: Icon(Icons.accessibility, color: Colors.black, size: 40,),
                    title: "Adicionar Agendamentos",
                    titleColor: Colors.white,
                    subtitle: "Adicionar novo agendamento",
                    subTitleColor: Colors.white,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.schedule, color: Colors.white),
                    onTap: () =>
                        Navigator.pushNamed(context, "/AddAgendamentoBarbeiro"),
                  )
                ])
          : null,
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
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
            icon: Icon(Icons.calendar_today),
            label: 'Dia',
          ),
          new BottomNavigationBarItem(
              icon: Icon(Icons.pending_actions), label: 'Pendentes'),
          new BottomNavigationBarItem(
              icon: Icon(Icons.table_view_sharp), label: 'Calendario'),
        ],
      ),
    );
  }
}
