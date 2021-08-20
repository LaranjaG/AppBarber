import 'package:app_barbearia/controller/Agendamento.dart';
import 'package:app_barbearia/controller/Barbearia.dart';
import 'package:app_barbearia/controller/Corte.dart';
import 'package:app_barbearia/controller/Endereco.dart';
import 'package:app_barbearia/controller/Usuario.dart';
import 'package:app_barbearia/controller/cruds/selects/UsuarioFirebase.dart';
import 'package:app_barbearia/telas/ferramentas/Popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

class AgendamentosBarber extends StatefulWidget {
  @override
  _AgendamentosBarberState createState() => _AgendamentosBarberState();
}

class _AgendamentosBarberState extends State<AgendamentosBarber> {
   // ignore: deprecated_member_use
   List<Agendamento> _agendamentos = [];
   Map<String, dynamic> _barbearias = {};

  _recuperarAgendamentos() async {
     Usuario user = await UsuarioFirebase.getUsuarioLogado() as Usuario;
    // ignore: deprecated_member_use

     FirebaseFirestore dados = FirebaseFirestore.instance;

     await dados.collection("agendamentos")
     .where("idBarbeiro", isEqualTo: user.id)
      .where("status", isEqualTo: "pendente")
         .snapshots()
          .listen((snap) async {
       _agendamentos = [];
        _barbearias = {};
       for(DocumentSnapshot doc in snap.docs){
         Barbearia barber = Barbearia();
         Usuario usuarioCliente = Usuario();

         usuarioCliente.id = doc.data().toString(); //doc.data["idCliente"]
         Usuario usuarioFuncionario = Usuario();

         usuarioFuncionario.id = doc.data().toString(); //doc.data["idBarbeiro"]

        barber.id = doc.data().toString(); //doc.data["idBarbearia"]
         List cortes = doc.data().values; //doc.data["cortes"]
         _agendamentos.add( Agendamento());
         //     Agendamento.get(doc.id,
         //         DateTime.fromMicrosecondsSinceEpoch(doc.data().values.toString())//doc.data["horario"].microsecondsSinceEpoch),
         //         usuarioCliente, usuarioFuncionario, doc.data().values.toString() , //doc.data["status"]
         //         barber,
         //         doc.data().values, //doc.data["tempoTotal"]
         //         doc.data["valorTotal"].toDouble(),
         //         cortes)
         // );
       }

       for(int index = 0; index < _agendamentos.length; index++){
         print('\n\n??');
         Agendamento agendamento = _agendamentos[index] as Agendamento;

         String idBarber = agendamento.barbearia.id;
         print("ID" + idBarber);
         DocumentSnapshot snapBarber = await dados.collection("barbearias").doc(
             idBarber
         ).get();

         Barbearia barber = Barbearia();
         barber.id = idBarber;
         barber.nomeFantasia =  snapBarber.data()["nomeFantasia"]; //snapBarber.data["nomeFantasia"];
         barber.endereco = Endereco();
             // Endereco.barbearia(snapBarber.data["endereco"]["estado"], snapBarber.data["endereco"]["cidade"],
             // snapBarber.data["endereco"]["bairro"], snapBarber.data["endereco"]["rua"], snapBarber.data["endereco"]["numero"]);

         _barbearias[idBarber] = {
           // "contato" : snapBarber.data["contato"],
           // "nome" : snapBarber.data["nomeFantasia"],
           // "endereco" : snapBarber.data["endereco"],
         };

       }


       setState(() { //Muda o status
         // _agendamento = snap as Map;
         _agendamentos;
         _barbearias;
       });

    });

     // QuerySnapshot snap = await
     //     dados.collection("agendamentos")
     //      .where("idCliente", isEqualTo: user.id)
     //        .getDocuments();






  }

  @override
  void initState(){
    super.initState();
    _recuperarAgendamentos();
  }

  @override
  Widget build(BuildContext context) {
    /**
     * Uma lista que demonstra os agendamentos associados a um x usuário
      */
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                  itemCount: _agendamentos.length,
                  itemBuilder: (context, index){

                    final _dadosAgendamento = _agendamentos[index];
                    print(_agendamentos);

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
                                    child: Icon(Icons.calendar_today_outlined,
                                        color: ((_dadosAgendamento == "pendente") ? Colors.white :
                                        (_dadosAgendamento == "confirmado") ? Colors.green : Colors.red)
                                    ),
                                  ),
                                ),

                                Padding(
                                    padding: EdgeInsets.only(top: 0, bottom: 0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width - 83,
                                      child:
                                      ListTile(
                                        title:
                                        GestureDetector(child: Text(_barbearias[_dadosAgendamento.barbearia.id]["nome"], style:
                                        TextStyle(color: Colors.white),
                                        ), onTap: (){
                                          //Abrir para mais informações
                                          print('');
                                          },
                                        ),

                                        subtitle:
                                        (_dadosAgendamento.status == "pendente") ?
                                        Text(
                                              formatDate(_dadosAgendamento.horario, [HH, ':', nn, ' - ', dd, '/', mm, '/', yyyy]).toString()
                                              + "\nStatus: " + _dadosAgendamento.status.toString()
                                            ,
                                              style: TextStyle(color: Color.fromRGBO(250, 80, 0, 1)))
                                            : Text(
                                                  formatDate(_dadosAgendamento.horario, [HH, ':', nn, ' - ', dd, '/', mm, '/', yyyy]).toString()
                                                    + "\nStatus: " + _dadosAgendamento.status.toString(),
                                                  style: TextStyle(color: Colors.green)),

                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(padding: EdgeInsets.only(right: 10),
                                              child: GestureDetector(
                                                child: Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                ),
                                                onTap: (){
                                                  Popup.popupConfirmarAgendamento(context, _dadosAgendamento);
                                                },
                                              ),
                                            ),
                                            GestureDetector(
                                              child: Icon(
                                                Icons.cancel,
                                                color: Colors.red,
                                              ),
                                              onTap: (){
                                                Popup.popupCancelarAgendamento(context, _dadosAgendamento, false, nomeBarber:
                                                _barbearias[_dadosAgendamento.barbearia.id]["nome"]
                                                );
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
