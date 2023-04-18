import 'package:aura2/models/article.dart';

import 'package:flutter/material.dart';

import '../../models/customMarker.dart';

class Balise32 extends StatefulWidget {
  Article article;
  final Function openMarker;
  CustomMarker item;
  Balise32({this.article, this.item, this.openMarker});

  @override
  _Balise32State createState() => _Balise32State();
}

class _Balise32State extends State<Balise32> {
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
                image:
                    AssetImage("assets/Siège Parti Communiste/IMG_4383.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
