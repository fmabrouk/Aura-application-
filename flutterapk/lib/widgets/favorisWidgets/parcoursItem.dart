import 'package:flutter/material.dart';

import '../markerWidgets/articleItem.dart';

/// @return renvoie la vue d'un article
class ParcoursItem extends StatefulWidget {
  int taille;
  List<SavedElement> liste;
  final Function deleteTexte;
  final Function fonctionStcokeIdArticle;
  final Function deleteItem;
  String idMarker;
  bool trade;
  ParcoursItem(
      {this.taille,
      this.liste,
      this.deleteTexte,
      this.fonctionStcokeIdArticle,
      this.deleteItem,
      this.idMarker,
      this.trade});
  @override
  _ParcoursItemState createState() => _ParcoursItemState();
}

class _ParcoursItemState extends State<ParcoursItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.taille,
        itemBuilder: (context, index) {
          final currentText = widget.liste[index].text;

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
                  //widget.liste.remove(currentTaille);
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
                  //widget.liste.remove(currentTaille);
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

            child: CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: Row(
                  children: [
                    Text(
                      widget.liste[index].text,
                      style: TextStyle(color: widget.liste[index].color),
                    ),
                  ],
                ),
                value: widget.liste[index].selected,
                onChanged: (value) {
                  setState(() {
                    widget.liste[index].selected = value;
                  });

                  if (widget.liste[index].selected) {
                    widget.fonctionStcokeIdArticle(
                        widget.liste[index].text, widget.idMarker);
                  } else {
                    widget.deleteItem(
                        widget.idMarker, widget.liste[index].text);
                  }
                }),
          );
        },
      ),
    );
  }
}
