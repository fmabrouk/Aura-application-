import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise13 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise13({this.article, this.item, this.openMarker});

  @override
  _Balise13State createState() => _Balise13State();
}

class _Balise13State extends State<Balise13> {
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
                image: AssetImage("assets/Fondation Cartier/IMG_2195.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
