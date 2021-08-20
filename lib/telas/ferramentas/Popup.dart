import 'package:app_barbearia/controller/Agendamento.dart';
import 'package:app_barbearia/controller/Servico.dart';
import 'package:app_barbearia/controller/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:date_format/date_format.dart';

class Popup{
 static  popup(context, {Text titulo, String container, String tipo}){
   showDialog(
        barrierDismissible: false, //Impede que o popup feche se clicar em fora da caixa do conteudo
        context: context,
        builder: (context){
          return CupertinoAlertDialog(
            title: titulo,
            content: Text(container), //Fazer um list de actions depois e passar o titulo e o conteudo como parametro
            actions: [
              if((tipo == null || tipo == "mensagem") && tipo != "sair") //Se tipo mensagem aparece apensa o popup de fechar
                CupertinoDialogAction(child: Text("Fechar"), onPressed: () => Navigator.of(context).pop())
              else if(tipo != "sair")
                CupertinoDialogAction(child: Text("Cancelar"), onPressed: () => Navigator.of(context).pop()),
              if(tipo == "confirmar")
                CupertinoDialogAction(child: Text("Confirmar"), onPressed: () => Navigator.of(context).pop()),
              if(tipo == "sair")
                CupertinoDialogAction(child: Text("Ok", style: TextStyle(color: Colors.blue)), onPressed: () =>
                    Navigator.pushNamedAndRemoveUntil(context, "/",(_) => false)
                ),
            ],
          );
        }
    );
  }


  static popupCancelarAgendamento(context, Agendamento agendamento, bool cliente, {String nomeBarber}){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Cancelar", style: TextStyle(color: Colors.red)),
        content: Text(
            "Cancelar agendamento?"
          +"\n${nomeBarber}"
                +"\n horario: ${formatDate(agendamento.horario, [HH, ':', nn, ' - ', dd, '/', mm, '/', yyyy]).toString()}",
          textAlign: TextAlign.start,
        ),
        actions: [
          CupertinoDialogAction(child: Text("Fechar"), onPressed: () => Navigator.of(context).pop()),
          CupertinoDialogAction(child: Text("Confirmar"), onPressed: () {
            Navigator.of(context).pop();
            FirebaseFirestore dados = FirebaseFirestore.instance;

            if(cliente){
              agendamento.cliente.id = "";
            }


            agendamento.status = "cancelado";


                dados.collection("agendamentos").doc(
              agendamento.id
            ).set(
               agendamento.toMap()
                // {
                //   "idUsuario" : "",
                //   "idFuncionario" : agendamento.funcionario.id,
                //   "status" : "cancelaro",
                // }
            );
          })
        ],
      ),
    );
  }

 static popupConfirmarAgendamento(context, Agendamento agendamento){
   showDialog(
     barrierDismissible: false,
     context: context,
     builder: (context) => CupertinoAlertDialog(
       title: Text("Confirmar", style: TextStyle(color: Colors.green)),
       content: Text(
         "Confirmar agendamento?"
             +"\n horario: ${formatDate(agendamento.horario, [HH, ':', nn])}"
             +"\n Data: ${formatDate(agendamento.horario, [dd, '/', mm, '/', yyyy])}"
             +"\n Tempo: ${agendamento.tempoTotal} mins",
         textAlign: TextAlign.start,
       ),
       actions: [
         CupertinoDialogAction(child: Text("Fechar"), onPressed: () => Navigator.of(context).pop()),
         CupertinoDialogAction(child: Text("Confirmar"), onPressed: () {
           Navigator.of(context).pop();
           FirebaseFirestore dados = FirebaseFirestore.instance;

           agendamento.status = "confirmado";

           dados.collection("agendamentos").doc(
               agendamento.id
           ).set(
               agendamento.toMap()
             // {
             //   "idUsuario" : "",
             //   "idFuncionario" : agendamento.funcionario.id,
             //   "status" : "cancelaro",
             // }
           );
         })
       ],
     ),
   );
 }

 static formServico(context){
   TextEditingController _controllerNome = TextEditingController();
   Servico servico = null;
   showDialog<bool>(
     context: context,
     builder: (context) {
       return CupertinoAlertDialog(
         title: Text('Tambah baru'),
         content: Card(
           color: Colors.transparent,
           elevation: 0.0,
           child: Column(
             children: <Widget>[
               TextField(
                 decoration: InputDecoration(
                     labelText: "Nama",
                     filled: true,
                     fillColor: Colors.grey.shade50
                 ),
               ),
             ],
           ),
         ),
         actions: [
           CupertinoDialogAction(child: Text("Fechar"), onPressed: () => Navigator.of(context).pop()),
         ],
       );
     },
   );
  //return servico;
 }
}