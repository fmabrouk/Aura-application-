import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise15 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise15({this.article, this.item, this.openMarker});

  @override
  _Balise15State createState() => _Balise15State();
}

class _Balise15State extends State<Balise15> {
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
                    "assets/Département des Arts de l_Islam du Louvre/PARIS_Departement-des-Arts-de-l-Islam-du-musee-du-Louvre_02b.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
