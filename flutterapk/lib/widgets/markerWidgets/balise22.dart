import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise22 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise22({this.article, this.item, this.openMarker});

  @override
  _Balise22State createState() => _Balise22State();
}

class _Balise22State extends State<Balise22> {
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
                image: AssetImage("assets/téléchargement (1).jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
