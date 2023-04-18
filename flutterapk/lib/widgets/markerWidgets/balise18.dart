import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise18 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise18({this.article, this.item, this.openMarker});

  @override
  _Balise18State createState() => _Balise18State();
}

class _Balise18State extends State<Balise18> {
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
                image: AssetImage("assets/téléchargement.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
