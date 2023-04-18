import 'package:flutter/material.dart';
import '../../models/customMarker.dart';
import '../favorisWidgets/favoriItem.dart';


/// la classe de la liste des parcours / favoris
class FenetreParcours {

  /// Permet de savoir si la page doit être traduite en anglais
  bool trade;

  /// La liste de parcours
  static List<String> savedTexts =[];

  ///Affiche la fenêtre des parcours
  static void show(BuildContext context, Widget widgetToShow) {
    final TextEditingController _textEditingController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '   Tous les parcours',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'myriad',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Nom du parcours'),
                            content: TextField(
                              controller: _textEditingController,
                              decoration: InputDecoration(hintText: 'Entrez le texte ici'),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Annuler'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  // Sauvegarde du texte entré
                                  final newText = _textEditingController.text;
                                  if (newText.isNotEmpty) {
                                    savedTexts.add(newText);
                                  }
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      '+Parcours',
                      style: TextStyle(
                        fontFamily: 'myriad',
                        fontSize: 20,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: savedTexts.length,
                itemBuilder: (context, index) {
                  final currentText = savedTexts[index];
                  return Dismissible(
                    key: Key(currentText),
                    //Direction de droite à gauche
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      // Suppression du texte sauvegardé
                      savedTexts.remove(currentText);
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
                        onPressed: () {
                          // TODO: ajouter le code à exécuter lorsque le bouton est pressé
                        },
                        child: Text(
                          currentText,
                          style: TextStyle(
                            fontFamily: 'myriad',
                            fontSize: 18,
                          ),
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
  }
}