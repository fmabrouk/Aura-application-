import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise24 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise24({this.article, this.item, this.openMarker});

  @override
  _Balise24State createState() => _Balise24State();
}

class _Balise24State extends State<Balise24> {
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
                image: AssetImage("assets/IMG_7619.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
