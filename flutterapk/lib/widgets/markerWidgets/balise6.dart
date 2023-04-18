import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise6 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise6({this.article, this.item, this.openMarker});

  @override
  _Balise6State createState() => _Balise6State();
}

class _Balise6State extends State<Balise6> {
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
                image: AssetImage("assets/IMG_2083.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
