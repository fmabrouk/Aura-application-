import 'package:aura2/models/article.dart';
import 'package:aura2/widgets/favorisWidgets/listeFavoris.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/User.dart';
import '../../models/customMarker.dart';
import '../../providers/articleProvider.dart';
import '../../screens/listeScreen.dart';
import '../../screens/parcoursScreen.dart';

class BoutonParcoursItem extends StatefulWidget {
  String dropdownValue;
  String buttonText;
  List<SavedElement> liste;
  bool showWidget;

  final bool auth;

  final User login;

  final UserCustom user;

  final Function stcokeeParcours;

  List<String> articlesParcours;

  /// Permet de savoir si la page doit être traduite en anglais
  bool trade;

  BoutonParcoursItem(
      {this.buttonText,
      this.dropdownValue,
      this.liste,
      this.showWidget = false,
      this.auth,
      this.login,
      this.trade,
      this.user,
      this.stcokeeParcours,
      this.articlesParcours});

  @override
  _BoutonParcoursItemState createState() => _BoutonParcoursItemState();
}

class _BoutonParcoursItemState extends State<BoutonParcoursItem> {
  @override
  Widget build(BuildContext context) {
    final articleListImage =
        Provider.of<ArticleProvider>(context).getAllArticlesImage().toList();

    ///Liste contenanat des articles qui possedent pas des images
    final articleListWithoutImage = Provider.of<ArticleProvider>(context)
        .getAllArticlesWithoutImage()
        .toList();

    ///Trier les articles par ordre alphabétiques selon leur titres
    articleListImage.sort(((a, b) => a.title.compareTo(b.title)));
    articleListWithoutImage.sort(((a, b) => a.title.compareTo(b.title)));
    final articleLists = articleListImage + articleListWithoutImage;

    return Stack(
      children: [
        PopupMenuButton<String>(
          onSelected: (option) async {
            setState(() {
              widget.dropdownValue = option;
              widget.buttonText = option;
              widget.showWidget = false;
            });

            for (int i = 0; i < widget.liste.length; i++) {
              if (option == widget.liste[i].text) {
                print(widget.liste[i].text);
                widget.dropdownValue = widget.liste[i].text;
                List<Article> articleListsParcours = [];
                List<String> fayez = [];
                fayez = await widget.stcokeeParcours(widget.liste[i].text);
                //print(widget.liste[i].text);
                //print(await widget.stcokeeParcours(widget.liste[i].text));
                widget.articlesParcours = fayez;
                //print(widget.articlesParcours);

                for (int k = 0; k < articleLists.length; k++) {
                  for (int m = 0; m < widget.articlesParcours.length; m++) {
                    if (widget.articlesParcours[m] == articleLists[k].id) {
                      articleListsParcours.add(articleLists[k]);
                    }
                  }
                }

                //print(articleListsParcours[0].title);
                //print(widget.dropdownValue);
                //print(widget.trade);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ParcoursScreen(
                              dropDownValue: widget.dropdownValue,
                              articless: articleListsParcours,
                              auth: true,
                              trade: widget.trade,
                            )));
              }
              if (option == 'Tous') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => listeScreen(
                              auth: true,
                              trade: widget.trade,
                            )));
              }
            }
          },
          itemBuilder: (BuildContext context) {
            List<PopupMenuEntry<String>> entries = [];
            List<String> options2 = ['Tous'];
            for (int i = 0; i < widget.liste.length; i++) {
              options2.add(widget.liste[i].text);
            }

            for (String option in options2) {
              entries.add(
                PopupMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              );
            }
            return entries;
          },
          child: Row(
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  widget.dropdownValue,
                  style: TextStyle(color: Color.fromRGBO(206, 63, 143, 1)),
                ),
              ),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ],
    );
  }
}
