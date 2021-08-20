import 'package:app_barbearia/controller/Barbearia.dart';
import 'package:app_barbearia/controller/Corte.dart';
import 'package:app_barbearia/controller/Servico.dart';
import 'package:app_barbearia/controller/Usuario.dart';
import 'package:app_barbearia/controller/cruds/selects/UsuarioFirebase.dart';
import 'package:app_barbearia/telas/ferramentas/Popup.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class FecharAgendamento extends StatefulWidget {
  FecharAgendamento({this.barbearia, this.barbeiro});

  Barbearia barbearia;
  final DocumentSnapshot barbeiro;

  @override
  _FecharAgendamentoState createState() => _FecharAgendamentoState();

}
class _FecharAgendamentoState extends State<FecharAgendamento> {
  TextEditingController _controllerData = TextEditingController();
  TextEditingController _controllerHora = TextEditingController();
  TextEditingController _controllerValor = TextEditingController();
  TextEditingController _controllerTempo = TextEditingController();
  DateTime _dateTime = DateTime.now();
  TimeOfDay _time;
  List<Corte> _cortes = null;
  Map _cortesSelecionados = {};
  double _valor = 0;
  int _tempo = 0;
  List<Servico> servico;
  bool _agendamento = true;

  _calcularValores(operacao, index){

    if(operacao == "add"){
      _cortesSelecionados.forEach((key, value) {
        if(key == index){
          _valor += value["preco"];
          // _tempo += value["tempo"];
        }

      });
    } else{
      _cortesSelecionados.forEach((key, value) {
        if(key == index){
          _valor -= value["preco"];
          // _tempo -= value["tempo"];
        }
      });
    }


    setState(() {
      if(_valor == 0) _controllerValor.text = "R\$ 0.00";
      else _controllerTempo.text = "${_tempo} min";
      if(_tempo == 0) _controllerTempo.text = "00 min";
      else _controllerValor.text = "R\$ ${_valor}0";



    });
  }

  _pegarCortes() async{
    FirebaseFirestore dados = FirebaseFirestore.instance;
    widget.barbearia = await UsuarioFirebase.getBarbearia() as Barbearia;
    DocumentSnapshot snap = await dados.collection("barbearias").doc(widget.barbearia.id).get();
    _cortes = widget.barbearia.cortes;

    setState(() {
      _cortes;
    });
  }

  _addSerico(){
    Popup.formServico(context);
  }
  _solicitarAgendamento() async{

    Usuario user = await UsuarioFirebase.getUsuarioLogado() as Usuario;
    FirebaseFirestore dados = FirebaseFirestore.instance;



    await dados.collection("agendamentos").add(
        {
          "idCliente" : user.id,
          "idBarbeiro" : widget.barbeiro.id,
          "idBarbearia" : widget.barbearia.id,
          "horario" : DateTime.utc(_dateTime.year, _dateTime.month, _dateTime.day, _time.hour, _time.minute),
          "cortes" : _cortes,
          "valorTotal" : _valor,
          "tempoTotal" : _tempo,
          "status" : "confirmado"
        }
    );

  }

  _mostrarData(){
    showDatePicker(
        context: context,
        initialDate: _dateTime == null ? DateTime.now() : _dateTime,
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(DateTime.now().year+1)
    ).then((date) {
      setState(() {
        _dateTime = date;
        _controllerData.text = _dateTime == null ? "" :
        (date.day < 10 ? "0${date.day.toString()}" : date.day.toString()) +  "/" +
            (date.month <  10 ? "0${date.month.toString()}" : date.month.toString())
            + "/"+ date.year.toString();
      });
    });
  }

  _mostrarRelogio(){
    showTimePicker(
        context: context,
        initialTime: _time == null ? TimeOfDay(hour: 0, minute: 0) : _time
    ).then((time) {
      setState(() {
        _time = time;
        _controllerHora.text = _time == null ? "" : _time.hour.toString() + ":"
            + (_time.minute < 10 ? "0${_time.minute.toString()}" : _time.minute.toString());
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _time = TimeOfDay.now();
      _controllerHora.text = _time == null ? "" : _time.hour.toString() + ":"
          + (_time.minute < 10 ? "0${_time.minute.toString()}" : _time.minute.toString());
    });
    setState(() {
      _dateTime = DateTime.now();
      _controllerData.text = _dateTime == null ? "" :
      (_dateTime.day < 10 ? "0${_dateTime.day.toString()}" : _dateTime.day.toString()) +  "/" +
          (_dateTime.month <  10 ? "0${_dateTime.month.toString()}" : _dateTime.month.toString())
          + "/"+ _dateTime.year.toString();
    });
    setState(
        (){
          _controllerValor.text = "20.00";
        }
    );
    _pegarCortes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Controle Agendamento"),
        ),

        body: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if(_cortes != null)
                    Expanded(
                        child: ListView.builder(
                            itemCount: _cortes.length,
                            itemBuilder: (context, index){

                              final Corte item = _cortes[index];

                              return GestureDetector(
                                onTap: (){
                                  setState(() {
                                    if(_cortesSelecionados[index] == null){
                                      _cortesSelecionados[index] = item.topMap();
                                      _calcularValores("add", index);

                                    } else{
                                      _calcularValores("remove", index);
                                      _cortesSelecionados.remove(index);
                                    }

                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  // Text(item["nome"], style: (_cortesSelecionados[index] != null ? TextStyle(color: Colors.red) : TextStyle(color: Colors.white)) )
                                  child: Card(
                                    color: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width: 60,
                                          height: 60,
                                          child: Padding(
                                            padding: EdgeInsets.all(1),
                                            child: ((_cortesSelecionados[index] == null) ? Icon(Icons.check_box_outline_blank, size: 30, color: Colors.blue) : Icon(Icons.check, size: 30, color: Colors.blue)) ,
                                          ),
                                        ),

                                        Padding(
                                            padding: EdgeInsets.only(top: 0, bottom: 0),
                                            child: Container(
                                              width: MediaQuery.of(context).size.width - 120,
                                              child:
                                              ListTile(
                                                title: GestureDetector(child: Text(item.nome, style: TextStyle(color: Colors.white),), onTap: (){
                                                  //Abrir para mais informações
                                                  print('');
                                                },),
                                                // subtitle: Text("Barbeiro", style: TextStyle(color: Color.fromRGBO(250, 80, 0, 1))) ,
                                                trailing: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Padding(padding: EdgeInsets.only(top: 9),
                                                      child: GestureDetector(
                                                        child: Column(
                                                          children: [
                                                            Icon(
                                                              Icons.info_outline,
                                                              color: Colors.amber,
                                                            ),
                                                          ],
                                                        ),
                                                        onTap: (){
                                                          Popup.popup(context, titulo: Text("Corte"), container: "Esse corte aqui");
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                        )
                    ),
                  Divider(
                    color: Colors.white,
                  ),
                  Center(
                    child: Text("Cliente: ", style: TextStyle(color: Colors.white))
                  ),
                  Center(
                    child:                   Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Text("Faltou", style: TextStyle(color: Colors.white)),
                          Switch(
                            value: _agendamento, //Se for false, é cliente, se verdadeiro é Barbeiro/Funcionario
                            onChanged: (bool valor){
                              setState(() {
                                _agendamento = valor;
                              });
                            },
                          ),
                          Text("Compareceu", style: TextStyle(color: Colors.white))
                        ],
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(
                      bottom: 20, top: 5, left: 20, right: 20),
                    child: ElevatedButton(
                      child: Text(
                        "Adicionar serviço",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.white38,
                          padding: EdgeInsets.fromLTRB(32, 16, 32, 16)
                      ),

                      // color: Colors.blue,
                      onPressed: () => _addSerico(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: TextField(
                      readOnly: true,
                      enabled: true,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.info, color: Colors.white),
                        errorText: null,
                        labelText: "Detalhes Agendamento",
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white,

                      ),
                    ),
                  ),

                  Container(
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          // crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            Container(
                              width: 200,
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                              child: TextField(
                                readOnly: true,
                                onTap: () => _mostrarData(),
                                controller: _controllerData,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                                  //hintText: "email@dominio.com",
                                  hintStyle: TextStyle(color: Colors.white),
                                  prefixIcon: Icon(Icons.date_range, color: Colors.white),
                                  errorText: null,
                                  labelText: "Data",
                                  labelStyle: TextStyle(color: Colors.white),
                                  fillColor: Colors.white,

                                ),
                              ),
                            ),
                            Container(
                              width: 130,
                              padding: EdgeInsets.fromLTRB(1, 0, 0, 5),
                              child: TextField(
                                readOnly: true,
                                onTap: () => _mostrarRelogio(),
                                controller: _controllerHora,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                                  //hintText: "email@dominio.com",
                                  hintStyle: TextStyle(color: Colors.white),
                                  prefixIcon: Icon(Icons.access_time, color: Colors.white),
                                  errorText: null,
                                  labelText: "Hora",
                                  labelStyle: TextStyle(color: Colors.white),
                                  fillColor: Colors.white,

                                ),
                              ),
                            ),
                          ],
                        ),

                        Container(
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                          child: TextField(
                            readOnly: true,
                            enabled: true,
                            controller: _controllerValor,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                              hintStyle: TextStyle(color: Colors.white),
                              prefixIcon: Icon(Icons.attach_money, color: Colors.white),
                              errorText: null,
                              labelText: "Valor",
                              labelStyle: TextStyle(color: Colors.white),
                              fillColor: Colors.white,

                            ),
                          ),
                        ),

                      ],
                    ),
                  ),

                  Divider(
                    color: Colors.white,
                  ),



                  Padding(padding: EdgeInsets.only(
                      bottom: 20, top: 20),
                    child: ElevatedButton(
                      child: Text(
                        "Salvar",
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
                      onPressed: () => _solicitarAgendamento(),
                    ),
                  ),

                ],
              ),
            )
        )
    );
  }
}
