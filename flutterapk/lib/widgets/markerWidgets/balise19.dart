import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise19 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise19({this.article, this.item, this.openMarker});

  @override
  _Balise19State createState() => _Balise19State();
}

class _Balise19State extends State<Balise19> {
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
                image: AssetImage("assets/La Canopée/IMG_3297.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
