import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise11 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise11({this.article, this.item, this.openMarker});

  @override
  _Balise11State createState() => _Balise11State();
}

class _Balise11State extends State<Balise11> {
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
                image: AssetImage("assets/Showroom Citroën/IMG_3651.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
