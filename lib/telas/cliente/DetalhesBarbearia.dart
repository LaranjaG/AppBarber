import 'package:app_barbearia/controller/Barbearia.dart';
import 'package:app_barbearia/telas/cliente/FuncionariosAgendamento.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'CortesBarbearia.dart';
import 'IndexBarber.dart';

class DetalhesBarbearia extends StatefulWidget {
  DetalhesBarbearia({this.barbers});
  final Barbearia barbers;

  @override
  _DetalhesBarbeariaState createState() => _DetalhesBarbeariaState();
}

class _DetalhesBarbeariaState extends State<DetalhesBarbearia> {
  // List barbers = widget.barbers;
  int _currentIndex = 0;
  List<Widget> _children = [];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _children = [
      IndexBarber(barbearia: widget.barbers),
      CortesBarbearia(barbers: widget.barbers),
      FuncionarioAgendamento(barbearia: widget.barbers),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.barbers.nomeFantasia),
      ),
      body: _children[_currentIndex],
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
            icon: Icon(Icons.home),
            label: 'Menu',
          ),

          // new BottomNavigationBarItem(
          //   icon: new Icon(Icons.notifications),
          //   label: 'Notificações',
          // ),

          new BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Cortes',
          ),

          new BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agendar',
          ),
        ],
      ),
    );
  }
}
