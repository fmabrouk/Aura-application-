import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise12 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise12({this.article, this.item, this.openMarker});

  @override
  _Balise12State createState() => _Balise12State();
}

class _Balise12State extends State<Balise12> {
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
                    "assets/57 logements - Herzog et Demeuron/IMG_2681.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
