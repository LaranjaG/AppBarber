import 'package:app_barbearia/controller/Usuario.dart';
import 'package:app_barbearia/controller/cruds/selects/UsuarioFirebase.dart';
import 'package:app_barbearia/telas/ferramentas/Decoration.dart';
import 'package:app_barbearia/telas/ferramentas/ValidacoesForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController controllerPopup = TextEditingController();
  TextEditingController controllerSenhaAtual = TextEditingController();

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

  Usuario _usuarioLogado = Usuario();
  bool _subindoImagem = false;

  Future _recuperarImgagem(String origemImagem) async {
    PickedFile imagemSelecionada;
    switch (origemImagem) {
      case "galeria":
        imagemSelecionada =
            await ImagePicker.platform.pickImage(source: ImageSource.gallery);
        _uploadImagem(imagemSelecionada);
        break;

      case "camera":
        imagemSelecionada =
            await ImagePicker.platform.pickImage(source: ImageSource.camera);
        _uploadImagem(imagemSelecionada);
        break;

      case "remove":
        _excluirImagem();
        // imagemSelecionada = PickedFile("");
        break;
    }

    Navigator.pop(context);
  }

  Future _excluirImagem() async {
    _usuarioLogado = await UsuarioFirebase.getUsuarioLogado() as Usuario;

    print("RODEI VIU?");

    Reference fotoRef =
        FirebaseStorage.instance.refFromURL(_usuarioLogado.foto);

    fotoRef.delete();

    _usuarioLogado.foto = null;

    _atualizarUsuario();
    setState(() {
      _usuarioLogado;
    });
  }

  Future _uploadImagem(PickedFile imagem) async {
    setState(() {
      _subindoImagem = true;
    });

    _usuarioLogado = await UsuarioFirebase.getUsuarioLogado() as Usuario;

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo =
        pastaRaiz.child("perfil").child("${_usuarioLogado.id}.jpg");

    UploadTask task = arquivo.putFile(File(imagem.path));

    task.then((snapshot) {
      setState(() {
        _usuarioLogado;
        _subindoImagem;
      });
      _subindoImagem = false;
      _pegarImagem(snapshot);
      // _usuarioLogado.foto = snap.ref;
    }).catchError((error) {
      print('ERRO');
      print(error);
    });
  }

  Future _pegarImagem(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    setState(() {
      _usuarioLogado.foto = url;
      _atualizarUsuario();
    });
  }

  Future _atualizarUsuario() {
    FirebaseFirestore bd = FirebaseFirestore.instance;

    FirebaseAuth auth = FirebaseAuth.instance;

    auth.currentUser.updateProfile(
      photoURL: _usuarioLogado.foto,
      displayName: _usuarioLogado.nome,
    );

    // bd.collection("usuarios").doc(_usuarioLogado.id).set({
    //   "contato": _usuarioLogado.contato,
    //   "tipoUsuario": _usuarioLogado.tipoUsuario,
    //   "endereco": _usuarioLogado.endereco.toMap(),
    // });
  }

  _userLog() async {
    _usuarioLogado = await UsuarioFirebase.getUsuarioLogado() as Usuario;

    setState(() {
      _usuarioLogado;
      _nome = _usuarioLogado.nome;
      _email = _usuarioLogado.email;
      _senha = _usuarioLogado.senha;
      _telefone = _usuarioLogado.contato;
      // _estado = _usuarioLogado.endereco.estado;
      // _cidade = _usuarioLogado.endereco.cidade;
    });
  }

  _popUp() {
    showCupertinoModalPopup(
      context: context,
      // barrierColor: Colors.grey[600],

      builder: (context) => CupertinoActionSheet(
          title: Container(
            padding: EdgeInsets.all(5),
            child: Text(
              "Foto de perfil",
              style: TextStyle(fontSize: 22, fontFamily: "Times"),
            ),
          ),
          message: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  FloatingActionButton(
                    onPressed: () => _recuperarImgagem("camera"),
                    backgroundColor: Colors.deepOrange[800],
                    child: Icon(Icons.camera, color: Colors.white),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      "Câmera",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontFamily: "Times"),
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  FloatingActionButton(
                    onPressed: () => _recuperarImgagem("galeria"),
                    backgroundColor: Colors.deepPurple[900],
                    child: Icon(Icons.photo, color: Colors.white),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      "Galeria",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontFamily: "Times"),
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  FloatingActionButton(
                    onPressed: () => _recuperarImgagem("remove"),
                    backgroundColor: Colors.pink[700],
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      "Deletar",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontFamily: "Times"),
                    ),
                  )
                ],
              ),
            ],
          )),
    );
  }

  TextInputType _tipoTeclado(String type) {
    switch (type) {
      case "Telefone":
        return TextInputType.phone;
      case "Email":
        return TextInputType.emailAddress;
      default:
        return TextInputType.text;
    }
  }

  _popUpEdit(String campo) {
    showCupertinoModalPopup(
      context: context,
      // barrierColor: Colors.grey[600],

      builder: (context) => CupertinoPageScaffold(
          backgroundColor: Colors.transparent,
          child: CupertinoActionSheet(
            title: Container(
              padding: EdgeInsets.all(5),
              child: Text(
                campo,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontFamily: "Times",
                ),
              ),
            ),
            message: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 7.5),
                  child: CupertinoTextField(
                    padding: EdgeInsets.all(5),
                    cursorColor: Colors.grey,
                    autofocus: true,
                    prefix: Container(
                      padding: EdgeInsets.only(left: 5),
                      child: Icon(Icons.edit),
                    ),
                    keyboardType: _tipoTeclado(campo),
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Times",
                      fontSize: 19,
                    ),
                    placeholder: campo == "Senha" ? "Nova ${campo}" : campo,
                    placeholderStyle: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                        fontFamily: "Times"),
                    // validator: (String nome) => Validar.validarEmail(nome),
                    // onSaved: (String valor) => _nome = valor,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    controller: controllerPopup,
                    obscureText: ((campo == "Senha") ? true : false),
                  ),
                ),
                (campo == "Email" || campo == "Senha")
                    ? CupertinoTextField(
                        prefix: Container(
                          padding: EdgeInsets.only(left: 5),
                          child: Icon(Icons.lock),
                        ),
                        cursorColor: Colors.grey,
                        keyboardType: _tipoTeclado(campo),
                        placeholder: "Senha atual",
                        padding: EdgeInsets.all(5),
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Times",
                          fontSize: 19,
                        ),
                        // validator: (String nome) => Validar.validarEmail(nome),
                        // onSaved: (String valor) => _nome = valor,
                        placeholderStyle: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                            fontFamily: "Times"),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                        controller: controllerSenhaAtual,
                        obscureText: true,
                      )
                    : Container(),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoActionSheetAction(
                      onPressed: () {
                        controllerSenhaAtual.text = "";
                        Navigator.pop(context);
                      },
                      child: Text("Cancelar")),
                  Container(
                    color: Colors.black45,
                    height: 40,
                    width: 2,
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  ),
                  // Divider(color: Colors.amber, height: 5),
                  CupertinoActionSheetAction(
                    child: Text("Salvar"),
                    onPressed: () => _salvarInput(campo),
                  )
                ],
              )
            ],
          )),
    );
  }

  _salvarInput(String campo) {
    switch (campo) {
      case "Nome":
        _usuarioLogado.nome = controllerPopup.text;
        setState(() {
          _nome = _usuarioLogado.nome;
        });
        break;
      case "Telefone":
        _usuarioLogado.contato = controllerPopup.text;
        setState(() {
          _telefone = _usuarioLogado.contato;
        });
        break;
      case "Estado":
        _usuarioLogado.endereco.estado = controllerPopup.text;
        setState(() {
          _estado = _usuarioLogado.endereco.estado;
        });
        break;
      case "Cidade":
        _usuarioLogado.endereco.cidade = controllerPopup.text;
        setState(() {
          _cidade = _usuarioLogado.endereco.cidade;
        });
        break;
      case "Email":
        FirebaseAuth auth = FirebaseAuth.instance;

        var user = auth.currentUser;

        print("TESTE\n\n\n\n\nTESTE:\n");
        print(user.emailVerified);
        print(user.photoURL);

        setState(() {
          if (user.photoURL != null) {
            _usuarioLogado.foto = user.photoURL;
          } else {
            // user.photoURL = _usuarioLogado.foto;
            user.updateProfile(photoURL: _usuarioLogado.foto);
          }
        });

        user.providerData.forEach((profile) {
          print("NOME: ${profile.displayName}");
          print("FOTO: ${profile.photoURL}");
        });

        auth
            .signInWithEmailAndPassword(
                email: _usuarioLogado.email,
                password: controllerSenhaAtual.text)
            .then((value) {
          setState(() {
            _usuarioLogado.email = controllerPopup.text;
            _email = _usuarioLogado.email;
            controllerSenhaAtual.text = "";
          });

          user
              .updateEmail(_email)
              .then((value) => _atualizarUsuario())
              .catchError(
                  (erro) => print("Deu errado viu: ${erro.toString()}"));
        }).catchError((erro) => print("Cara vc errou sua senha '-'"));

        // user
        //     .sendEmailVerification()
        //     .then((value) => print("Deu 300% certo"))
        //     .catchError((erro) => print(
        //         "Cara esse código não tá na sua ${erro}"));
        break;

      case "Senha":
        FirebaseAuth auth = FirebaseAuth.instance;
        _usuarioLogado.senha = controllerPopup.text;

        auth
            .signInWithEmailAndPassword(
                email: _usuarioLogado.email,
                password: controllerSenhaAtual.text)
            .then((value) {
          auth.currentUser
              .updatePassword(controllerPopup.text)
              .then((value) => print("Senha Alterada"))
              .catchError(
                  (erro) => print("Deu errado viu: ${erro.toString()}"));
        }).catchError(
                (erro) => print("Não foi possível mudar a senha! \n${erro}"));

        break;
      default:
        print("What?");
        break;
    }
    setState(() {
      _usuarioLogado;
      _atualizarUsuario();
    });

    Navigator.pop(context); //Fechar popup
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userLog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Configurações")),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 90,
                  backgroundImage: (_usuarioLogado.foto != null)
                      ? NetworkImage(_usuarioLogado.foto)
                      : null,
                  backgroundColor: Colors.grey,
                  child: Stack(
                    // alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      (_usuarioLogado.foto == null)
                          ? Center(
                              child: Text(
                                (_usuarioLogado.nome != null)
                                    ? _usuarioLogado.nome.substring(0, 1)
                                    : "",
                                style: TextStyle(
                                    fontSize: 45, color: Colors.white),
                              ),
                            )
                          : Center(
                              child: _subindoImagem
                                  ? CircularProgressIndicator()
                                  : Container(),
                            ),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: FloatingActionButton(
                            backgroundColor:
                                Color.fromRGBO(110, 160, 200, 0.75),
                            child: Icon(Icons.photo_camera),
                            onPressed: () => _popUp(),
                          ))
                    ],
                  ),
                ),
                Form(
                  key: _key,
                  // ignore: deprecated_member_use
                  autovalidate: _validate,
                  child: _form(),
                ),
              ],
            ),
          ),
        ),
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
                  readOnly: true,
                  style: TextStyle(color: Colors.white),
                  decoration: DecorationForm.inputNome(),
                  validator: (String nome) => Validar.validarEmail(nome),
                  onSaved: (String valor) => _nome = valor,
                  controller: TextEditingController(text: _nome),
                  onTap: () {
                    controllerPopup.text = _nome;
                    _popUpEdit("Nome");
                  },
                ),
              ),

              /**
               * Solicitação de mudança de email e senha deve, ficar em outro lugar
               */

              // Container(
              //   Input E-mail
              //   padding: EdgeInsets.only(bottom: 10),
              //   child: TextFormField(
              //     style: TextStyle(color: Colors.white),
              //     cursorColor: Colors.grey,
              //     decoration: DecorationForm.inputEmail(),
              //     keyboardType: TextInputType.emailAddress,
              //     validator: (String email) => Validar.validarEmail(email),
              //     onSaved: (String valor) => _email = valor,
              //     controller: TextEditingController(text: _email),
              //   ),
              // ),

              /**
               * A solicitação para mudança de senha vai ficar em outro lugar 
               */
              // Container(
              //  Input Senha
              //   padding: EdgeInsets.only(bottom: 10),
              //   child: TextFormField(
              //     obscureText: true, //Manter texto oculto
              //     style: TextStyle(color: Colors.white),
              //     cursorColor: Colors.grey,
              //     decoration: DecorationForm.inputSenha(),
              //     keyboardType: TextInputType.text,
              //     validator: (String senha) => Validar.validarSenha(senha),
              //     onSaved: (String valor) => _senha = valor,
              //     controller: TextEditingController(text: _senha)
              //   ),
              // ),

              /**
               *
               */

              Container(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: TextFormField(
                  readOnly: true,
                  keyboardType: TextInputType.phone,
                  cursorColor: Colors.grey,
                  style: TextStyle(color: Colors.white),
                  decoration: DecorationForm.inputTelefone(),
                  validator: (String telefone) =>
                      Validar.validarTelefone(telefone),
                  onSaved: (String valor) => _telefone = valor,
                  controller: TextEditingController(text: _telefone),
                  onTap: () {
                    controllerPopup.text = _telefone;
                    _popUpEdit("Telefone");
                  },
                ),
              ),

              Container(
                //Input estado
                padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: TextFormField(
                  readOnly: true,
                  keyboardType: TextInputType.text,
                  cursorColor: Colors.grey,
                  style: TextStyle(color: Colors.white),
                  decoration: DecorationForm.inputEstado(),
                  validator: (String estado) => null,
                  // Validar.validarTelefone(telefone),
                  onSaved: (String valor) => _estado = valor,
                  controller: TextEditingController(text: _estado),
                  onTap: () {
                    controllerPopup.text = _estado;
                    _popUpEdit("Estado");
                  },
                ),
              ),

              Container(
                //Input estado
                padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: TextFormField(
                  readOnly: true,
                  keyboardType: TextInputType.text,
                  cursorColor: Colors.grey,
                  style: TextStyle(color: Colors.white),
                  decoration: DecorationForm.inputCidade(),
                  validator: (String cidade) => null,
                  // Validar.validarTelefone(telefone),
                  onSaved: (String valor) => _cidade = valor,
                  controller: TextEditingController(text: _cidade),
                  onTap: () {
                    controllerPopup.text = _cidade;
                    _popUpEdit("Cidade");
                  },
                ),
              ),

              Container(
                //Input Email
                padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: TextFormField(
                  readOnly: true,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Colors.grey,
                  style: TextStyle(color: Colors.white),
                  decoration: DecorationForm.inputEmail(),
                  validator: (String email) => null,
                  // Validar.validarTelefone(telefone),
                  onSaved: (String valor) => _email = valor,
                  controller: TextEditingController(text: _email),
                  onTap: () {
                    controllerPopup.text = _email;
                    _popUpEdit("Email");
                  },
                ),
              ),

              Container(
                //Input Senha
                padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: TextFormField(
                  readOnly: true,
                  keyboardType: TextInputType.text,
                  cursorColor: Colors.grey,
                  style: TextStyle(color: Colors.white),
                  decoration: DecorationForm.inputSenha(),
                  validator: (String email) => null,
                  // Validar.validarTelefone(telefone),
                  onSaved: (String valor) => null,
                  controller: TextEditingController(text: ""),
                  onTap: () {
                    controllerPopup.text = "";
                    _popUpEdit("Senha");
                  },
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

              // DropdownButton<String>(
              //     items: _cidades.map((String dropDownStringItem) {
              //       return DropdownMenuItem<String>(
              //         value: dropDownStringItem,
              //         child: Text(dropDownStringItem),
              //       );
              //     }).toList(),
              //     onChanged: (String novoItemSelecionado) {
              //       _dropDownItemSelected(novoItemSelecionado);
              //       setState(() {
              //         this._itemSelecionado = novoItemSelecionado;
              //       });
              //     },
              //     value: _itemSelecionado),

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

              // if (_tipoUser)
              //   Padding(
              //     padding: EdgeInsets.fromLTRB(5, 0, 5, 15),
              //     child: TextField(
              //       onChanged: (value) {
              //         if (value.length > 2)
              //           _pesquisarBarbearia();
              //         else
              //           setState(() {
              //             listTitle = [];
              //             _idBarbearia = null;
              //           });
              //       },
              //       controller: _controllerBarbearia,
              //       keyboardType: TextInputType.text,
              //       style: TextStyle(fontSize: 20, color: Colors.white),
              //       decoration: InputDecoration(
              //           contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
              //           hintStyle: TextStyle(color: Colors.white),
              //           prefixIcon: Icon(Icons.search, color: Colors.white),
              //           labelText: "Barbearia",
              //           errorText: errorInput["barbearia"],
              //           labelStyle: TextStyle(color: Colors.white),
              //           fillColor: Colors.white,
              //           border: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(6))),
              //     ),
              //   ),

              // if(_tipoUser)
              // Popup.popup(context, titulo: Text("Nota", style: TextStyle(color: Colors.blueAccent)), container: "Pesquise e selecio!"),

              // Column(
              //   children: listTitle,
              // ),

              _usuarioLogado.tipoUsuario == "Barbeiro"
                  ? Container(
                      child: ElevatedButton(
                          onPressed: () {
                            print(
                                "Vai abrir em uma nova pagina para alterar a senha");
                          },
                          child: Text("Alterar")),
                    )
                  : Container(),
              // Container(
              //   padding: EdgeInsets.only(bottom: 20, top: 20),
              //   child: ElevatedButton(
              //     child: Text(
              //       "Salvar",
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 20,
              //       ),
              //     ),
              //     style: ElevatedButton.styleFrom(
              //         shadowColor: Colors.green[600],
              //         primary: Color(0xff123456),
              //         padding: EdgeInsets.fromLTRB(32, 16, 32, 16)),

              //     // color: Colors.blue,
              //     onPressed: () {
              //       bool validar = true;
              //       // if (_idBarbearia == null && _tipoUser) validar = false;

              //       // if (validar) {
              //       //   _validarCampos();
              //       // } else
              //       //   _mostrarErro("Barbearia não encontrada", "barbearia");
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
