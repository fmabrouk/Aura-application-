import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise14 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise14({this.article, this.item, this.openMarker});

  @override
  _Balise14State createState() => _Balise14State();
}

class _Balise14State extends State<Balise14> {
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
                    "assets/Galerie Marchande Gaîté Montparnasse/03_Gaîté_Montparnasse_MVRDV_©Ossip van Duivenbode.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
