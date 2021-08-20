import 'file:///C:/Users/raysl/AndroidStudioProjects/app_barbearia/lib/telas/cadastro/CadastroUsuario.dart';
import 'package:app_barbearia/telas/CadastroGoogle.dart';
import 'package:app_barbearia/telas/Home.dart';
import 'package:app_barbearia/telas/RecuperarSenha.dart';
import 'package:app_barbearia/telas/barbeiro/AdicionarServico.dart';
import 'file:///C:/Users/raysl/AndroidStudioProjects/app_barbearia/lib/telas/Configuracoes.dart';
import 'package:app_barbearia/telas/barbeiro/FecharAgendamento.dart';
import 'package:app_barbearia/telas/barbeiro/NovoAgendamento.dart';
import 'package:app_barbearia/telas/barbeiro/PrincipalBarber.dart';
import 'package:app_barbearia/telas/cadastro/CadastroBarbearia.dart';
import 'package:app_barbearia/telas/cliente/PrincipalCliente.dart';
import 'package:flutter/material.dart';

class Rotas {
  static Route<dynamic> gerarRotas(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => Home());

      case "/cadastroUsuario":
        return MaterialPageRoute(builder: (_) => CadastroUsuario());

      case "/cadastroBarbearia":
        return MaterialPageRoute(builder: (_) => CadastroBarbearia());

      case "/principalBarbeiro":
        return MaterialPageRoute(builder: (_) => PrincipalBarber());

      case "/principalCliente":
        return MaterialPageRoute(builder: (_) => PrincipalCliente());

      case "/recuperarSenha":
        return MaterialPageRoute(builder: (_) => RecuperarSenha());

      case "/AddAgendamentoBarbeiro":
        return MaterialPageRoute(builder: (_) => NovoAgendamento());

      case "/AddServico":
        return MaterialPageRoute(builder: (_) => AdicionarServico());

      case "/Controle":
        return MaterialPageRoute(builder: (_) => FecharAgendamento());

      case "/Configuracoes":
        return MaterialPageRoute(builder: (_) => Configuracoes());

      case "/cadastroGoogle":
        return MaterialPageRoute(builder: (_) => CadastroGoogle());
      default:
        _erroRota();
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Erro: 404"),
        ),
        body: Center(
          child: Text(
            "Tela não encontrada!",
            style: TextStyle(color: Colors.red, fontSize: 25),
          ),
        ),
      );
    });
  }
}
