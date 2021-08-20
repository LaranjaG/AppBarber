import 'package:app_barbearia/controller/Agendamento.dart';
import 'package:app_barbearia/controller/Servico.dart';
import 'package:app_barbearia/controller/Usuario.dart';

class Controle{
  String _id;
  Usuario _barbeiro;
  DateTime _dataRegistro;
  Agendamento _agendamento;
  Map<String, dynamic> _servico; //Recebe serviço e a quantidade

}