import 'package:flutter/material.dart';

class DecorationForm {
  static InputDecoration inputEmail() {
    return InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
      //hintText: "email@dominio.com",
      hintStyle: TextStyle(color: Colors.white),
      prefixIcon: Icon(Icons.email, color: Colors.white),
      labelText: "E-mail",
      labelStyle: TextStyle(color: Colors.white),
      fillColor: Colors.white,
    );
  }

  static InputDecoration inputSenha() {
    return InputDecoration(
      prefixIcon: Icon(Icons.lock, color: Colors.white),
      labelText: "Senha",
    );
  }

  static InputDecoration inputNome() {
    return InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(35, 16, 0, 20),
      hintStyle: TextStyle(color: Colors.white),
      prefixIcon: Icon(Icons.person, color: Colors.white),
      labelText: "Nome",
      labelStyle: TextStyle(color: Colors.white),
      fillColor: Colors.white,
    );
  }

  static InputDecoration inputTelefone() {
    return InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
      hintStyle: TextStyle(color: Colors.white),
      prefixIcon: Icon(Icons.phone, color: Colors.white),
      labelText: "Telefone",
      labelStyle: TextStyle(color: Colors.white),
      fillColor: Colors.white,
    );
  }

  static InputDecoration inputEstado() {
    return InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 20),
      hintStyle: TextStyle(color: Colors.white),
      prefixIcon: Icon(Icons.location_city_sharp, color: Colors.white),
      labelText: "Estado",
      labelStyle: TextStyle(color: Colors.white),
      fillColor: Colors.white,
    );
  }

  static InputDecoration inputCidade() {
    return InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 20),
      hintStyle: TextStyle(color: Colors.white),
      prefixIcon: Icon(Icons.location_city_sharp, color: Colors.white),
      labelText: "Cidade",
      labelStyle: TextStyle(color: Colors.white),
      fillColor: Colors.white,
    );
  }
}
