import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../providers/favoriteProvider.dart';
import 'favoriItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customMarker.dart';

/// Represente la fenetre 'liste des favoris'
class ListFavoris extends StatefulWidget {
  /// Afficher l'article
  final Function afficherArticle;

  /// Ferme la fenetre 'liste des favoris'
  final Function showMap;

  /// Centre la carte sur le marqueur
  final Function centerMarker;

  /// Permet de savoir si la page doit être traduite en anglais
  bool trade;

  ListFavoris(
      {this.afficherArticle, this.showMap, this.centerMarker, this.trade});

  @override
  State<StatefulWidget> createState() {
    return new ListFavorisState();
  }
}

class ListFavorisState extends State<ListFavoris> {
  Map<String, List<CustomMarker>> subFavoriteLists = {};

//liste contenant titre et couleur
  List<SavedElement> savedElements = [];

  Color textColor = Colors.black;

  void changeTextColor(Color color) {
    setState(() {
      textColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Liste des marquers avec l'attribut isFavorite à true
    final articleList =
        Provider.of<FavoriteProvider>(context).markers.reversed.toList();

    final TextEditingController _textEditingController =
        TextEditingController();

    return Dismissible(
        movementDuration: Duration(seconds: 1),
        key: Key("key"),
        direction: DismissDirection.vertical,
        onDismissed: (value) {
          widget.showMap();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  widget.showMap();
                },
                child: Container(
                  color: Colors.transparent,
                ),
              )),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.74,
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Header
                    Container(
                      width: double.infinity,
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // ajouter cet attribut pour centrer l'icône à droite
                        children: [
                          Container(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.favorite,
                                size: 17,
                                color: Colors.red,
                              )),
                          Container(
                              padding: EdgeInsets.all(3),
                              child: !widget.trade
                                  ? Text(
                                      'Lieux sauvegardés',
                                      style: TextStyle(fontFamily: 'myriad'),
                                    )
                                  : Text(
                                      'Favorites',
                                      style: TextStyle(fontFamily: 'myriad'),
                                    )),
                          // button, Fenetre, icon parcours
                          IconButton(
                            icon: Icon(Icons.menu_book),
                            color: Colors.deepPurple,
                            onPressed: () {
                              return showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '   Tous les parcours',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: 'myriad',
                                              ),
                                            ),
                                            SingleChildScrollView(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Nom du parcours'),
                                                        content:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              TextField(
                                                                controller:
                                                                    _textEditingController,
                                                                decoration:
                                                                    InputDecoration(
                                                                        hintText:
                                                                            'Entrez le texte ici'),
                                                              ),
                                                              SizedBox(
                                                                  height: 10),
                                                              Text(
                                                                  'Couleur du texte :'),
                                                              SizedBox(
                                                                  height: 10),
                                                              ColorPicker(
                                                                pickerColor:
                                                                    textColor,
                                                                onColorChanged:
                                                                    changeTextColor,
                                                                pickerAreaHeightPercent:
                                                                    0.8,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            child:
                                                                Text('Annuler'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: Text('OK'),
                                                            onPressed: () {
                                                              // Sauvegarde du texte entré
                                                              final newText =
                                                                  _textEditingController
                                                                      .text;

                                                              if (newText
                                                                  .isNotEmpty) {
                                                                savedElements.add(
                                                                    SavedElement(
                                                                        newText,
                                                                        textColor,
                                                                        '0',
                                                                        false));
                                                              }
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Text(
                                                  '+ Parcours',
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 33, 44, 243)),
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: savedElements.length,
                                          itemBuilder: (context, index) {
                                            final currentText =
                                                savedElements[index].text;
                                            final currentColor =
                                                savedElements[index].color;
                                            return Dismissible(
                                              key: Key(currentText),
                                              //Direction de droite à gauche
                                              direction:
                                                  DismissDirection.endToStart,
                                              onDismissed: (direction) {
                                                // Suppression du texte sauvegardé

                                                savedElements
                                                    .remove(currentText);
                                              },
                                              background: Container(
                                                color: Colors.red,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
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
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10),
                                                child: TextButton(
                                                  onPressed: () {
                                                    // TODO: ajouter le code à exécuter lorsque le bouton est pressé
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 25.0,
                                                        height: 25.0,
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color:
                                                                currentColor),
                                                        child: Center(
                                                          child: Text(
                                                            '0',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 16),
                                                      Expanded(
                                                          child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            currentText,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'myriad',
                                                                fontSize: 18,
                                                                color:
                                                                    currentColor),
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
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    /// Body
                    Expanded(
                      child: Scrollbar(
                        child: ListView.builder(
                            itemCount: articleList.length,
                            itemBuilder: (ctx, index) => Column(
                                  children: [
                                    FavoriItem(
                                      afficherArticle: widget.afficherArticle,
                                      marker: articleList[index],
                                      centerMarker: widget.centerMarker,
                                      trade: widget.trade,
                                    ),
                                    Divider(
                                      color: Colors.black26,
                                      height: 4,
                                      endIndent: 40,
                                      indent: 40,
                                      thickness: 1,
                                    )
                                  ],
                                )),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    )
                    // ),
                  ],
                ),
                color: Colors.white,
              ),
            ],
          ),
        ));
  }
}

class SavedElement {
  final String text;
  final Color color;
  final String taille;
  bool trade;
  SavedElement(this.text, this.color, this.taille, this.trade);
}

class SavedTaille {
  final String text;
  final String taille;

  SavedTaille(this.text, this.taille);
}
