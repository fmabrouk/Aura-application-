import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'authentificationScreen/LoginScreen.dart';
import 'authentificationScreen/SignScreen.dart';
import 'meconnecter.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home.dart';

  /// Permet de savoir si la page doit être traduite en anglais
  bool trade = false;
  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    Future<bool> recupereValeurTrade(bool trade) async {
      final docRef = FirebaseFirestore.instance
          .collection('utilisateur')
          .doc(FirebaseAuth.instance.currentUser.uid);
      docRef.get().then((doc) {
        if (doc.exists) {
          trade = doc.data()['trade'];
          // utilisez la variable 'trade' ici
          print(trade);
          //return trade;
        }
      });
    }

    //recupereValeurTrade(widget.trade);
    return Scaffold(
        body: SafeArea(
            child: Stack(
      children: <Widget>[
        Positioned.fill(
          //
          child: Image(
            image: AssetImage('assets/images/carte_earth_large.png'),
            fit: BoxFit.cover,
          ),
        ),
        Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 20.0,
              ),
              Container(
                  alignment: Alignment.center,
                  width: 340,
                  child: Text(
                    'AURA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'myriad',
                    ),
                  )),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 20, 20, 0),
          alignment: Alignment.topRight,
          child: GestureDetector(
              onTap: () {
                setState(() {
                  widget.trade = !widget.trade;
                });
              },
              child: Text(
                widget.trade ? 'FR' : 'EN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'myriad',
                ),
              )),
        ),
        Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                width: 340,
                child: GestureDetector(
                    child: Image(
                      image: AssetImage(!widget.trade
                          ? 'assets/images/AURA_bouton_me_connecter.png'
                          : 'assets/images/AURA - bouton me connecter_EN.png'),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginScreen(
                                  trade: widget.trade,
                                )),
                      );
                    }),
              ),
              SizedBox(
                height: 15.0,
              ),
              Container(
                alignment: Alignment.center,
                width: 340,
                child: GestureDetector(
                    child: Image(
                      image: AssetImage(!widget.trade
                          ? 'assets/images/AURA_bouton_minscrire.png'
                          : 'assets/images/AURA - bouton m\'inscrire_EN.png'),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignScreen(
                                  trade: widget.trade,
                                )),
                      );
                    }),
              ),
              SizedBox(
                height: 100.0,
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                alignment: Alignment.center,
                width: 340,
                child: GestureDetector(
                    child: Image(
                      image: AssetImage(!widget.trade
                          ? 'assets/images/AURA_bouton_connecte_ plus_tard.png'
                          : 'assets/images/AURA - bouton connecter plus tard_EN.png'),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => meconnecter(
                                  auth: false,
                                  trade: false,
                                )),
                      );
                    }),
              ),
              SizedBox(
                height: 100.0,
              ),
            ],
          ),
        ),
      ],
    )));
  }
}
