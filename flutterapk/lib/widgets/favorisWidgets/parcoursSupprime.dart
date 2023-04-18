import 'package:animated_button_bar/animated_button_bar.dart';
import 'package:aura2/models/User.dart';
import 'package:aura2/screens/carteScreen.dart';
import 'package:aura2/widgets/favorisWidgets/listeFavoris.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

import '../../screens/listeScreen.dart';

/// @return renvoie la vue d'un article
class parcoursSupprime extends StatefulWidget {
  parcoursSupprime({Key key, this.liste, this.trade, this.deleteTexte})
      : super(key: key);

  List<SavedElement> liste;
  bool trade;
  final Function deleteTexte;
  @override
  _parcoursSupprimeState createState() => _parcoursSupprimeState();
}

class _parcoursSupprimeState extends State<parcoursSupprime> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.liste.length,
        itemBuilder: (context, index) {
          final currentText = widget.liste[index].text;
          final currentTaille = widget.liste[index].taille;

          final currentColor = widget.liste[index].color;
          return Dismissible(
            key: Key(currentText),
            //Direction de droite à gauche
            direction: DismissDirection.endToStart,

            onDismissed: (direction) async {
              if (widget.trade == false) {
                bool confirmDelete = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Supprimer ce parcours ?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: Text("Non"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: Text("Oui"),
                        ),
                      ],
                    );
                  },
                );
                if (confirmDelete == true) {
                  // delete the text
                  widget.deleteTexte(currentText);
                  // delete the corresponding elements from the list
                  widget.liste.remove(currentText);
                  widget.liste.remove(currentTaille);
                  widget.liste.remove(currentColor);
                } else {
                  // if the user cancels the deletion, simply rebuild the widget to show the text again
                  // setState(() {});
                  Navigator.pop(context, false);
                  //return false;
                }
              } else {
                bool confirmDelete = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Do you want to delete this list ?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: Text("No"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: Text("Yes"),
                        ),
                      ],
                    );
                  },
                );
                if (confirmDelete == true) {
                  // delete the text
                  widget.deleteTexte(currentText);
                  // delete the corresponding elements from the list
                  widget.liste.remove(currentText);
                  widget.liste.remove(currentTaille);
                  widget.liste.remove(currentColor);
                } else {
                  // if the user cancels the deletion, simply rebuild the widget to show the text again
                  setState(() {});
                }
              }
            },
            background: Container(
              color: Colors.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),

            // le container du bouton text
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextButton(
                onPressed: () async {},
                child: Row(
                  children: [
                    Container(
                      width: 25.0,
                      height: 25.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: currentColor),
                      child: Center(
                        child: Text(
                          currentTaille,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentText,
                          style: TextStyle(
                              fontFamily: 'myriad',
                              fontSize: 18,
                              color: currentColor),
                        ),
                      ],
                    ))
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
