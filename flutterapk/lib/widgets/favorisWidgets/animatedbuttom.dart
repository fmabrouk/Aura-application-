import 'package:animated_button_bar/animated_button_bar.dart';
import 'package:aura2/models/User.dart';
import 'package:aura2/screens/carteScreen.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import '../../screens/listeScreen.dart';

/// @return renvoie la vue d'un article
class AnimatedButtom extends StatefulWidget {
  AnimatedButtom({Key key, this.auth, this.login, this.trade, this.user})
      : super(key: key);
  final bool auth;

  final User login;

  final UserCustom user;

  bool trade;

  @override
  _AnimatedButtomState createState() => _AnimatedButtomState();
}

class _AnimatedButtomState extends State<AnimatedButtom> {
  Color _firstButtonColor = Colors.white;
  Color _secondButtonColor = Color.fromRGBO(206, 63, 143, 1);
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 120,
      child: Container(
        width: 180,
        height: 70,
        child: AnimatedButtonBar(
          radius: 32.0,
          padding: const EdgeInsets.all(16.0),
          backgroundColor: Colors.white,
          foregroundColor: Color.fromRGBO(206, 63, 143, 1),
          elevation: 0,
          borderColor: Color.fromRGBO(206, 63, 143, 1),
          borderWidth: 2,
          innerVerticalPadding: 0,
          children: [
            ButtonBarEntry(
              onTap: () {
                setState(() {
                  _firstButtonColor = Colors.white;
                  _secondButtonColor = Color.fromRGBO(206, 63, 143, 1);
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CarteScreen(
                            auth: widget.auth,
                            trade: widget.trade,
                            user: widget.user,
                            login: widget.login,
                          )),
                );
              },
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Text(
                    'Carte',
                    style: TextStyle(color: _firstButtonColor, fontSize: 14),
                  ),
                ],
              ),
            ),
            ButtonBarEntry(
              onTap: () {
                setState(() {
                  _firstButtonColor = Color.fromRGBO(206, 63, 143, 1);
                  _secondButtonColor = Colors.white;
                });
                ;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => listeScreen(
                            auth: widget.auth,
                            user: widget.user,
                            login: widget.login,
                            trade: widget.trade,
                          )),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    'Liste',
                    style: TextStyle(color: _secondButtonColor, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
