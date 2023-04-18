import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise31 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise31({this.article, this.item, this.openMarker});

  @override
  _Balise31State createState() => _Balise31State();
}

class _Balise31State extends State<Balise31> {
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
                    "assets/220 Logements rue de Meaux/IMG_2681.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
