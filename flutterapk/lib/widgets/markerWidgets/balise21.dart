import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise21 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise21({this.article, this.item, this.openMarker});

  @override
  _Balise21State createState() => _Balise21State();
}

class _Balise21State extends State<Balise21> {
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
                    "assets/Pavillon Mobile Art Chanel/chanel_mobile_art_pavilion-zaha_hadid_2_photo AA13.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
