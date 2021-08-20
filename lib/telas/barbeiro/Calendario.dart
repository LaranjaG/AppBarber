import 'package:app_barbearia/controller/Agendamento.dart';
import 'package:app_barbearia/controller/Barbearia.dart';
import 'package:app_barbearia/controller/Endereco.dart';
import 'package:app_barbearia/controller/Usuario.dart';
import 'package:app_barbearia/controller/cruds/selects/UsuarioFirebase.dart';
import 'package:app_barbearia/telas/ferramentas/Popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:date_format/date_format.dart';

class Calendario extends StatefulWidget {
  @override
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {

  List<Agendamento> _agendamentos = [];
  Map<String, dynamic> _barbearias = {};
  List<Agendamento> day = [];

  _recuperarAgendamentos() async {
    DateTime data;
    Usuario user = await UsuarioFirebase.getUsuarioLogado() as Usuario;
    // ignore: deprecated_member_use

    FirebaseFirestore dados = FirebaseFirestore.instance;

    await dados.collection("agendamentos")
        .where("idBarbeiro", isEqualTo: user.id)

        .snapshots()
        .listen((snap) async {
      _agendamentos = [];
      _barbearias = {};
      _events = {};
      for (DocumentSnapshot doc in snap.docs) {
        Barbearia barber = Barbearia();
        Usuario usuarioCliente = Usuario();
        usuarioCliente.id = doc.data()["idCliente"];
        Usuario usuarioFuncionario = Usuario();
        usuarioFuncionario.id = doc.data()["idBarbeiro"];

        barber.id = doc.data()["idBarbearia"];
        List cortes = doc.data()["cortes"];
        _agendamentos.add(
            Agendamento.get(
                doc.id,
                DateTime.fromMicrosecondsSinceEpoch(
                    doc.data()["horario"].microsecondsSinceEpoch),
                usuarioCliente,
                usuarioFuncionario,
                doc.data()["status"],
                barber,
                doc.data()["tempoTotal"],
                doc.data()["valorTotal"].toDouble(),
                cortes)
        );



        // _events[DateTime(data.year, data.month, data.day)] = [_agendamentos];
      }

      for (int index = 0; index < _agendamentos.length; index++) {
        print('\n\n??');
        Agendamento agendamento = _agendamentos[index] as Agendamento;

        String idBarber = agendamento.barbearia.id;
        print("ID" + idBarber);
        DocumentSnapshot snapBarber = await dados.collection("barbearias")
            .doc(
            idBarber
        )
            .get();

        Barbearia barber = Barbearia();
        barber.id = idBarber;
        barber.nomeFantasia = snapBarber.data()["nomeFantasia"];
        barber.endereco = Endereco.barbearia(
            snapBarber.data()["endereco"]["estado"],
            snapBarber.data()["endereco"]["cidade"],
            snapBarber.data()["endereco"]["bairro"],
            snapBarber.data()["endereco"]["rua"],
            snapBarber.data()["endereco"]["numero"]);

        _barbearias[idBarber] = {
          "contato": snapBarber.data()["contato"],
          "nome": snapBarber.data()["nomeFantasia"],
          "endereco": snapBarber.data()["endereco"],
        };

        data = DateTime.fromMicrosecondsSinceEpoch(
            agendamento.horario.microsecondsSinceEpoch);

        DateTime dataLocal = DateTime(data.year, data.month, data.day);
        if(_events[dataLocal] == null)
          _events[dataLocal] = [agendamento];
        else{
          List aux = _events[dataLocal];
          aux.add(agendamento);
          _events[dataLocal] = aux;
        }
      }


      setState(() { //Muda o status
        // _agendamento = snap as Map;
        _events;
        _agendamentos;
        _barbearias;
      });
    });
  }

  CalendarController _controller;

  Map<DateTime, List<dynamic>> _events;

  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map){
    Map<String, dynamic> newMap = {};

    map.forEach((key, value) {
      newMap[key.toString()] = map[Key];
    });

    return newMap;
  }

  Map<DateTime, dynamic> dencodeMap(Map<String, dynamic> map){
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[Key];
    });
    return newMap;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = CalendarController();
    _events = {};
    _recuperarAgendamentos();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TableCalendar(

            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.white)
            ),
            locale: "pt_BR",
            events: _events,
            calendarController: _controller,
            initialCalendarFormat: CalendarFormat.month,
            formatAnimation: FormatAnimation.scale,
            calendarStyle: CalendarStyle(
              todayColor: Colors.amber,
              selectedColor: Colors.white12,
              todayStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey
              ),
            ),
            headerStyle: HeaderStyle(
              centerHeaderTitle: true,
              formatButtonVisible: false,
              formatButtonDecoration: BoxDecoration(
                color: Colors.white
              )
            ),
            startingDayOfWeek: StartingDayOfWeek.sunday,
            onDaySelected: (date, list1, list2){
                setState(() {
                  _recuperarAgendamentos();
                });
            },
            builders: CalendarBuilders(
              selectedDayBuilder: (context, date, events) =>
                  Container(
                    margin: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  todayDayBuilder: (context, date, events) =>
                      Container(
                        margin:  const EdgeInsets.all(7),
                        alignment: Alignment.center,
                        decoration:  BoxDecoration(
                          color: Colors.blue.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      )
            ),
          ),
          if(_controller.selectedDay != null)
          if(_events[DateTime(_controller.selectedDay.year, _controller.selectedDay.month, _controller.selectedDay.day)] != null)
          Expanded(
            child: ListView.builder(
                itemCount: _events[DateTime(_controller.selectedDay.year, _controller.selectedDay.month, _controller.selectedDay.day)].length,
                itemBuilder: (context, index){
                  DateTime data = _controller.selectedDay;

                  print("TAMANDO DO EVENTO: ${_events.length}");
                  print('EVENT??? ${_events}');
                  print('DATA ${DateTime(data.year, data.month, data.day)}');
                  print('O Q TEM AQUI? ${_events[DateTime(data.year, data.month, data.day)]}');
                  var dados = _events[DateTime(data.year, data.month, data.day)];
                  print("O Q TEM AQUI?${dados}");
                  Agendamento _dadosAgendamento = dados[index];

                  return Padding(
                    padding: EdgeInsets.only(bottom: 0, right: 7.5, left: 7.5, top: 4),
                    child: Column(
                      children: [
                        Card(
                          color: Colors.transparent,
                          shadowColor: Colors.transparent,
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 60,
                                height: 60,
                                child: Padding(
                                  padding: EdgeInsets.all(1),
                                  child: Icon(Icons.calendar_today_outlined,
                                      color: ((_dadosAgendamento.status == "pendente") ? Colors.white :
                                      (_dadosAgendamento.status == "confirmado") ? Colors.green : Colors.red)
                                  ),
                                ),
                              ),

                              Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width - 83,
                                    child:
                                    ListTile(
                                      title:
                                      GestureDetector(
                                        child: Text("_barbearias[_dadosAgendamento.barbearia.id][]", style:
                                      TextStyle(color: Colors.white),
                                      ), onTap: (){
                                        //Abrir para mais informações
                                        print('');
                                      },
                                      ),

                                      subtitle:
                                      (_dadosAgendamento.status == "pendente") ?
                                      Text(
                                          formatDate(_dadosAgendamento.horario, [HH, ':', nn, ' - ', dd, '/', mm, '/', yyyy]).toString()
                                              + "\nStatus: " + _dadosAgendamento.status.toString()
                                          ,
                                          style: TextStyle(color: Color.fromRGBO(250, 80, 0, 1)))
                                          : Text(
                                          formatDate(_dadosAgendamento.horario, [HH, ':', nn, ' - ', dd, '/', mm, '/', yyyy]).toString()
                                              + "\nStatus: " + _dadosAgendamento.status.toString(),
                                          style: TextStyle(color: Colors.green)),

                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          GestureDetector(
                                            child: Icon(
                                              Icons.cancel,
                                              color: Colors.amber,
                                            ),
                                            onTap: (){
                                              Popup.popupCancelarAgendamento(context, _dadosAgendamento, false,  nomeBarber:
                                              _barbearias[_dadosAgendamento.barbearia.id]["nome"]
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                              )
                            ],
                          ),
                        ),

                        Divider(

                          color: Colors.white,
                        )
                      ] ,
                    ),
                  );

                }
            ),
          )
        ],
      ),
    );
  }
}
