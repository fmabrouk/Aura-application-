import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise27 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise27({this.article, this.item, this.openMarker});

  @override
  _Balise27State createState() => _Balise27State();
}

class _Balise27State extends State<Balise27> {
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
                    "assets/La Cinémathèque Française/IMG_8448.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
