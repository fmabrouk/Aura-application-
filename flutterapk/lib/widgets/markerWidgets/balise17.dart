import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise17 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise17({this.article, this.item, this.openMarker});

  @override
  _Balise17State createState() => _Balise17State();
}

class _Balise17State extends State<Balise17> {
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
                    "assets/La Nouvelle Saint Maritaine - SANAA/IMG_3967.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
