import 'package:app_barbearia/controller/Corte.dart';

import 'Barbearia.dart';
import 'Usuario.dart';


class Agendamento{
//Atributos
  String _id;
  DateTime _horario;
  Usuario _cliente;
  Usuario _funcionario;
  String _status;
  Barbearia _barbearia;
  List _cortes;
  int _tempoTotal;
  double _valorTotal;
  bool _atendido;

//Construtores
  Agendamento();

  Agendamento.create(
      this._horario,
      this._cliente,
      this._funcionario,
      this._status,
      this._barbearia,

      this._tempoTotal,
      this._valorTotal);

  Agendamento.get(
      this._id,
      this._horario,
      this._cliente,
      this._funcionario,
      this._status,
      this._barbearia,
      this._tempoTotal,
      this._valorTotal,
      this._cortes);

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "horario" : this._horario,
      "idCliente" : this._cliente.id,
      "idBarbeiro" : this._funcionario.id,
      "status" : this._status,
      "idBarbearia" : this._barbearia.id,
      "tempoTotal" : this.tempoTotal,
      "valorTotal" : this._valorTotal,
      // "cortes" : this._cortes
    };

    return map;
  }

  //Getters && Setters
  double get valorTotal => _valorTotal;

  set valorTotal(double value) {
    _valorTotal = value;
  }

  int get tempoTotal => _tempoTotal;

  set tempoTotal(int value) {
    _tempoTotal = value;
  }

  List get cortes => _cortes;

  set cortes(List value) {
    _cortes = value;
  }

  Barbearia get barbearia => _barbearia;

  set barbearia(Barbearia value) {
    _barbearia = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  Usuario get funcionario => _funcionario;

  set funcionario(Usuario value) {
    _funcionario = value;
  }

  Usuario get cliente => _cliente;

  set cliente(Usuario value) {
    _cliente = value;
  }

  DateTime get horario => _horario;

  set horario(DateTime value) {
    _horario = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }
}