import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise30 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise30({this.article, this.item, this.openMarker});

  @override
  _Balise30State createState() => _Balise30State();
}

class _Balise30State extends State<Balise30> {
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
                    "assets/Cité de la mode/Le Parc Lavillette/IMG_4727.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
