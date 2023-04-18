import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise28 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise28({this.article, this.item, this.openMarker});

  @override
  _Balise28State createState() => _Balise28State();
}

class _Balise28State extends State<Balise28> {
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
                image: AssetImage("assets/Eden Bio/IMG_4174.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
