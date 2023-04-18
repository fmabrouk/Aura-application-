import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise7 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise7({this.article, this.item, this.openMarker});

  @override
  _Balise7State createState() => _Balise7State();
}

class _Balise7State extends State<Balise7> {
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
                    AssetImage("assets/La Tour Triangle/La Tour Triangle.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
