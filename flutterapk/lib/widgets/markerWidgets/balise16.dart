import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise16 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise16({this.article, this.item, this.openMarker});

  @override
  _Balise16State createState() => _Balise16State();
}

class _Balise16State extends State<Balise16> {
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
                image: AssetImage("assets/La Pyramide du Louvre/IMG_3222.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
