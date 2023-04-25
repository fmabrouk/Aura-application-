import 'package:animated_button_bar/animated_button_bar.dart';
import 'package:aura2/models/User.dart';
import 'package:aura2/screens/carteScreen.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

import '../../screens/listeScreen.dart';

/// @return renvoie la vue d'un article
class BoutonNord extends StatefulWidget {
  BoutonNord({Key key, this.setRotationImage, this.mapController})
      : super(key: key);

  final Function setRotationImage;
  MapController mapController;

  @override
  _BoutonNordState createState() => _BoutonNordState();
}

class _BoutonNordState extends State<BoutonNord> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 34,
      top: 69,
      child: GestureDetector(
          onTap: () {
            setState(() {
              widget.mapController.rotate(0);
            });
          },
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Transform.rotate(
              angle: widget.setRotationImage(widget.mapController.rotation),
              child: Image(
                image: AssetImage('assets/location-arrow-solid copie.png'),
                color: Colors.black,
              ),
            ),
          )),
    );
  }
}
