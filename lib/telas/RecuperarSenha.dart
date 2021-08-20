import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'ferramentas/Decoration.dart';
import 'ferramentas/Popup.dart';
import 'ferramentas/ValidacoesForm.dart';

class RecuperarSenha extends StatefulWidget {
  @override
  _RecuperarSenhaState createState() => _RecuperarSenhaState();
}

class _RecuperarSenhaState extends State<RecuperarSenha> {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  TextEditingController _controllerEmail = TextEditingController();
  String _erroValidarInput = null;
  String _erroMensagem = "";
  String _email;

  _mostrarErro(String mensagem, String local){
    setState(() {
      if(local == 'input') _erroValidarInput = mensagem;
      else _erroMensagem = mensagem;
    });
  }


  _sendForm() {
    if (_key.currentState.validate()) {
      // Sem erros na validação
      _key.currentState.save();
      _solicitarSenha(_email);
    } else {
      // erro de validação
      setState(() {
        _validate = true;
      });
    }
  }

  Future<void> _solicitarSenha(String emailAddress){
    FirebaseAuth auth = FirebaseAuth.instance;

    auth.sendPasswordResetEmail(email: emailAddress)
        .then((value) {
          Popup.popup(
              context,
              titulo: Text("Enviado", style: TextStyle(color: Colors.blue)),
              container: "Um email com o link para recuperação de senha foi enviado neste endereço de email", tipo: "sair");
        }).catchError((onError){
          Popup.popup(
              context,
              titulo: Text("Erro", style: TextStyle(color: Colors.red)),
              container: "Não foi possível solicitar alteração de senha!");
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recuperar senha")
      ),

      body: Form(
        key: _key,
        autovalidate: _validate,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 35),
                    child: Text(
                        "Digite seu endereço de e-mail:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                           fontSize: 20, color:
                           Colors.white,),
                        ),
                  ),

                  Container( //Input E-mail
                    padding: EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      autofocus: true,
                      cursorColor: Colors.grey,
                      keyboardType: TextInputType.emailAddress,
                      decoration: DecorationForm.inputEmail(),
                      validator: (String email) => Validar.validarEmail(email),
                      onSaved: (String valor) => _email = valor,
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.only(bottom: 20, top: 20),
                    child: ElevatedButton(
                      onPressed: () => _sendForm(),
                      child: Text(
                        "Enviar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Color(0xff123456),
                          padding: EdgeInsets.fromLTRB(32, 16, 32, 16)
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Center(
                      child: Text(
                        _erroMensagem,
                        style: TextStyle(
                            color: Colors.red[800],
                            fontSize: 20
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
