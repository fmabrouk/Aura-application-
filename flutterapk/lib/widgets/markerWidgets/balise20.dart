import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise20 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise20({this.article, this.item, this.openMarker});

  @override
  _Balise20State createState() => _Balise20State();
}

class _Balise20State extends State<Balise20> {
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
                image: AssetImage("assets/IMG_3353.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
