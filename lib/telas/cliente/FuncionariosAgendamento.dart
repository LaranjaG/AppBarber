import 'package:app_barbearia/controller/Barbearia.dart';
import 'package:app_barbearia/controller/Endereco.dart';
import 'package:app_barbearia/controller/Usuario.dart';
import 'package:app_barbearia/telas/cliente/DetalhesBarbearia.dart';
import 'package:app_barbearia/telas/cliente/SolicitarAgendamento.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FuncionarioAgendamento extends StatefulWidget {
  FuncionarioAgendamento({this.barbearia});
  final barbearia;

  @override
  _FuncionarioAgendamentoState createState() => _FuncionarioAgendamentoState();
}

class _FuncionarioAgendamentoState extends State<FuncionarioAgendamento> {
// ignore: deprecated_member_use
  List _barbers = [];

  _recuperarBarbearias() async {
    FirebaseFirestore dados = FirebaseFirestore.instance;

    QuerySnapshot snapshot = await dados.collection("barbearias").get();

    List<DocumentSnapshot> listCollection = snapshot.docs;
    // DocumentSnapshot tipoUser = dadosUser[0];

    for (DocumentSnapshot dados in listCollection) {
      // Barbearia barber = Barbearia();
      Usuario user = Usuario();
      user.id = dados.data()['idResponsavel'];
      print("O q tem aqui?");
      print(dados.data());
      _barbers.add(Barbearia.get(
          dados.data()['nomeFantasia'],
          dados.data()['razaoSocial'],
          dados.data()['cnpj'],
          dados.data()['descricao'],
          user, //dados.data()['responsavel'] //id do responsavel
          //dados.data()['servicos'],
          dados.data()['id'],
          dados.data()['contato'],
          Endereco.barbearia(
              dados.data()['endereco']['estado'],
              dados.data()['endereco']['cidade'],
              dados.data()['endereco']['bairro'],
              dados.data()['endereco']['rua'],
              dados.data()['endereco']['numero'])));
    }

    print("DADOS DO USUARIO");
    // print(tipoUser.id);

    // _barbers = snapshot.docs;

    setState(() {
      _barbers;
    });
  }

  @override
  void initState() {
    super.initState();
    _recuperarBarbearias();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _barbers.length,
              itemBuilder: (context, index) {
                final Barbearia dadosBarber = _barbers[index];

                return Padding(
                  padding:
                      EdgeInsets.only(bottom: 0, right: 7.5, left: 7.5, top: 4),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalhesBarbearia(
                            barbers: _barbers[index],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.transparent,
                      shadowColor: Colors.transparent,
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 60,
                            height: 60,
                            child: Padding(
                              padding: EdgeInsets.all(1),
                              child: Icon(Icons.account_circle_rounded,
                                  size: 30, color: Colors.blue),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 0, bottom: 0),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 83,
                              child: ListTile(
                                title: GestureDetector(
                                  child: Text(
                                    dadosBarber.nomeFantasia,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () {
                                    //Abrir para mais informações
                                    print('');
                                  },
                                ),
                                subtitle: Text("Barbeiro",
                                    style: TextStyle(
                                        color: Color.fromRGBO(250, 80, 0, 1))),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(top: 9),
                                      child: GestureDetector(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_outlined,
                                              color: Colors.amber,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 1),
                                              child: Text("Agendar",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  SolicitarAgendamento(
                                                barbearia: dadosBarber,
                                                barbeiro: Usuario(),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
