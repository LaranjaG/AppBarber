import 'package:app_barbearia/controller/Pessoa.dart';
import 'package:app_barbearia/controller/Usuario.dart';
import 'Corte.dart';
import 'Endereco.dart';
import 'Servico.dart';

class Barbearia extends Pessoa {
  String _nomeFantasia;
  String _razaoSocial;
  String _cnpj;
  String _descricao;
  Usuario _responsavel;
  List<Corte> _cortes;
  List<Servico> _servico;
  String _url;

  Barbearia();
  Barbearia.create(this._nomeFantasia, this._razaoSocial, this._cnpj, this._descricao, this._responsavel , String contato, Endereco endereco)
      : super.create(contato, endereco);
  Barbearia.get(this._nomeFantasia, this._razaoSocial, this._cnpj, this._descricao, this._responsavel, /*this._cortes,*/ String id, String contato, Endereco endereco)
      : super.get(id, contato, endereco);

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    Map<String, dynamic> map = { //Map
      "nomeFantasia" : this._nomeFantasia,
      "razaoSocial" : this._razaoSocial,
      "cnpj" : this._cnpj,
      "descricao" : this._descricao,
      "responsavel" : this._responsavel.toMap(),
      "contato" : this.contato,
      "endereco" : this.endereco.toMap()
      //A senha é utilizada apenas para validação, por isso n é necessária
    };

    return map;
  }

//Getters && Setters
  List<Corte> get cortes => _cortes;

  set cortes(List<Corte> value) {
    _cortes = value;
  }

  Usuario get responsavel => _responsavel;

  set responsavel(Usuario value) {
    _responsavel = value;
  }

  String get descricao => _descricao;

  set descricao(String value) {
    _descricao = value;
  }

  String get cnpj => _cnpj;

  set cnpj(String value) {
    _cnpj = value;
  }

  String get razaoSocial => _razaoSocial;

  set razaoSocial(String value) {
    _razaoSocial = value;
  }

  String get nomeFantasia => _nomeFantasia;

  set nomeFantasia(String value) {
    _nomeFantasia = value;
  }
}