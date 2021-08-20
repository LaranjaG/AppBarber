import 'package:flutter/material.dart';

class Loadins{
  static Widget imagem(){
    return Container( //Imagem logo
      padding: EdgeInsets.only(bottom: 32),
      child: Image.network(
        "https://cdn.pixabay.com/photo/2018/03/26/18/20/man-3263509__340.png",
        height: 180,
        color: Color(0xff123456),
      ),
    );
  }

  static Widget circulo(){
    return Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.grey,
          ),
        )
    );
  }
}