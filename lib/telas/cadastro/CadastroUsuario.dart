import 'package:app_barbearia/controller/Endereco.dart';
import 'package:app_barbearia/controller/Usuario.dart';
import 'package:app_barbearia/telas/ferramentas/Decoration.dart';
import 'package:app_barbearia/telas/ferramentas/ValidacoesForm.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../ferramentas/Popup.dart';

class CadastroUsuario extends StatefulWidget {
  @override
  _CadastroUsuarioState createState() => _CadastroUsuarioState();
}

class _CadastroUsuarioState extends State<CadastroUsuario> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerLogin = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  TextEditingController _controllerTelefone = TextEditingController();
  TextEditingController _controllerEstado = TextEditingController();
  TextEditingController _controllerCidade = TextEditingController();
  TextEditingController _controllerBarbearia = TextEditingController();

  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  bool _tipoUser = false;
  String _nome;
  String _email;
  String _senha;
  String _telefone;
  String _estado;
  String _cidade;
  String _barbearia;

  String nomeCidade = "";
  var _cidades = ['Santos', 'Porto Alegre', 'Campinas', 'Rio de Janeiro'];
  var _itemSelecionado = 'Santos';

  String _emailRegex =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  List<Widget> listTitle = [];
  String _idBarbearia = null;
  // static Usuario _usuarioProprietario;

  void _dropDownItemSelected(String novoItem) {
    setState(() {
      this._itemSelecionado = novoItem;
    });
  }

  _pesquisarBarbearia() async {
    setState(() {
      listTitle = [];
      _idBarbearia = null;
    });

    FirebaseFirestore dados = await FirebaseFirestore.instance;

    String barber = _controllerBarbearia.text;

    QuerySnapshot querySnapshot = await dados
        .collection("barbearias")
        .where("nomeFantasia", isGreaterThanOrEqualTo: barber)
        .where("nomeFantasia", isLessThanOrEqualTo: barber + "\uf8ff")
        .get();

    for (DocumentSnapshot item in querySnapshot.docs) {
      listTitle.add(Padding(
        padding: EdgeInsets.all(5),
        child: GestureDetector(
          onTap: () {
            setState(() {
              listTitle = [];
              _idBarbearia = item.id;
              _controllerBarbearia.text = item.data()["nomeFantasia"];
            });
          },
          child: Text(item.data()["nomeFantasia"],
              style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ));
      setState(() {
        listTitle;
      });
    }
  }

  _cadastrarUser(Usuario usuario) async {
    // print(usuario.toMap());
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore dados = await FirebaseFirestore.instance;

    await auth
        .createUserWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaseUser) async {
      //Nome da coleção
      //
      firebaseUser.user.updateProfile(displayName: usuario.nome, photoURL: "");
     
      // PhoneAuthProvider number = PhoneAuthProvider();
      // firebaseUser.user.updatePhoneNumber(phoneCredential);
      await dados
          .collection("usuarios")
          .doc(//Cria um documento para a coleção Usuarios
              firebaseUser.user.uid //Pega o id do usuario para o documento
              )
          .set(//Mudar dados da documentação
              {
        "contato": usuario.contato,
        "tipoUsuario": usuario.tipoUsuario,
        "endereco": usuario.endereco.toMap()
      });

      switch (usuario.tipoUsuario) {
        case "Barbeiro":
          print("ID DA BARBEARIA" + _idBarbearia);
          if (_idBarbearia != null) {
            await dados.collection("funcionarios").add({
              "idBarbearia": _idBarbearia,
              "idBarbeiro": firebaseUser.user.uid
            });

            Navigator.pushNamedAndRemoveUntil(
                //Remove as rotas anteriores
                context,
                "/principalBarbeiro",
                (_) => false);
          } else
            _mostrarErro("Barbearia não possui cadastro", "barbearia");

          //Se for barbeiro, precisa achar a barbearia e colocar o nome dela
          // if(_proprietario) _usuarioProprietario = usuario;
          break;

        case "Cliente":
          Navigator.pushNamedAndRemoveUntil(
              context, "/principalCliente", (_) => false);
          break;
      }
    }).catchError((erro) {
      print(erro.runtimeType);
      print(erro);
      Popup.popup(context,
          titulo: Text("Erro", style: TextStyle(color: Colors.red)),
          container: "Erro ao fazer cadastro!");
    });
  }

  _inputValido(input) {
    setState(() {
      // errorInput[input] = null;
    });
  }

  _mostrarErro(mensagem, input) {
    setState(() {
      // errorInput[input] = mensagem;
    });
  }

  _validarCampos() {
    //Melhorara  logica de validar campos, adicionar pra validar campo a campo
    //Recuperar os dados
    String nome = _controllerNome.text;
    String login = _controllerLogin.text;
    String senha = _controllerSenha.text;
    String telefone = _controllerTelefone.text;
    String estado = _controllerEstado.text;
    String cidade = _controllerCidade.text;
    Endereco endereco;

    if (estado.isNotEmpty) {
      _inputValido("estado");
      if (cidade.isNotEmpty) {
        _inputValido("cidade");
        endereco = Endereco.usuario(estado, cidade);
      } else
        _mostrarErro("Campo nome inválido!", "cidade");
    } else
      _mostrarErro("Campo nome inválido!", "estado");

    if (nome.isNotEmpty) {
      _inputValido("nome");
      if (login.isNotEmpty && RegExp(_emailRegex).hasMatch(login)) {
        _inputValido("login");
        if (senha.isNotEmpty && senha.length > 6) {
          _inputValido("senha");
          if (telefone.isNotEmpty) {
            _inputValido("telefone");
            if (endereco != null) {
              _cadastrarUser(
                  //this._nome, this._email, this._senha, this._tipoUsuario, String contato, Endereco endereco
                  Usuario.create(nome, login, senha,
                      Usuario.verificaTipoUser(_tipoUser), telefone, endereco));
            }
          } else
            _mostrarErro("Campo telefone inválido!", "telefone");
        } else
          _mostrarErro("Campo senha inválido! Tamaho minimo de 7!", "senha");
      } else
        _mostrarErro("Campo email inválido!", "login");
    } else
      _mostrarErro("Campo nome inválido!", "nome");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro Usuário"),
      ),
      body: Form(
        key: _key,
        // ignore: deprecated_member_use
        autovalidate: _validate,
        child: _form(),
      ),
    );
  }

  Widget _form() {
    return Container(
      color: Colors.grey[800],
      padding: EdgeInsets.all(20),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                //Input nome
                padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: TextFormField(
                  cursorColor: Colors.grey,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(color: Colors.white),
                  decoration: DecorationForm.inputNome(),
                  validator: (String nome) => Validar.validarEmail(nome),
                  onSaved: (String valor) => _nome = valor,
                ),
              ),

              Container(
                //Input E-mail
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.grey,
                  decoration: DecorationForm.inputEmail(),
                  keyboardType: TextInputType.emailAddress,
                  validator: (String email) => Validar.validarEmail(email),
                  onSaved: (String valor) => _email = valor,
                ),
              ),

              Container(
                //Input Senha
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  obscureText: true, //Manter texto oculto
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.grey,
                  decoration: DecorationForm.inputSenha(),
                  keyboardType: TextInputType.text,
                  validator: (String senha) => Validar.validarSenha(senha),
                  onSaved: (String valor) => _senha = valor,
                ),
              ),

              /**
               *
               */

              Divider(
                color: Colors.white,
                height: 20,
              ),

              Container(
                //Input Senha
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  obscureText: true, //Manter texto oculto
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.grey,
                  decoration: DecorationForm.inputSenha(),
                  keyboardType: TextInputType.text,
                  validator: (String senha) => Validar.validarSenha(senha),
                  onSaved: (String valor) => _senha = valor,
                ),
              ),

              Container(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  cursorColor: Colors.grey,
                  style: TextStyle(color: Colors.white),
                  decoration: DecorationForm.inputTelefone(),
                  validator: (String telefone) =>
                      Validar.validarTelefone(telefone),
                  onSaved: (String valor) => _telefone = valor,
                ),
              ),

              Container(
                //Input estado
                padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  cursorColor: Colors.grey,
                  style: TextStyle(color: Colors.white),
                  decoration: DecorationForm.inputEstado(),
                  validator: (String telefone) =>
                      Validar.validarTelefone(telefone),
                  onSaved: (String valor) => _telefone = valor,
                ),
              ),

              /**
               * Fazer um select para pegar cidade e estado
               */

              // Padding(
              //   padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
              //   child: TextField(
              //     controller: _controllerEstado,
              //     keyboardType: TextInputType.text,
              //     style: TextStyle(
              //         fontSize: 20,
              //         color: Colors.white
              //     ),
              //     decoration: ,
              //   ),
              // ),

              DropdownButton<String>(
                  items: _cidades.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  onChanged: (String novoItemSelecionado) {
                    _dropDownItemSelected(novoItemSelecionado);
                    setState(() {
                      this._itemSelecionado = novoItemSelecionado;
                    });
                  },
                  value: _itemSelecionado),

              // Padding(
              //   padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
              //   child: TextField(
              //     controller: _controllerCidade,
              //     keyboardType: TextInputType.text,
              //     style: TextStyle(
              //         fontSize: 20,
              //         color: Colors.white
              //     ),
              //     decoration: InputDecoration(
              //         contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
              //         hintStyle: TextStyle(color: Colors.white),
              //         prefixIcon: Icon(Icons.location_city, color: Colors.white),
              //         errorText: errorInput["cidade"],
              //         labelText: "Cidade",
              //         labelStyle: TextStyle(color: Colors.white),
              //         fillColor: Colors.white,
              //         border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(6)
              //         )
              //     ),
              //   ),
              // ),

              Divider(
                color: Colors.white,
                height: 20,
              ),
              /**
               *
               */
              //Button cliente ou barbeiro
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Cliente", style: TextStyle(color: Colors.white)),
                    Switch(
                      value:
                          _tipoUser, //Se for false, é cliente, se verdadeiro é Barbeiro/Funcionario
                      onChanged: (bool valor) {
                        setState(() {
                          _tipoUser = valor;
                        });
                      },
                    ),
                    Text("Barbeiro", style: TextStyle(color: Colors.white))
                  ],
                ),
              ),

              if (_tipoUser)
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 15),
                  child: TextField(
                    onChanged: (value) {
                      if (value.length > 2)
                        _pesquisarBarbearia();
                      else
                        setState(() {
                          listTitle = [];
                          _idBarbearia = null;
                        });
                    },
                    controller: _controllerBarbearia,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        labelText: "Barbearia",
                        // errorText: errorInput["barbearia"],
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6))),
                  ),
                ),

              // if(_tipoUser)
              // Popup.popup(context, titulo: Text("Nota", style: TextStyle(color: Colors.blueAccent)), container: "Pesquise e selecio!"),

              Column(
                children: listTitle,
              ),

              Divider(
                color: Colors.white,
                height: 20,
              ),

              Padding(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/cadastroBarbearia");
                    },
                    child: Text(
                      "É proprietario? Click aqui para cadastrar sua Barbearia!",
                      style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(bottom: 20, top: 20),
                child: ElevatedButton(
                  child: Text(
                    "Cadastrar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Color(0xff123456),
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16)),

                  // color: Colors.blue,
                  onPressed: () {
                    bool validar = true;
                    if (_idBarbearia == null && _tipoUser) validar = false;

                    if (validar) {
                      _validarCampos();
                    } else
                      _mostrarErro("Barbearia não encontrada", "barbearia");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
