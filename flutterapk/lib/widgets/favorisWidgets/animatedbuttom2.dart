import 'package:animated_button_bar/animated_button_bar.dart';
import 'package:aura2/models/User.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import '../../screens/authentificationScreen/LoginScreen.dart';

/// @return renvoie la vue d'un article
class AnimatedButtom2 extends StatefulWidget {
  AnimatedButtom2({Key key, this.auth, this.login, this.trade, this.user})
      : super(key: key);
  final bool auth;

  final User login;

  final UserCustom user;

  bool trade;

  @override
  _AnimatedButtom2State createState() => _AnimatedButtom2State();
}

class _AnimatedButtom2State extends State<AnimatedButtom2> {
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
                        builder: (context) => LoginScreen(
                              trade: widget.trade,
                            )),
                  );
                },
                child: !widget.trade
                    ? Column(
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'Carte',
                            style: TextStyle(
                                color: _firstButtonColor, fontSize: 14),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'Map',
                            style: TextStyle(
                                color: _firstButtonColor, fontSize: 14),
                          ),
                        ],
                      )),
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
                        builder: (context) => LoginScreen(
                              trade: widget.trade,
                            )),
                  );
                },
                child: !widget.trade
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'Liste',
                            style: TextStyle(
                                color: _secondButtonColor, fontSize: 14),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'List',
                            style: TextStyle(
                                color: _secondButtonColor, fontSize: 14),
                          ),
                        ],
                      )),
          ],
        ),
      ),
    );
  }
}
