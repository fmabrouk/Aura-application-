import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise34 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise34({this.article, this.item, this.openMarker});

  @override
  _Balise34State createState() => _Balise34State();
}

class _Balise34State extends State<Balise34> {
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
                image: AssetImage("assets/Emergence/IMG_0324.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
