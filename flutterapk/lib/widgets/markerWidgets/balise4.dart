import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise4 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise4({this.article, this.item, this.openMarker});

  @override
  _Balise4State createState() => _Balise4State();
}

class _Balise4State extends State<Balise4> {
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
                image:
                    AssetImage("assets/Fondation Louis Vuitton/IMG_1330.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
