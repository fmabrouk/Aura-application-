import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise3 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise3({this.article, this.item, this.openMarker});

  @override
  _Balise3State createState() => _Balise3State();
}

class _Balise3State extends State<Balise3> {
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
                image: AssetImage("assets/La Grande Arche/IMG_3992.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
