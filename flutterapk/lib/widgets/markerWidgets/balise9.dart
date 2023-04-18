import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise9 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise9({this.article, this.item, this.openMarker});

  @override
  _Balise9State createState() => _Balise9State();
}

class _Balise9State extends State<Balise9> {
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
                image: AssetImage("assets/Musée Quai Branly/IMG_3690.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
