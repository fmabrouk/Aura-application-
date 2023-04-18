import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise38 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise38({this.article, this.item, this.openMarker});

  @override
  _Balise38State createState() => _Balise38State();
}

class _Balise38State extends State<Balise38> {
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
                image: AssetImage(
                    "assets/Cité de la mode/Le Tribunal de Paris/IMG_0321.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
