import 'package:app_barbearia/controller/Barbearia.dart';
import 'package:app_barbearia/controller/Usuario.dart';
import 'package:app_barbearia/controller/cruds/selects/UsuarioFirebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';

class CortesBarbearia extends StatefulWidget {
  CortesBarbearia({this.barbers});
  final Barbearia barbers;

  @override
  _CortesBarbeariaState createState() => _CortesBarbeariaState();
}

class _CortesBarbeariaState extends State<CortesBarbearia> {

  // ignore: deprecated_member_use
  List _agendamentos = [];
  Map<String, dynamic> _barbearias = {};

  _recuperarAgendamentos() async {
  Usuario user = await UsuarioFirebase.getUsuarioLogado() as Usuario;
  // ignore: deprecated_member_use

  FirebaseFirestore dados = FirebaseFirestore.instance;

  QuerySnapshot snap = await
  dados.collection("agendamentos")
      .where("idCliente", isEqualTo: user.id)
      .get();

  for(var item in widget.barbers.cortes){
  _agendamentos.add(
    {
    "nome" : item.nome,
    "descricao" : item.descricao,
    "preco" : item.preco,
    "tempo" : item.tempo
    }
    );
  }




  setState(() { //Muda o status
  // _agendamento = snap as Map;
  _agendamentos;
  });


  }

  @override
  void initState(){
  super.initState();
  _recuperarAgendamentos();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                  itemCount: _agendamentos.length,
                  itemBuilder: (context, index){

                    final _dadosAgendamento = _agendamentos[index];

                    return Padding(
                      padding: EdgeInsets.only(bottom: 0, right: 7.5, left: 7.5, top: 4),
                      child: Column(
                        children: [
                          Card(
                            color: Colors.transparent,
                            shadowColor: Colors.transparent,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 60,
                                  height: 60,
                                  child: Padding(
                                    padding: EdgeInsets.all(1),
                                    child: Icon(Icons.cut,
                                        color: Colors.red)
                                    ),
                                  ),

                                Padding(
                                    padding: EdgeInsets.only(top: 0, bottom: 0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width - 83,
                                      child:
                                      ListTile(
                                        title: GestureDetector(child: Text(_dadosAgendamento["nome"], style:
                                        TextStyle(color: Colors.white),
                                        ), onTap: (){
                                          //Abrir para mais informações
                                          print('');
                                        },
                                        ),

                                        subtitle: Text("R\$ " + _dadosAgendamento["preco"].toString() + "\n" + _dadosAgendamento["descricao"],
                                            style: TextStyle(color: Colors.orange[800])),

                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            GestureDetector(
                                              child: Icon(
                                                Icons.info,
                                                color: Colors.amber,
                                              ),
                                              onTap: (){
                                                Navigator.pushNamed(context, '/agendar');
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                )
                              ],
                            ),
                          ),

                          Divider(

                            color: Colors.white,
                          )
                        ] ,
                      ),
                    );

                  }
              )
          ),

        ],
      ),
    );
  }
}
