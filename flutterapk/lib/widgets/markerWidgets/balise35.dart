import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise35 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise35({this.article, this.item, this.openMarker});

  @override
  _Balise35State createState() => _Balise35State();
}

class _Balise35State extends State<Balise35> {
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
                image: AssetImage("assets/Tower Flower/IMG_0269.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
