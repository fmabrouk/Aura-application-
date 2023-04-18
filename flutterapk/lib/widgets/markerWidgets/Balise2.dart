import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise2 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise2({this.article, this.item, this.openMarker});

  @override
  _Balise2State createState() => _Balise2State();
}

class _Balise2State extends State<Balise2> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          widget.openMarker(widget.item);
        },
        child: Transform.scale(
          scale: 0.7,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(
                    "assets/Centre Ville de Montreuil sous Bois Alvaro Siza/Croquis Siza Centre Ville Montreuil.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
