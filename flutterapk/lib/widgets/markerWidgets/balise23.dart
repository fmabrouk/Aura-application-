import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise23 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise23({this.article, this.item, this.openMarker});

  @override
  _Balise23State createState() => _Balise23State();
}

class _Balise23State extends State<Balise23> {
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
                image: AssetImage("assets/Pushed Slab/IMG_5889.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
