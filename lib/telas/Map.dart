// import 'dart:async';

// import 'package:app_barbearia/controller/cruds/selects/GeolocatorService.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';

// class Map extends StatefulWidget {
//   @override
//   _MapState createState() => _MapState();
// }

// class _MapState extends State<Map> {
//   final GeolocatorService geoService = GeolocatorService();
//   Completer<GoogleMapController> _controller = Completer();
//   String _distancia;
//   Position _posicao;
//   Set<Marker> _marcadores = {};
//   Set<Polyline> _polylines = {};
//   var nLat, nLog, sLat, sLog;
// //-17.73125495030081, -49.10915429441235
//   var salaoLat = -17.73125495030081;
//   var salaoLog = -49.10915429441235;

//   String _endereco;

//   Future<void> _abrirUrl(String url) async {
//     if (await canLaunch(url))
//       await launch(url);
//     else
//       throw 'Erro ao abrir url de destino';
//   }

//   void _abrirWaze() async {
//     await _abrirUrl("https://waze.com/ul?ll=${salaoLat},${salaoLog}&z=10");
//   }

//   void _abrirGoogleMaps() async {
//     await _abrirUrl(
//         "https://www.google.com/maps/search/?api=1&query=${salaoLat}, ${salaoLog}");
//   }

//   void _pegarPosicao() async {
//     _posicao = await geoService.getInitialLocation();
//     setState(() {
//       _posicao;
//       if (_posicao.latitude <= salaoLat) {
//         sLat = _posicao.latitude;
//         nLat = salaoLat;
//       } else {
//         nLat = _posicao.latitude;
//         sLat = salaoLat;
//       }

//       if (_posicao.longitude <= salaoLog) {
//         sLog = _posicao.longitude;
//         nLog = salaoLog;
//       } else {
//         nLog = _posicao.longitude;
//         sLog = salaoLog;
//       }
//     });

//     _carregarMarcadores();
//     _carregarPolylines();
//     _recuperarEndereco();
//   }

//   String _calcularDistancia() {
//     // geoService.getCurrentLocation().listen((snap) async {
//     //   print('\n\nTeste:\n\n');
//     //   print('${await snap.latitude}');
//     //   print('${await snap.longitude}');
//     //   print('\n\n\n');
//     // });

//     geoService.getInitialLocation().then((snap) {
//       print('\n\n\n\nValue ${snap.longitude}, ${snap.latitude}\n\n\n\n');
//       final double startLat = snap.latitude;
//       final double starLng = snap.longitude;
//       final double endLat = -17.731144300328083;
//       final double endLng = -49.10910871650915;

//       print("\n\n\n\n\n\n\n\n AHHHHHHHHHHHHHHHHHHHHHH\n\n\n\n${starLng}");
//       final String distancia =
//           (Geolocator.distanceBetween(startLat, starLng, endLat, endLng) / 1000)
//               .toStringAsPrecision(2);

//       valorDistancia(distancia);
//     });

//     // print("Distancia${distancia}");

//     // return distancia;
//   }

//   void valorDistancia(String valor) {
//     print("VALOR: ${valor}");
//     setState(() {
//       _distancia = valor;
//     });
//   }

//   _carregarMarcadores() async {
//     Marker marcadorUsuario = Marker(
//         markerId: MarkerId("marcador-usuario"),
//         position: _posicao.latitude != null
//             ? LatLng(_posicao.latitude, _posicao.longitude)
//             : LatLng(salaoLat, salaoLog),
//         infoWindow: InfoWindow(title: "Localização atual"),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan)
//         // icon: Icons.ac_unit
//         );

//     Marker marcadorBarber = Marker(
//       markerId: MarkerId("marcador-barber"),
//       position: LatLng(-17.731144300328083, -49.10910871650915),
//       infoWindow: InfoWindow(title: "Barbearia do Leando"),
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//       // await BitmapDescriptor.fromAssetImage(
//       //     ImageConfiguration(
//       //         devicePixelRatio: MediaQuery.of(context).devicePixelRatio),
//       //     "!assetpath"),
//     );

//     _marcadores.add(marcadorUsuario);
//     _marcadores.add(marcadorBarber);

//     setState(() {
//       _marcadores;

//       _movimentarCameraBouds(
//         LatLngBounds(
//           northeast: LatLng(nLat, nLog),
//           southwest: LatLng(sLat, sLog),
//         ),
//       );
//     });
//   }

//   _carregarPolylines() {
//     Polyline polyline = Polyline(
//         polylineId: PolylineId("poly"),
//         color: Color.fromRGBO(255, 0, 50, 0.8),
//         startCap: Cap.roundCap,
//         endCap: Cap.roundCap,
//         jointType: JointType.mitered,
//         width: 10,
//         points: [
//           LatLng(_posicao.latitude, _posicao.longitude),
//           LatLng(-17.731144300328083, -49.10910871650915),
//         ]);

//     _polylines.add(polyline);
//     setState(() {
//       _polylines;
//     });
//   }

//   _movimentarCameraBouds(LatLngBounds latLngBounds) async {
//     GoogleMapController googleMapController = await _controller.future;
//     googleMapController.animateCamera(
//       CameraUpdate.newLatLngBounds(latLngBounds, 85),
//     );
//   }

//   Future<void> centerScreen(Position position) async {
//     final GoogleMapController googleController = await _controller.future;
//     googleController.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: position.latitude != null
//               ? LatLng(position.latitude, position.longitude)
//               : LatLng(-17.731052327737945, -49.109087258838706),
//           zoom: 20,
//           tilt: 45, //Inclinação
//           bearing: 30, //Rotação
//         ),
//       ),
//     );
//   }

//   _recuperarEndereco() async {
//     List<Location> locations =
//         await locationFromAddress("R. Piauí, 383 - Centro, Morrinhos - GO");
//     //Converte em um array com a geolocalização do endereço

//     List<Placemark> placemarks = await placemarkFromCoordinates(
//         locations[0].latitude, locations[0].longitude);
//     //Converte a a gelocalização em uma lista de endereços escritos
//     // _endereco = placemarks[0] as Map;
//     Placemark endereco = placemarks[0];
//     placemarks.forEach((element) {
//       print("\n\n\nLocality: ${element.locality}");
//     });
//     print(endereco);
//     print(
//         "\n\n\n\nENDERECO: \nRua: ${endereco.street} \nLocality: ${endereco.locality} \nName:${endereco.name}\n\n\n\n");

//     _endereco =
//         '${endereco.street}, ${endereco.subThoroughfare} - ${endereco.subAdministrativeArea} - ${endereco.administrativeArea}';

//     setState(() {
//       _endereco;
//     });
//   }

//   @override
//   void initState() {
//     setState(() {
//       _distancia = "desconhecida";
//       _calcularDistancia();
//       _pegarPosicao();
//       geoService.getCurrentLocation().listen((position) {
//         // centerScreen(position);

//         nLat;
//         nLog;
//         sLog;
//         sLat;

//         _movimentarCameraBouds(
//           LatLngBounds(
//             northeast: LatLng(nLat, nLog),
//             southwest: LatLng(sLat, sLog),
//           ),
//         );
//       });
//     });

//     // TODO: implement initState
//     super.initState();

//     // setState(() {
//     //   _distancia = _calcularDistancia();
//     // });
//   }

//   @override
//   Widget build(BuildContext contex) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Maps"),
//       ),
//       // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       // floatingActionButton: FloatingActionButton(
//       //   child: Icon(Icons.gif),
//       //   onPressed: () {
//       //     centerScreen(_posicao);
//       //   },
//       // ),
//       body: Container(
//         height: MediaQuery.of(context).size.height / 3,
//         width: MediaQuery.of(context).size.width,
//         child: Stack(
//           children: [
//             GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: LatLng(
//                   _posicao.latitude,
//                   _posicao.longitude,
//                 ),
//               ),
//               mapType: MapType.normal,

//               onMapCreated: (GoogleMapController googleMapController) {
//                 _controller.complete(googleMapController);
//               },
//               myLocationEnabled:
//                   false, //Pontinho azul que mostra a localização do usuario
//               myLocationButtonEnabled:
//                   false, //Botão para ir para posição atual do usuario

//               zoomControlsEnabled: false, //Controles de zoom
//               tiltGesturesEnabled:
//                   true, //Altera alguma coisa q eu n sei o que é, mas deu diferença no valor da distancia
//               mapToolbarEnabled: false, //Desativar os botões do aplicatico
//               markers: _marcadores,
//               polylines: _polylines,
//             ),

//             /**
//              * Left
//              */
//             Positioned(
//               left: 10,
//               top: 5,
//               child: Container(
//                 child: Text(
//                   "Distância: ${_distancia} km",
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.black87,
//                   border: Border.all(color: Colors.black),
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 0,
//               child: Container(
//                 child: Text(
//                   "${_endereco}",
//                   style: TextStyle(color: Colors.white),
//                   textAlign: TextAlign.center,
//                 ),
//                 width: MediaQuery.of(context).size.width,
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.black87,
//                   border: Border.all(color: Colors.black),
//                   // borderRadius: BorderRadius.circular(5),
//                 ),
//               ),
//             ),

//             /**
//              * Right
//              */
//             Positioned(
//               bottom: 135,
//               right: 15,
//               child: Column(
//                 children: [
//                   FloatingActionButton(
//                     onPressed: _abrirGoogleMaps,
//                     child: Icon(
//                       FontAwesomeIcons.mapMarkerAlt,
//                       // Icons.local_activity,
//                     ),
//                     backgroundColor: Colors.red,
//                   ),
//                   Text("Maps"),
//                 ],
//               ),
//             ),
//             Positioned(
//               bottom: 55,
//               right: 15,
//               child: Column(
//                 children: [
//                   FloatingActionButton(
//                     onPressed: _abrirWaze,
//                     child: Icon(
//                       FontAwesomeIcons.waze,
//                     ),
//                     backgroundColor: Colors.blue,
//                   ),
//                   Text("Waze"),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
