import 'package:app_barbearia/telas/ferramentas/Decoration.dart';
import 'package:flutter/material.dart';

class Validar{
  static String validarEmail(String email){
    String regex = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    if(email.isEmpty){
        return "Informe um e-mail!";
    }

    if(!(RegExp(regex).hasMatch(email))){
        return "Email inválido!";
    }
    return null;
  }

  static String validarTelefone(String telefone){
    String _emailRegex = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    if(telefone.isEmpty){
      return "Informe Telefone!";
    }

    if(!(RegExp(telefone).hasMatch(telefone))){
      return "Telefone inválido!";
    }
    return null;
  }

  static String validarNome(String nome){
    if(nome.isEmpty){
      return "Preencha o campo nome!";
    }

    return null;
  }

  static String validarSenha(String senha){
    if(senha.isEmpty){
      return "Preencha o campo senha!";
    }

    return null;
  }

}