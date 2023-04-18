import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise26 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise26({this.article, this.item, this.openMarker});

  @override
  _Balise26State createState() => _Balise26State();
}

class _Balise26State extends State<Balise26> {
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
                image: AssetImage("assets/Cité de la mode/IMG_7176.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
