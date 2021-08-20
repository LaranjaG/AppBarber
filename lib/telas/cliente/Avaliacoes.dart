import 'dart:async';

import 'package:app_barbearia/controller/Barbearia.dart';
import 'package:app_barbearia/controller/Endereco.dart';
import 'package:app_barbearia/controller/Location/GeoEndereco.dart';
import 'package:app_barbearia/controller/Usuario.dart';
import 'package:app_barbearia/controller/cruds/selects/GeolocatorService.dart';
import 'package:app_barbearia/controller/cruds/selects/Url.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'SolicitarAgendamento.dart';

class Avaliacoes extends StatefulWidget {
  Avaliacoes({this.barbearia});
  final Barbearia barbearia;
  // final String idUsuario;
  // final Map mapUser;

  @override
  _AvaliacoesState createState() => _AvaliacoesState();
}

class _AvaliacoesState extends State<Avaliacoes> {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: Container(
        child: Column(
          children: [
            _escalaAvaliacao(),
            Divider(
              color: Colors.grey,
            ),
            Container(
              child: Column(
                children: [
                  Text('Aqui vai estar a avaliação'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _escalaAvaliacao() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.only(top: 0),
            width: MediaQuery.of(context).size.width / 4,
            child: Column(
              children: [
                Icon(Icons.star),
                Text('4.8'),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width -
                MediaQuery.of(context).size.width / 4 -
                10,
            padding: EdgeInsets.only(right: 20),
            child: Column(
              children: [
                // Text('Não deveria ter erro'),
                Container(
                  // padding: EdgeInsets.all(0),
                  child: LinearPercentIndicator(
                    percent: 0.85,
                    lineHeight: 7.5,
                    progressColor: Colors.deepOrange,
                    // padding: EdgeInsets.all(5),
                    leading: Container(
                      padding: EdgeInsets.only(right: 5),
                      child: Text(
                        '5',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  // padding: EdgeInsets.all(0),
                  child: LinearPercentIndicator(
                    percent: 0.05,
                    lineHeight: 7.5,
                    progressColor: Colors.deepOrange,
                    // padding: EdgeInsets.all(5),
                    leading: Container(
                      padding: EdgeInsets.only(right: 5),
                      child: Text(
                        '4',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  // padding: EdgeInsets.all(0),
                  child: LinearPercentIndicator(
                    percent: 0.02,
                    lineHeight: 7.5,
                    progressColor: Colors.deepOrange,
                    // padding: EdgeInsets.all(10),
                    leading: Container(
                      padding: EdgeInsets.only(right: 5),
                      child: Text(
                        '3',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  // padding: EdgeInsets.all(0),
                  child: LinearPercentIndicator(
                    percent: 0.10,
                    lineHeight: 7.5,
                    progressColor: Colors.deepOrange,
                    // padding: EdgeInsets.all(10),
                    leading: Container(
                      padding: EdgeInsets.only(right: 5),
                      child: Text(
                        '2',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // widgetIndicator: Text('O que é isso?'),
                  ),
                ),
                Container(
                  // padding: EdgeInsets.all(0),
                  child: LinearPercentIndicator(
                    percent: 0.05,
                    lineHeight: 7.5,
                    progressColor: Colors.deepOrange,
                    // padding: EdgeInsets.all(10),
                    leading: Container(
                      padding: EdgeInsets.only(right: 5),
                      child: Text(
                        '1',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
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
