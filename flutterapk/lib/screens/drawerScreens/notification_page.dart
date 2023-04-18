import 'package:aura2/FirebaseMessaging.dart';
import 'package:aura2/widgets/customAppBar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/User.dart';

class NotificationsPage1 extends StatefulWidget {
  static const routeName = '/notifications.dart';

  /// Permet de savoir si la page doit être traduite en anglais
  bool trade;
  final UserCustom user;
  final Function(int) rangeCallBack;

  NotificationsPage1({Key key, this.rangeCallBack, this.trade, this.user})
      : super(key: key);

  @override
  NotificationsPage1State createState() => NotificationsPage1State();
}

int cent = 100;
int trente = 30;

enum Range { cent, troiscents }

enum Freq { q, h, m }

class NotificationsPage1State extends State<NotificationsPage1> {
  Range _range = Range.cent;
  Freq _freq = Freq.q;

  ///renvoie l'utilisateur courant
  // UserCustom user = FirebaseAuth.instance.currentUser;

  //Initialise le topic
  subscribe() async {
    !widget.trade
        ? {
            await FirebaseMessaging.instance
                .unsubscribeFromTopic(_freq.toString() + "en"),
            await FirebaseMessaging.instance.subscribeToTopic(_freq.toString())
          }
        : {
            await FirebaseMessaging.instance
                .unsubscribeFromTopic(_freq.toString()),
            await FirebaseMessaging.instance
                .subscribeToTopic(_freq.toString() + "en")
          };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Notifications',
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'myriad',
              color: Color.fromRGBO(209, 62, 150, 1),
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          leading: CustomAppBar(from: ''),
          leadingWidth: 41,
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('utilisateur')
                .doc(FirebaseAuth.instance.currentUser.uid)
                .get()
                .asStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                snapshot.data.get('range')
                    ? _range = Range.troiscents
                    : _range = Range.cent;

                if (snapshot.data.get('freq') == 0) _freq = Freq.q;
                if (snapshot.data.get('freq') == 1) _freq = Freq.h;
                if (snapshot.data.get('freq') == 2) _freq = Freq.m;

                subscribe();

                return Column(children: [
                  FirebaseMessagingDemo(),
                  SizedBox(
                    height: 50,
                  ),
                  ExpansionTile(
                    title: Text(
                      !widget.trade ? 'Géolocalisation' : 'Geolocation',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    children: <Widget>[
                      ListTile(
                        minVerticalPadding: 0,
                        title: Text(
                          !widget.trade ? '100 mètres' : '100 meters',
                          style: TextStyle(
                            color: Colors.blueGrey,
                          ),
                        ),
                        onTap: () => {
                          if (widget.user != null)
                            FirebaseFirestore.instance
                                .collection('utilisateur')
                                .doc(FirebaseAuth.instance.currentUser.uid)
                                .update({'range': false}),
                          setState(() {
                            _range = Range.cent;
                          })
                        },
                        trailing: Radio<Range>(
                          activeColor: Color.fromRGBO(209, 62, 150, 1),
                          value: Range.cent,
                          groupValue: _range,
                          onChanged: (Range value) {
                            setState(() {
                              _range = value;
                            });

                            /// Met à jour le range de l'utilisateur
                            if (widget.user != null) {
                              FirebaseFirestore.instance
                                  .collection('utilisateur')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .update({'range': false});
                            }
                          },
                        ),
                      ),
                      ListTile(
                          minVerticalPadding: 0,
                          title: Text(
                            !widget.trade ? '300 mètres' : '300 meters',
                            style: TextStyle(
                              color: Colors.blueGrey,
                            ),
                          ),
                          onTap: () => {
                                if (widget.user != null)
                                  FirebaseFirestore.instance
                                      .collection('utilisateur')
                                      .doc(
                                          FirebaseAuth.instance.currentUser.uid)
                                      .update({'range': true}),
                                setState(() {
                                  _range = Range.troiscents;
                                })
                              },
                          trailing: Radio<Range>(
                              activeColor: Color.fromRGBO(209, 62, 150, 1),
                              value: Range.troiscents,
                              groupValue: _range,
                              onChanged: (Range value) {
                                setState(() {
                                  _range = value;
                                });

                                /// Met à jour le range de l'utilisateur
                                if (widget.user != null) {
                                  FirebaseFirestore.instance
                                      .collection('utilisateur')
                                      .doc(
                                          FirebaseAuth.instance.currentUser.uid)
                                      .update({'range': true});
                                }
                              })),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      !widget.trade ? 'Fréquence' : 'Frequency',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    children: <Widget>[
                      ListTile(
                        minVerticalPadding: 0,
                        title: Text(
                          !widget.trade ? 'Quotidienne' : 'Daily',
                          style: TextStyle(
                            color: Colors.blueGrey,
                          ),
                        ),
                        onTap: () async {
                          await FirebaseMessaging.instance
                              .unsubscribeFromTopic(_freq.toString());
                          await FirebaseMessaging.instance
                              .unsubscribeFromTopic(_freq.toString() + "en");
                          if (widget.user != null)
                            FirebaseFirestore.instance
                                .collection('utilisateur')
                                .doc(FirebaseAuth.instance.currentUser.uid)
                                .update({'freq': 0});
                          setState(() {
                            _freq = Freq.q;
                          });
                          !widget.trade
                              ? await FirebaseMessaging.instance
                                  .subscribeToTopic(_freq.toString())
                              : await FirebaseMessaging.instance
                                  .subscribeToTopic(_freq.toString() + "en");
                        },
                        trailing: Radio<Freq>(
                          activeColor: Color.fromRGBO(209, 62, 150, 1),
                          value: Freq.q,
                          groupValue: _freq,
                          onChanged: (Freq value) async {
                            await FirebaseMessaging.instance
                                .unsubscribeFromTopic(_freq.toString());
                            await FirebaseMessaging.instance
                                .unsubscribeFromTopic(_freq.toString() + "en");
                            setState(() {
                              _freq = value;
                            });
                            !widget.trade
                                ? await FirebaseMessaging.instance
                                    .subscribeToTopic(_freq.toString())
                                : await FirebaseMessaging.instance
                                    .subscribeToTopic(_freq.toString() + "en");

                            /// Met à jour le range de l'utilisateur
                            if (widget.user != null) {
                              FirebaseFirestore.instance
                                  .collection('utilisateur')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .update({'freq': 0});
                            }
                          },
                        ),
                      ),
                      ListTile(
                          minVerticalPadding: 0,
                          title: Text(
                            !widget.trade ? 'Hebdomadaire' : 'Weekly',
                            style: TextStyle(
                              color: Colors.blueGrey,
                            ),
                          ),
                          onTap: () async {
                            await FirebaseMessaging.instance
                                .unsubscribeFromTopic(_freq.toString());
                            await FirebaseMessaging.instance
                                .unsubscribeFromTopic(_freq.toString() + "en");
                            if (widget.user != null)
                              FirebaseFirestore.instance
                                  .collection('utilisateur')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .update({'freq': 1});

                            setState(() {
                              _freq = Freq.h;
                            });
                            !widget.trade
                                ? await FirebaseMessaging.instance
                                    .subscribeToTopic(_freq.toString())
                                : await FirebaseMessaging.instance
                                    .subscribeToTopic(_freq.toString() + "en");
                          },
                          trailing: Radio<Freq>(
                              activeColor: Color.fromRGBO(209, 62, 150, 1),
                              value: Freq.h,
                              groupValue: _freq,
                              onChanged: (Freq value) async {
                                await FirebaseMessaging.instance
                                    .unsubscribeFromTopic(_freq.toString());
                                await FirebaseMessaging.instance
                                    .unsubscribeFromTopic(
                                        _freq.toString() + "en");
                                setState(() {
                                  _freq = value;
                                });
                                !widget.trade
                                    ? await FirebaseMessaging.instance
                                        .subscribeToTopic(_freq.toString())
                                    : await FirebaseMessaging.instance
                                        .subscribeToTopic(
                                            _freq.toString() + "en");

                                /// Met à jour le range de l'utilisateur
                                if (widget.user != null) {
                                  FirebaseFirestore.instance
                                      .collection('utilisateur')
                                      .doc(
                                          FirebaseAuth.instance.currentUser.uid)
                                      .update({'freq': 1});
                                }
                              })),
                      ListTile(
                          minVerticalPadding: 0,
                          title: Text(
                            !widget.trade ? 'Mensuelle' : 'Monthly',
                            style: TextStyle(
                              color: Colors.blueGrey,
                            ),
                          ),
                          onTap: () async {
                            await FirebaseMessaging.instance
                                .unsubscribeFromTopic(_freq.toString());
                            await FirebaseMessaging.instance
                                .unsubscribeFromTopic(_freq.toString() + "en");
                            if (widget.user != null)
                              FirebaseFirestore.instance
                                  .collection('utilisateur')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .update({'freq': 2});
                            setState(() {
                              _freq = Freq.m;
                            });
                            !widget.trade
                                ? await FirebaseMessaging.instance
                                    .subscribeToTopic(_freq.toString())
                                : await FirebaseMessaging.instance
                                    .subscribeToTopic(_freq.toString() + "en");
                          },
                          trailing: Radio<Freq>(
                              activeColor: Color.fromRGBO(209, 62, 150, 1),
                              value: Freq.m,
                              groupValue: _freq,
                              onChanged: (Freq value) async {
                                await FirebaseMessaging.instance
                                    .unsubscribeFromTopic(_freq.toString());
                                await FirebaseMessaging.instance
                                    .unsubscribeFromTopic(
                                        _freq.toString() + "en");
                                setState(() {
                                  _freq = value;
                                });
                                !widget.trade
                                    ? await FirebaseMessaging.instance
                                        .subscribeToTopic(_freq.toString())
                                    : await FirebaseMessaging.instance
                                        .subscribeToTopic(
                                            _freq.toString() + "en");

                                /// Met à jour le range de l'utilisateur
                                if (widget.user != null) {
                                  FirebaseFirestore.instance
                                      .collection('utilisateur')
                                      .doc(
                                          FirebaseAuth.instance.currentUser.uid)
                                      .update({'freq': 2});
                                }
                              })),
                    ],
                  ),
                ]);
              } else
                return Center(child: CircularProgressIndicator());
            }));
  }
}
