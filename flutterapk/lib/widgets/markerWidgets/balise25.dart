import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise25 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise25({this.article, this.item, this.openMarker});

  @override
  _Balise25State createState() => _Balise25State();
}

class _Balise25State extends State<Balise25> {
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
                    "assets/Bibliothèque François Mitterand/IMG_6855.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
