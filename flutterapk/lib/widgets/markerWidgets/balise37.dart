import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise37 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise37({this.article, this.item, this.openMarker});

  @override
  _Balise37State createState() => _Balise37State();
}

class _Balise37State extends State<Balise37> {
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
                image: AssetImage("assets/Institut Monde Arabe/IMG_8831.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
