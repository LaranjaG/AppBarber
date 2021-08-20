import 'package:app_barbearia/controller/Usuario.dart';
import 'package:app_barbearia/controller/cruds/selects/UsuarioFirebase.dart';
import 'package:app_barbearia/telas/ferramentas/Loadins.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'ferramentas/Decoration.dart';
import 'ferramentas/ValidacoesForm.dart'; //Importe para pesquisa
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _mensagemErro = "";
  bool _loading;
  bool _carregando;
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String _email, _senha;

  _carregar(bool valor) {
    setState(() {
      _carregando = valor;
    });
  }

  _mostrarErro(mensagem) {
    setState(() {
      _mensagemErro = mensagem;
    });
  }

  _sendForm() {
    if (_key.currentState.validate()) {
      // Sem erros na validação
      _key.currentState.save();

      UsuarioFirebase.logarUsuario(Usuario.logar(_email, _senha), context);
    } else {
      // erro de validação
      setState(() {
        _validate = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loading = false;
    UsuarioFirebase.verificarLogin(context);
    _carregando = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _key,
        // ignore: deprecated_member_use
        autovalidate: _validate,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: _loading ? Loadins.circulo() : _form(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          //Imagem logo
          padding: EdgeInsets.only(bottom: 32),
          child: Image.network(
            "https://cdn.pixabay.com/photo/2018/03/26/18/20/man-3263509__340.png",
            height: 180,
            color: Color(0xff123456),
          ),
        ),
        Container(
          //Input E-mail
          padding: EdgeInsets.only(bottom: 10),
          child: TextFormField(
            style: TextStyle(color: Colors.white),
            autofocus: false,
            cursorColor: Colors.grey,
            decoration: DecorationForm.inputEmail(),
            keyboardType: TextInputType.emailAddress,
            validator: (String email) => Validar.validarEmail(email),
            onSaved: (String valor) => _email = valor,
          ),
        ),
        Container(
          //Input senha
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: TextFormField(
            style: TextStyle(color: Colors.white),
            obscureText: true,
            keyboardType: TextInputType.text,
            cursorColor: Colors.grey,
            decoration: DecorationForm.inputSenha(),
            onSaved: (String valor) => _senha = valor,
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 5, top: 10),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "/recuperarSenha");
            },
            child: Text(
              "Esqueci minha senha",
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 5),
          child: Center(
            child: Text(
              _mensagemErro,
              style: TextStyle(color: Colors.red[800], fontSize: 20),
            ),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _sendForm(),
          child: Text('Entrar'),
          style: ElevatedButton.styleFrom(
              primary: Color(0xff123456),
              padding: EdgeInsets.fromLTRB(32, 16, 32, 16)),
        ),
        Container(
          padding: EdgeInsets.only(top: 35),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "/cadastroUsuario");
            },
            child: Text(
              "Não tem conta? Cadastre-se!",
              style: TextStyle(
                  color: Colors.white, decoration: TextDecoration.underline),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 40, left: 70, right: 70),
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                UsuarioFirebase.logarComGoogle(context)
                    .then((value) => print("Deu"))
                    .catchError(
                        (onError) => print("onError: " + onError.toString()));
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // background
                onPrimary: Colors.white, // foreground
              ),
              child: Container(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                        padding: EdgeInsets.all(0),
                        child: Icon(FontAwesomeIcons.google)),
                    Padding(
                        padding: EdgeInsets.all(0),
                        child: Text("Login com google")),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 0, left: 70, right: 70),
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                UsuarioFirebase.loginFacebook(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // background
                onPrimary: Colors.white, // foreground
              ),
              child: Container(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                        padding: EdgeInsets.all(0),
                        child: Icon(FontAwesomeIcons.facebook)),
                    Padding(
                        padding: EdgeInsets.all(0),
                        child: Text("Login com facebook")),
                  ],
                ),
              ),
            ),
          ),
        ),
        _carregando
            ? Container(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.grey,
                  ),
                ))
            : Container(),
        Container(
          padding: EdgeInsets.only(top: 32),
          child: Center(
            child: Text(
              _mensagemErro,
              style: TextStyle(color: Colors.red[800], fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }
}
