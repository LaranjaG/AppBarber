import 'package:app_barbearia/controller/Barbearia.dart';
import 'package:app_barbearia/controller/Endereco.dart';
import 'package:app_barbearia/controller/Usuario.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import '../ferramentas/Popup.dart';

class CadastroBarbearia extends StatefulWidget {
  @override

  _CadastroBarbeariaState createState() => _CadastroBarbeariaState();
}

class _CadastroBarbeariaState extends State<CadastroBarbearia> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerLogin = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  TextEditingController _controllerTelefone = TextEditingController();
  TextEditingController _controllerNomeFantasia = TextEditingController();
  TextEditingController _controllerRazaoSocial = TextEditingController();
  TextEditingController _controllerCnpj = TextEditingController();
  TextEditingController _controllerTelefoneBarbearia = TextEditingController();
  TextEditingController _controllerEstado = TextEditingController();
  TextEditingController _controllerCidade = TextEditingController();
  TextEditingController _controllerBairro = TextEditingController();
  TextEditingController _controllerRua = TextEditingController();
  TextEditingController _controllerNumero = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();

  String _emailRegex = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';


  Map<String, dynamic> errorInput = {
    "nome" : null,
    "email" : null,
    "senha" : null,
    "telefone" : null,
    "nomeFantasia" : null,
    "razaoSocial" : null,
    "telefoneBarbearia" : null,
    "descricao" : null,
    "cnpj" : null,
    "estado" : null,
    "cidade" : null,
    "bairro" : null,
    "rua" : null,
    "numero" : null
  };

  // static Usuario _usuarioProprietario;


  _cadastrar(Usuario usuario, Barbearia barbaearia) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore dados = await FirebaseFirestore.instance;

    await auth.createUserWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha
    ).then((firebaseUser) async {
      //Nome da coleção
      dados.collection("usuarios").doc( //Cria um documento para a coleção Usuarios
          firebaseUser.user.uid //Pega o id do usuario para o documento
      ).set( //Mudar dados da documentação
          usuario.toMap()
      );

      //Retorna a referencia criada
      DocumentReference ref = await dados.collection("barbearias").add(
          barbaearia.toMap()
      );

      Navigator.pushNamedAndRemoveUntil( //Remove as rotas anteriores
        context, "/principalBarbeiro", (_) => false
      );


    }).catchError((erro){
      print(erro.runtimeType);
      print(erro);
      Popup.popup(context, titulo: Text("Erro", style: TextStyle(color: Colors.red)), container: "Email inválido ou já possui cadastro!");
    });

  }

  _inputValido(input){
    setState(() {
      errorInput[input] = null;
    });
  }

  _mostrarErro(mensagem, input){
    setState(() {
      errorInput[input] = mensagem;
    });
  }


  _validarCampos(){ //Melhorara  logica de validar campos, adicionar pra validar campo a campo
    //Recuperar os dados
    String nome = _controllerNome.text;
    String login = _controllerLogin.text;
    String senha = _controllerSenha.text;
    String telefone = _controllerTelefone.text;
    String estado = _controllerEstado.text;
    String cidade = _controllerCidade.text;
    Endereco enderecoUser;
    Endereco enderecoBarbearia;
    String nomeFantasia = _controllerNomeFantasia.text;
    String razaoSocial = _controllerRazaoSocial.text;
    String telefoneBarbearia = _controllerTelefoneBarbearia.text;
    String cnpj = _controllerCnpj.text;
    String bairro = _controllerBairro.text;
    String rua = _controllerRua.text;
    String numero = _controllerNumero.text;
    String descricao = _controllerDescricao.text;

    enderecoUser = Endereco.usuario(estado, cidade);
    enderecoBarbearia = Endereco.barbearia(estado, cidade, bairro, rua, numero);
    if(estado.isNotEmpty){
      _inputValido("estado");
      if(cidade.isNotEmpty){
        _inputValido("cidade");

      } else _mostrarErro("Campo nome inválido!", "cidade");
    } else _mostrarErro("Campo nome inválido!", "estado");

    if(nome.isNotEmpty){
      _inputValido("nome");
      if(login.isNotEmpty && RegExp(_emailRegex).hasMatch(login)){
        _inputValido("login");
        if(senha.isNotEmpty && senha.length > 6){
          _inputValido("senha");
          if(telefone.isNotEmpty){
            _inputValido("telefone");
            if(enderecoUser != null)
              _cadastrar(
                  Usuario.create(nome, login, senha, "ProprietarioBarber", telefone, enderecoUser),
                  Barbearia.create(nomeFantasia, razaoSocial, cnpj, descricao,
                      Usuario.create(nome, login, senha, "ProprietarioBarber", telefone, enderecoUser),
                      telefoneBarbearia, enderecoBarbearia)
              );
          } else _mostrarErro("Campo telefone inválido!", "telefone");
        } else _mostrarErro("Campo senha inválido! Tamaho minimo de 7!", "senha");
      }else _mostrarErro("Campo email inválido!", "login");
    }else _mostrarErro("Campo nome inválido!", "nome");
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
      ),
      body: Container(
        color: Colors.grey[800],
        padding: EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: TextField(
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(35, 16, 0, 20),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.person, color: Colors.white),
                        errorText: errorInput["nome"],
                        labelText: "Nome",
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)
                        )
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: TextField(
                    controller: _controllerLogin,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(35, 16, 0, 20),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.email, color: Colors.white),
                        errorText: errorInput["email"],
                        labelText: "E-mail",
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)
                        )
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: TextField(
                    controller: _controllerSenha,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(35, 16, 0, 20),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
                        errorText: errorInput["senha"],
                        labelText: "Senha",
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)
                        )
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: TextField(
                    controller: _controllerTelefone,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.phone, color: Colors.white),
                        errorText: errorInput["telefone"],
                        labelText: "Telefone",
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)
                        )
                    ),
                  ),
                ),

                /**
                 *
                 */

                Divider(
                  color: Colors.white,
                  height: 20,
                ),
                /**
                 *
                 */

                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: TextField(
                    controller: _controllerNomeFantasia,
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.add_business, color: Colors.white),
                        errorText: errorInput["nomeFantasia"],
                        labelText: "Nome Fantasia",
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)
                        )
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: TextField(
                    controller: _controllerRazaoSocial,
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.add_business, color: Colors.white),
                        errorText: errorInput["razaoSocial"],
                        labelText: "Razão Social",
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)
                        )
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: TextField(
                    controller: _controllerCnpj,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.add_business, color: Colors.white),
                        errorText: errorInput["cnpj"],
                        labelText: "CNPJ",
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)
                        )
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: TextField(
                    controller: _controllerTelefoneBarbearia,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.contact_phone, color: Colors.white),
                        errorText: errorInput["telefoneBarbearia"],
                        labelText: "Telefone barbearia",
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)
                        )
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: TextField(
                    maxLines: null,
                    controller: _controllerDescricao,
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.note, color: Colors.white),
                        errorText: errorInput["descricao"],
                        labelText: "Descrição",
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)
                        )
                    ),
                  ),
                ),

                Divider(
                  color: Colors.white,
                  height: 20,
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: TextField(
                    controller: _controllerEstado,
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.location_city_sharp, color: Colors.white),
                        errorText: errorInput["estado"],
                        labelText: "Estado",
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)
                        )
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: TextField(
                    controller: _controllerCidade,
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.location_city, color: Colors.white),
                        errorText: errorInput["cidade"],
                        labelText: "Cidade",
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)
                        )
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: TextField(
                    controller: _controllerBairro,
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.streetview, color: Colors.white),
                        errorText: errorInput["bairro"],
                        labelText: "Bairro",
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)
                        )
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: TextField(
                    controller: _controllerRua,
                    keyboardType: TextInputType.streetAddress,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.streetview, color: Colors.white),
                        errorText: errorInput["rua"],
                        labelText: "Rua",
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)
                        )
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: TextField(
                    controller: _controllerNumero,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.home, color: Colors.white),
                        errorText: errorInput["numero"],
                        labelText: "Número",
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)
                        )
                    ),
                  ),
                ),

                Padding(padding: EdgeInsets.only(
                    bottom: 20, top: 20),
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
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16)
                    ),

                    // color: Colors.blue,
                    onPressed: () => _validarCampos(),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
