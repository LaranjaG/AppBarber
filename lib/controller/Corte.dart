class Corte{
  int _id;
  double _preco;
  String _nome;
  String _descricao;
  int _tempo; //Em mins
  int _comissao;

//Construtores
  Corte.create(this._preco, this._nome, this._descricao);
  Corte.get(this._id, this._preco, this._nome, this._descricao);

  Map<String, dynamic> topMap(){

    Map<String, dynamic> map = {
      "nome" : this._nome,
      "descricao" : this._descricao,
      "preco" : this._preco,
      "tempo" : this._tempo
    };

    return map ;
  }

  int get tempo => _tempo;

  set tempo(int value) {
    _tempo = value;
  }

  String get descricao => _descricao;

  set descricao(String value) {
    _descricao = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  double get preco => _preco;

  set preco(double value) {
    _preco = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }
}