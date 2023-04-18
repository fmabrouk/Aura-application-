import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise1 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise1({this.article, this.item, this.openMarker});

  @override
  _Balise1State createState() => _Balise1State();
}

class _Balise1State extends State<Balise1> {
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
                  "assets/Manufacture sur Seine Quartier Terre/reinventer-seine-manufacture-seine-amateur.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
