import 'package:app_barbearia/controller/Barbearia.dart';
import 'package:app_barbearia/controller/Endereco.dart';
import 'package:app_barbearia/controller/Usuario.dart';
import 'package:app_barbearia/telas/barbeiro/PrincipalBarber.dart';
import 'package:app_barbearia/telas/cliente/DetalhesBarbearia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Barbearias extends StatefulWidget {
  @override
  _BarbeariasState createState() => _BarbeariasState();
}

class _BarbeariasState extends State<Barbearias> {
// ignore: deprecated_member_use
  List _barbers = [];

  _recuperarBarbearias() async {
    FirebaseFirestore dados = FirebaseFirestore.instance;

    QuerySnapshot snapshot = await dados.collection("barbearias").get();

    List<DocumentSnapshot> listCollection = snapshot.docs;
    // DocumentSnapshot tipoUser = dadosUser[0];

    for(DocumentSnapshot dados in listCollection){
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
            dados.data()['endereco']['numero']
          )
      ));
    }

    print("DADOS DO USUARIO");
    // print(tipoUser.id);

    // _barbers = snapshot.docs;

    setState(() {
      _barbers;
    });

    // ignore: deprecated_member_use
//     for(int i = 0; i < 5; i++){
//       Barbearia barber = Barbearia();
// //String nomeFantasia, String razaoSocial, PessoaFisica proprietario, DateTime dataCadastro, Endereco endereco, List<Contato> contatos
//       barber.nomeFantasia = 'Barbearia ${i}';
//       barber.descricao = 'Descricao ${i}';
//
//       auxiliar.add(barber);
//     }


      // _barbers = _buscarBarbearias();
      // print(_barbers[0].nomeFantasia);

    // auxiliar = null;
  }

  @override
  void initState(){
    super.initState();
    _recuperarBarbearias();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: new BoxDecoration(
      //   gradient: new LinearGradient(
      //   begin: Alignment.topLeft,
      //   end: Alignment.bottomRight,
      //   colors: [
      //       Color.fromARGB(0, 75, 75, 75),
      //       Color.fromARGB(255, 200, 200, 200)
      //     ],
      //   )
      // ),

      child: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                  itemCount: _barbers.length,
                  itemBuilder: (context, index){

                    final Barbearia dadosBarber = _barbers[index];

                    return Padding(
                        padding: EdgeInsets.only(bottom: 0, right: 7.5, left: 7.5, top: 4),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => DetalhesBarbearia(barbers: _barbers[index]))
                            );
                          },
                          child:
                          Card(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 60,
                                  height: 60,
                                  child: Padding(
                                    padding: EdgeInsets.all(1),
                                    child: Image(image: NetworkImage('https://cdn.pixabay.com/photo/2017/10/27/23/36/beard-2895837_960_720.png')),
                                  ),
                                ),

                                Padding(
                                    padding: EdgeInsets.only(top: 5, bottom: 5),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width - 83,
                                      child:
                                      ListTile(
                                        title: Text(dadosBarber.nomeFantasia),//Text((dadosBarber.data["nomeFantasia"] == null ? "" : dadosBarber.data["nomeFantasia"]), style: TextStyle(color: Colors.white),),
                                        subtitle: Text(dadosBarber.endereco.bairro),//Text('Bairro: ' + dadosBarber.data["endereco"]["bairro"]) ,
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.add_business_outlined,
                                              color: Colors.blue,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                )
                              ],
                            ),
                          ),
                        )
                    );
                  }
              )
          )
        ],
      ),
    );
  }
}
