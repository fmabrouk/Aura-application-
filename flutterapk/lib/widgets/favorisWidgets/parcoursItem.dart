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
  ParcoursItem(
      {this.taille,
      this.liste,
      this.deleteTexte,
      this.fonctionStcokeIdArticle,
      this.deleteItem,
      this.idMarker});
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
              // Suppression du texte sauvegardé
              widget.deleteTexte(currentText);

              widget.liste.remove(currentText);

              widget.liste.remove(currentColor);
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
