import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise33 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise33({this.article, this.item, this.openMarker});

  @override
  _Balise33State createState() => _Balise33State();
}

class _Balise33State extends State<Balise33> {
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
                    "assets/La Tour Bois Le Prêtre - Lacaton Vassal/IMG_0689.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
