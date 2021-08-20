import 'dart:async';

import 'package:app_barbearia/controller/Barbearia.dart';
import 'package:app_barbearia/controller/Endereco.dart';
import 'package:app_barbearia/controller/Location/GeoEndereco.dart';
import 'package:app_barbearia/controller/Usuario.dart';
import 'package:app_barbearia/controller/cruds/selects/GeolocatorService.dart';
import 'package:app_barbearia/controller/cruds/selects/Url.dart';
import 'package:app_barbearia/telas/cliente/Avaliacoes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'SolicitarAgendamento.dart';

class IndexBarber extends StatefulWidget {
  IndexBarber({this.barbearia});
  final Barbearia barbearia;
  // final String idUsuario;
  // final Map mapUser;

  @override
  _BarbeariasState createState() => _BarbeariasState();
}

class _BarbeariasState extends State<IndexBarber> {
  final GeolocatorService geoService = GeolocatorService();
  Completer<GoogleMapController> _controller = Completer();
  String _distancia;
  Position _posicao;
  Set<Marker> _marcadores = {};
  Set<Polyline> _polylines = {};
  var nLat, nLog, sLat, sLog;
  bool _visivel;
  bool _mostrarPag = false;
//-17.73125495030081, -49.10915429441235
  var salaoLat = -17.73125495030081;
  var salaoLog = -49.10915429441235;
  double _rating = 1;

  Map<String, dynamic> _horarioFuncionamento = {
    "Domingo": "08:00 - 12:00",
    "Segunda-feira": "08:00 - 19:00",
    "Terça-feira": "08:00 - 19:00",
    "Quarta-feira": "08:00 - 19:00",
    "Quinta-feira": "08:00 - 19:00",
    "Sexta-feira": "08:00 - 19:00",
    "Sábado": "08:00 - 19:00",
    "Fériados": {"disponpivel": false, "horario": ""}
  };

  String _endereco;

  void _abrirWaze() async {
    Url.abrirUrl("https://waze.com/ul?ll=${salaoLat},${salaoLog}&z=10")
        .catchError((erro) => print('Erro ao pegar Url'));
  }

  void _abrirGoogleMaps() async {
    Url.abrirUrl((true)
            ? "https://www.google.com.br/maps/place/Barbearia+do+Leandro/@-17.7312976,-49.1113296,17z/data=!3m1!4b1!4m5!3m4!1s0x94a09413a9752419:0xd7c2351b1ee4b4c3!8m2!3d-17.7312665!4d-49.1091551?hl=pt-BR"
            : "https://www.google.com/maps/search/?api=1&query=${salaoLat}, ${salaoLog}")
        .catchError((erro) => print('Erro ao pegar Url'));
  }

  void _pegarPosicao() async {
    _posicao = await geoService.getInitialLocation();
    _endereco = await GeoEndereco.montarEnderecoAddress(salaoLat, salaoLog);
    setState(() {
      _posicao;
      _endereco;

      _carregarMarcadores();
      _carregarPolylines();
    });
  }

  _carregarMarcadores() async {
    // Marker marcadorUsuario = Marker(
    //     markerId: MarkerId("marcador-usuario"),
    //     position: _posicao.latitude != null
    //         ? LatLng(_posicao.latitude, _posicao.longitude)
    //         : LatLng(salaoLat, salaoLog),
    //     infoWindow: InfoWindow(title: "Localização atual"),
    //     alpha: 0.75,
    //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan));

    Marker marcadorBarber = Marker(
      markerId: MarkerId("marcador-barber"),
      position: LatLng(-17.731144300328083, -49.10910871650915),
      infoWindow: InfoWindow(
        title: "Barbearia do Leando",
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      // await BitmapDescriptor.fromAssetImage(
      //     ImageConfiguration(
      //         devicePixelRatio: MediaQuery.of(context).devicePixelRatio),
      //     "!assetpath"),
    );

    // _marcadores.add(marcadorUsuario);
    _marcadores.add(marcadorBarber);

    setState(() {
      _marcadores;

      geoService.movimentarCameraBouds(
        geoService.determinarPontosBouds(
          _posicao.latitude,
          _posicao.longitude,
          salaoLat,
          salaoLog,
        ),
        _controller,
      );
    });
  }

  _carregarPolylines() {
    Polyline polyline = Polyline(
        polylineId: PolylineId("poly"),
        color: Color.fromRGBO(255, 0, 50, 0.8),
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.mitered,
        width: 10,
        points: [
          LatLng(_posicao.latitude, _posicao.longitude),
          LatLng(-17.731144300328083, -49.10910871650915),
        ]);

    _polylines.add(polyline);
    setState(() {
      _polylines;
    });
  }

  Future<void> centerScreen(Position position) async {
    final GoogleMapController googleController = await _controller.future;
    googleController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position.latitude != null
              ? LatLng(position.latitude, position.longitude)
              : LatLng(-17.731052327737945, -49.109087258838706),
          zoom: 20,
          tilt: 45, //Inclinação
          bearing: 30, //Rotação
        ),
      ),
    );
  }

  Barbearia _barber = null;
  List _func = [];

  _recuperarBarbearias(Barbearia dados) async {
    // print(dados.data()["descricao"]);

    // Usuario usuario = Usuario.create(dados.data()["nome"], dados.data()["email"], dados.data()["senha"], dados.data()["tipoUsuario"], dados.data()["contato"],
    //     Endereco.usuario(dados.data()["endereco"]["estado"], dados.data()["endereco"]["cidade"]));

    // _barber = Barbearia.get(dados.data()["nomeFantasia"], dados.data()["razaoSocial"],
    //     dados.data()["cnpj"], dados.data()["descricao"],
    //     usuario,
    //     dados.id, dados.data()["contato"],
    //     Endereco.barbearia(dados.data()["endereco"]["estado"], dados.data()["endereco"]["cidade"], dados.data()["endereco"]["bairro"], dados.data()["endereco"]["rua"], dados.data()["endereco"]["numero"])
    // );

    _barber = dados;

    FirebaseFirestore fire = FirebaseFirestore.instance;

    // QuerySnapshot snapshot = await fire.collection("barbearias").doc(
    //   _barber.id
    // ).collection("funcionario").get();

    QuerySnapshot snapshot = await fire
        .collection("funcionarios")
        .where("idBarbearia", isEqualTo: widget.barbearia.id)
        .get();

    for (DocumentSnapshot funcionario in snapshot.docs) {
      DocumentSnapshot dados = await fire
          .collection("usuarios")
          .doc(funcionario.data()["idBarbeiro"])
          .get();

      _func.add(Usuario.get(
          dados.data()["nome"],
          dados.data()["email"],
          dados.data()["tipoUsuario"],
          dados.data()["foto"],
          dados.id,
          dados.data()["contato"],
          Endereco()));
    }
    // String tipoUser = dadosUser["tipoUsuario"];
    print(_func);
    print('O QUE?');

    setState(() {
      _func;
      _barber;
    });
    // ignore: deprecated_member_use
  }

  @override
  void initState() {
    _visivel = false;
    setState(() {
      // _distancia = "desconhecida";
      geoService.distanciaLocalizacaoAtual(salaoLat, salaoLog).then(
        (value) {
          _distancia = value;
          setState(() => _distancia);
        },
      );
      _pegarPosicao();
      geoService.getCurrentLocation().listen((position) {
        // centerScreen(position);

        nLat;
        nLog;
        sLog;
        sLat;

        // _movimentarCameraBouds(
        //   LatLngBounds(
        //     northeast: LatLng(nLat, nLog),
        //     southwest: LatLng(sLat, sLog),
        //   ),
        // );
      });
    });
    super.initState();
    _recuperarBarbearias(widget.barbearia);
  }

  int _stars = 0;
  Widget _buildStar(int starCount) {
    return InkWell(
      child: Icon(
        Icons.star,
        // size: 30.0,
        color: _stars >= starCount ? Colors.orange : Colors.grey,
      ),
      onTap: () => setState(
        () => _stars = starCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // _funcionarios(),
            Container(
              child: Container(
                child: Column(
                  children: [
                    _map(),
                    _redeSociais(),
                    _avaliacoes(),
                    _contato(),
                    _horarioFuncionamentoBarber(),
                    _pagamento(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pagamento() {
    return GestureDetector(
      onTap: () => setState(() => _mostrarPag = !_mostrarPag),
      child: (!_mostrarPag)
          ? Container(
              margin: EdgeInsets.only(top: 10, bottom: 15),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.2 / 2 -
                                12,
                            right: MediaQuery.of(context).size.width * 0.2 / 2 -
                                4),
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Icon(
                          // FontAwesomeIcons.moneyBill,
                          Icons.attach_money_sharp,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Formas de Pagamento'),
                                Icon(Icons.arrow_drop_down_rounded)
                                // Text('08:00 - 19:00'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : _formaPagamento(),
    );
  }

  Widget _formaPagamento() {
    return GestureDetector(
      onTap: () => setState(() => _mostrarPag = !_mostrarPag),
      child: Container(
        margin: EdgeInsets.only(top: 5, bottom: 15),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  // padding: EdgeInsets.only(
                  // left: MediaQuery.of(context).size.width * 0.2 / 2 - 12,
                  // right: MediaQuery.of(context).size.width * 0.2 / 2 - 4),
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Icon(Icons.attach_money_sharp),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Column(
                    children: [
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Icon(FontAwesomeIcons.moneyBill),
                          Container(
                            margin: EdgeInsets.only(top: 2.5),
                            child: Text(' - Dinheiro'),
                          ),
                          // Text('08:00 - 19:00'),
                        ],
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Icon(FontAwesomeIcons.creditCard),
                          Container(
                            margin: EdgeInsets.only(top: 2.5),
                            child: Text(' - Cartão de Crédito'),
                          ),
                          // Text('08:00 - 19:00'),
                        ],
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Icon(FontAwesomeIcons.creditCard),
                          Container(
                            margin: EdgeInsets.only(top: 2.5),
                            child: Text(' - Cartão de Débito'),
                          ),
                          // Text('08:00 - 19:00'),
                        ],
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Icon(FontAwesomeIcons.transgender),
                          Container(
                            margin: EdgeInsets.only(top: 2.5),
                            child: Text(' - Pix'),
                          ),
                          // Text('08:00 - 19:00'),
                        ],
                      ),
                      Row(
                        children: [
                          // Icon(FontAwesomeIcons.transgender),
                          Container(
                            margin: EdgeInsets.only(top: 2.5),
                            child: Text(' - Transferencia Bancaria'),
                          ),
                          // Text('08:00 - 19:00'),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _redeSociais() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (true) //Se tiver o link
            GestureDetector(
              onTap: () => Url.abrirUrl(
                  'https://www.facebook.com/185217952403010/photos/a.187647085493430/770256037232529/'),
              // 'https://www.facebook.com/100052035090209/posts/249942430083592/?sfnsn=wiwspwa'),
              child: Container(
                padding: EdgeInsets.only(top: 8, right: 4, left: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xff3B5998),
                ),
                child: Icon(
                  FontAwesomeIcons.facebookF,
                  color: Colors.white,
                ),
              ),
            ),
          if (true) //Se tiver o link
            GestureDetector(
              onTap: () => Url.abrirUrl(
                  'https://instagram.com/leandro_barbershop07?igshid=1e5ectht3eg48'),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    tileMode: TileMode.mirror,
                    // transform: ,
                    end: Alignment.bottomRight,
                    stops: [0.1, 0.2, 0.9],
                    colors: [
                      Color.fromRGBO(84, 70, 159, 1),
                      Color.fromRGBO(160, 48, 160, 1),
                      Color.fromRGBO(250, 96, 45, 1),
                    ],
                  ),
                ),
                child: Icon(
                  FontAwesomeIcons.instagram,
                ),
              ),
            ),
          if (true) //Se tiver o link
            GestureDetector(
              onTap: () => Url.abrirUrl(
                'https://www.facebook.com',
                // 'facebook:https://www.facebook.com/Barbearia-do-Leandro-185217952403010/?ref=page_internal',
              ),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xff00acee),
                ),
                child: Icon(
                  FontAwesomeIcons.twitter,
                ),
              ),
            ),
          if (true) //Se tiver o link
            GestureDetector(
              onTap: () => Url.abrirUrl(
                  'whatsapp://send?phone=+5564992869728&text=Olá,tudo bem ?'),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xff3ac24e),
                ),
                child: Icon(
                  FontAwesomeIcons.whatsapp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _avaliacoes() {
    return Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              child: Text('Avaliações'),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStar(1),
                  _buildStar(2),
                  _buildStar(3),
                  _buildStar(4),
                  _buildStar(5),
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Text('4.8'),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Número de avaliações: 300',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            GestureDetector(
              child: Container(
                margin: EdgeInsets.only(bottom: 15),
                child: Text(
                  'Ver avaliações',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Avaliacoes(),
                ),
              ),
            ),
          ],
        ));
  }

  _sistemaData() {
    return DateTime.now().weekday;
  }

  List _diasSemana = [
    '',
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  Widget _contato() {
    return GestureDetector(
      onTap: () => Url.abrirUrl('tel: +55 64 99286-9728'),
      child: Container(
        margin: EdgeInsets.only(top: 20, bottom: 5),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.2 / 2 - 12,
                      right: MediaQuery.of(context).size.width * 0.2 / 2 - 4),
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Icon(Icons.phone),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('+55 64 99286-9728'),
                          // Text('08:00 - 19:00'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _horarioFuncionamentoBarber() {
    return Container(
      // height: 300,
      margin: EdgeInsets.only(top: 15, bottom: 7.5),
      child: Column(
        children: [
          if (!_visivel)
            GestureDetector(
              onTap: () => setState(() => _visivel = !_visivel),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.2 / 2 -
                                12,
                            right: MediaQuery.of(context).size.width * 0.2 / 2 -
                                4),
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Icon(Icons.watch_later_outlined),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Status: aberto 08:00 - 19:00'),
                                Icon(Icons.arrow_drop_down_rounded)
                                // Text('08:00 - 19:00'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (_visivel) _funcionamento(),
        ],
      ),
    );
  }

  Widget _funcionamento() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      // width: MediaQuery.of(context).size.width * 0.9,
      child: GestureDetector(
        onTap: () => setState(() => _visivel = !_visivel),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: 0,
                      // right: MediaQuery.of(context).size.width * 0.2 / 2 - 4),
                    ),
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Icon(Icons.watch_later_outlined),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Segunda-feira'),
                            Text('08:00 - 19:00'),
                          ],
                        ),
                        Divider(
                          color: Colors.white,
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Terça-feira'),
                            Text('08:00 - 19:00'),
                          ],
                        ),
                        Divider(
                          color: Colors.white,
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Quarta-feira'),
                            Text('08:00 - 19:00'),
                          ],
                        ),
                        Divider(
                          color: Colors.white,
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Quinta-feira'),
                            Text('08:00 - 19:00'),
                          ],
                        ),
                        Divider(
                          color: Colors.white,
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sexta-feira'),
                            Text('08:00 - 19:00'),
                          ],
                        ),
                        Divider(
                          color: Colors.white,
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sábado'),
                            Text('08:00 - 19:00'),
                          ],
                        ),
                        Divider(
                          color: Colors.white,
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Domingo'),
                            Text('08:00 - 19:00'),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _map() {
    return Container(
      height: MediaQuery.of(context).size.height / 1.9,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              tilt: 30,
              target: LatLng(
                0,
                0,
              ),
            ),
            // zoomGesturesEnabled: true,

            mapType: MapType.normal,
            onMapCreated: (GoogleMapController googleMapController) {
              _controller.complete(googleMapController);
              setState(() {
                _controller;
              });
            },
            myLocationEnabled:
                true, //Pontinho azul que mostra a localização do usuario
            myLocationButtonEnabled:
                false, //Botão para ir para posição atual do usuario
            zoomControlsEnabled: false, //Controles de zoom
            tiltGesturesEnabled:
                true, //Altera alguma coisa q eu n sei o que é, mas deu diferença no valor da distancia
            mapToolbarEnabled: false, //Desativar os botões do aplicatico
            markers: _marcadores,
            // polylines: _polylines,
            // onCameraMoveStarted: () => _movimentarCameraBouds(
            //   LatLngBounds(
            //     northeast: LatLng(nLat, nLog),
            //     southwest: LatLng(sLat, sLog),
            //   ),
            // ),
            onLongPress: (_) {
              geoService.movimentarCameraBouds(
                geoService.determinarPontosBouds(
                  _posicao.latitude,
                  _posicao.longitude,
                  salaoLat,
                  salaoLog,
                ),
                _controller,
              );
              // _abrirGoogleMaps();
            },
          ),

          /**
             * Left
             */

          //Distância
          Positioned(
            left: 10,
            top: 5,
            child: Container(
              child: Text(
                "Distância: ${_distancia} km",
                style: TextStyle(color: Colors.white),
              ),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black87,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          //Endereço
          Positioned(
            bottom: 0,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    FontAwesomeIcons.mapMarkerAlt,
                    size: 16,
                  ),
                  Text(
                    "${_endereco}",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black87,
                border: Border.all(color: Colors.black),
                // borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),

          Positioned(
            bottom: 55,
            left: 15,
            child: FloatingActionButton(
              onPressed: () async {
                geoService.movimentarCameraBouds(
                  geoService.determinarPontosBouds(
                    _posicao.latitude,
                    _posicao.longitude,
                    salaoLat,
                    salaoLog,
                  ),
                  _controller,
                );
              },
              child: Icon(
                Icons.location_searching,
                size: 18,
              ),
              backgroundColor: Color.fromRGBO(255, 205, 205, 0.8),
              mini: true,
            ),
          ),

          /**
             * Right
             */
          Positioned(
            bottom: 135,
            right: 15,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _abrirGoogleMaps,
                  child: Icon(
                    FontAwesomeIcons.mapMarkerAlt,
                    size: 18,
                    // Icons.local_activity,
                  ),
                  backgroundColor: Colors.red,
                  mini: true,
                ),
                Text(
                  "Maps",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 55,
            right: 15,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _abrirWaze,
                  child: Icon(
                    FontAwesomeIcons.waze,
                    size: 18,
                  ),
                  backgroundColor: Color.fromRGBO(76, 185, 236, 1),
                  mini: true,
                ),
                Text(
                  "Waze",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
