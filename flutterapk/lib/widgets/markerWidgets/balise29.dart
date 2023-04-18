import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise29 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise29({this.article, this.item, this.openMarker});

  @override
  _Balise29State createState() => _Balise29State();
}

class _Balise29State extends State<Balise29> {
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
                image: AssetImage("assets/La Philharmonie/IMG_4684.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
