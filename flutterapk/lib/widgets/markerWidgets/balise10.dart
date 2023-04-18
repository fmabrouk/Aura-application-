import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise10 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise10({this.article, this.item, this.openMarker});

  @override
  _Balise10State createState() => _Balise10State();
}

class _Balise10State extends State<Balise10> {
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
                    "assets/Espace de Méditation UNESCO - Tadao Ando/IMG_3819.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
