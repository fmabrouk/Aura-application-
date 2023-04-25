import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/customMarker.dart';
import '../../models/tag.dart';
import '../../providers/markerProvider.dart';
import '../../providers/tagProvider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../models/article.dart';
import '../../providers/articleProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

import '../audioWidgets/audio.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../favorisWidgets/parcoursItem.dart';

/// @return renvoie la vue d'un article
class ArticleItem extends StatefulWidget {
  /// Article à afficher
  final Article article;

  /// Function permettant le changement de l'attribut isFavorite d'un marqueur
  final Function changeFavorite;

  final Function deleteItem;

  /// Function permettant le changement de l'attribut isFavorite d'un marqueur
  final Function changeArrondissement;

  //Etat du bouton Parcours
  final List<bool> options1;

  /// Identifiant du marqueur à changer
  final String idMaker;

  /// Etat du bouton Favori
  final bool like;

  ///  Affiche l'écran des commentaires
  final Function switchToComm;

  /// Permet de savoir si l'on est passée d'un article à l'autre
  final bool switchArticle;

  final Function switchFalse;

  /// Permet de savoir si la page doit être traduite en anglais
  bool trade;

  //Snapshot d'où provient l'audio
  final String snapshot;

  //Permet de savoir si le popUp est lancé ou non
  final bool lance;

  //Fonction callBack qui permet de "faire remonter" les données d'un article vers "CarteScreen"
  final Function(Article, AudioPlayer, bool, String) articleCallback;

  //L'audioPlayer qui permet de jouer/mettre en pause un article
  final AudioPlayer audioPlayer;

  //Permet de savoir si l'audio est en cours ou non
  final bool audioState;

  //Un second article
  final Article secondArticle;

  //Fonction callBack qui permet de renvoyer le booleen vers CarteScreen permettant de savoir si le popUp est ouvert
  final Function(bool) isPopUpOpen;

  //Permet de sauvegarder la durée max d'un audio
  final Duration savedMaxDuration;

  //Permet de sauvegarder la position d'un audio
  final Duration savedPosition;

  //Fonction callBack permettant de remonter les données de savedPosition et savedMaxPosition vers CarteScreen
  final Function(Duration, Duration) updateDuration;

  //Le bool qui permet de savoir si on lance un article pour la première fois
  final bool firstLaunchOfArticle;

  //Permet de set le bool à true
  final Function setFirstLaunchOfArticle;

  //Fonction qui permet d'ouvrir un article depuis le popupp audio
  final Function afficherArticle;

  //Le marker conrrespondant à l'article courant
  final CustomMarker marker;

  //Fonction pour actualiser le marker utilisé dans audioBottomBar
  final Function(CustomMarker) updateMarkerForPopUp;

  //La fonction qui permet de lancer l'audio
  final Function play;

  //La fonction qui permet de pause l'audio
  final Function pausePlayer;

  //La fonction qui permet d'areter l'audio
  final Function stopPlayer;

  //Les markers de l'application
  final MarkerProvider markersData;

  //Les articles de l'application
  final ArticleProvider articlesData;

  ArticleItem(
      {this.article,
      this.changeFavorite,
      this.deleteItem,
      this.idMaker,
      this.switchFalse,
      this.like,
      this.switchArticle,
      this.switchToComm,
      this.articleCallback,
      this.snapshot,
      this.lance,
      this.audioPlayer,
      this.audioState,
      this.trade,
      this.secondArticle,
      this.isPopUpOpen,
      this.savedMaxDuration,
      this.savedPosition,
      this.updateDuration,
      this.firstLaunchOfArticle,
      this.setFirstLaunchOfArticle,
      this.afficherArticle,
      this.marker,
      this.updateMarkerForPopUp,
      this.pausePlayer,
      this.play,
      this.stopPlayer,
      this.articlesData,
      this.markersData,
      this.changeArrondissement,
      this.options1});
  @override
  _ArticleItemState createState() => _ArticleItemState();
}

class _ArticleItemState extends State<ArticleItem> {
  Article article;

  /// Taille du titre
  double _sizeTitre = 20;

  /// Taille de l'info
  double _sizeInfo = 16;

  /// Taille de l'introduction
  double _sizeIntro = 18;

  /// Taille du text
  double _sizeText = 17;

  /// Echelle du slide
  final double _scale = 0.05;

  // Le nouvel article qui sera retourner dans carteScreen
  Article newArticle;

  //La nouvelle snapshot qui sera retourné dans carteScreen
  String newSnapshot;

  // Savoir si c'est un nouvel audio ou pas
  bool newAudio = false;

  // Le nouveau state qui sera retourner dans carteScreen
  bool newState;

  //liste _cheked pour etat de la case
  List<bool> _checked = [false, false, false, false, false];

  //les titres de case
  List<String> textes = [
    'XI arrondissement',
    'Parcours Ecole',
    'Balade samedi',
    'A visiter',
    'Bâtiments béton'
  ];

  //Listes de couleurs
  List<Color> couleurs = [
    Colors.purple,
    Colors.green,
    Colors.red,
    Colors.yellow,
    Colors.blue
  ];

  /// La liste de parcours
  static List<String> savedTexts = [];

  /// Change la taille de la police du titre
  void _fontSizeTitre(ScaleUpdateDetails details) {
    if (_sizeTitre < 20) {
      _sizeTitre = 20;
    }
    if (_sizeTitre > 28) {
      _sizeTitre = 28;
    }
    details.scale > 1
        ? _sizeTitre = _sizeTitre + details.scale * _scale
        : _sizeTitre = _sizeTitre - details.scale * _scale;
  }

  /// Change la taille de la police de l'introduction
  void _fontSizeIntro(ScaleUpdateDetails details) {
    if (_sizeIntro < 18) {
      _sizeIntro = 18;
    }
    if (_sizeIntro > 26) {
      _sizeIntro = 26;
    }
    details.scale > 1
        ? _sizeIntro = _sizeIntro + details.scale * _scale
        : _sizeIntro = _sizeIntro - details.scale * _scale;
  }

  /// Change la taille de la police des informations
  void _fontSizeInfo(ScaleUpdateDetails details) {
    if (_sizeInfo < 16) {
      _sizeInfo = 16;
    }
    if (_sizeInfo > 22) {
      _sizeInfo = 22;
    }
    details.scale > 1
        ? _sizeInfo = _sizeInfo + details.scale * _scale
        : _sizeInfo = _sizeInfo - details.scale * _scale;
  }

  /// Change la taille de la police du texte
  void _fontSizeText(ScaleUpdateDetails details) {
    if (_sizeText < 17) {
      _sizeText = 17;
    }
    if (_sizeText > 25) {
      _sizeText = 25;
    }
    details.scale > 1
        ? _sizeText = _sizeText + details.scale * _scale
        : _sizeText = _sizeText - details.scale * _scale;
  }

  /// Action permettant d'agrandir ou reduire la taille de la police
  void _pinch(ScaleUpdateDetails details) {
    setState(() {
      _fontSizeTitre(details);
      _fontSizeInfo(details);
      _fontSizeIntro(details);
      _fontSizeText(details);
    });
  }

  //Permet de modifier la valeur du bool lance
  //Si un nouvel audio est joué on renvoie les données de l'article vers CarteScreen pour l'afficher sur l'AudioBottomBar
  void setStateLance() {
    widget.isPopUpOpen(!widget.lance);
    if (newAudio)
      widget.articleCallback(
          newArticle, widget.audioPlayer, newState, newSnapshot);
    else
      widget.articleCallback(widget.article, widget.audioPlayer,
          widget.audioState, widget.snapshot);

    newAudio = false;
  }

  //Permet de recuperer les donnees du nouvel audio joue aleatoirement dans audio.dart
  //Au depart elle me servait uniquemement pour un nouvel audio, mais maintenant je l'utilise des que le state change dans audio.dart
  void randomAudioCallback(
      Article newArticle, String newSnapshot, bool newState, bool newAudio) {
    this.newArticle = newArticle;
    this.newSnapshot = newSnapshot;
    this.newAudio = newAudio;
    this.newState = newState;
  }

  ///fonction permet de récuperer l'iamge depuis firebase
  Future<String> getImage(Article article, [bool test = false]) async {
    String snap = "";
    if (test) {
      if (!widget.trade)
        snap = await firebase_storage.FirebaseStorage.instance
            .ref()
            .child(article.image)
            .getDownloadURL();
    }
    return snap;
  }

  @override
  Widget build(BuildContext context) {
    /// Liste de texte avec introdution
    List<String> intro = Provider.of<ArticleProvider>(context, listen: false)
        .getIntro(widget.article, widget.trade);

    /// Liste  des labels
    List<String> labels = Provider.of<TagProvider>(context, listen: false)
        .listLabel(widget.article.tags, widget.trade);
    labels.sort((a, b) => a.compareTo(b));

    /// Liste des labels ET des definitions
    List<Tag> _labels = Provider.of<TagProvider>(context).tags;

    ///Liste de texte séparant les phrases en gras ou non
    List<String> gras = Provider.of<ArticleProvider>(context, listen: false)
        .getBold(intro.length == 1 ? intro[0] : intro[1]);

    ///Texte représentant la signature
    String sign =
        Provider.of<ArticleProvider>(context, listen: false).getSign(gras.last);

    ///Valeur de champ couleur par défaut
    Color textColor = Colors.black;

    ///fonction pour changer couleur au niveau de ColorPicker
    void changeTextColor(Color color) {
      setState(() {
        textColor = color;
      });
    }

    //pour stocker le texte tapé par l'utilisateur
    final TextEditingController _textEditingController =
        TextEditingController();

    ///pour referencer la liaison vers firebase
    final DocumentReference documentReference = FirebaseFirestore.instance
        .collection('utilisateur')
        .doc(FirebaseAuth.instance.currentUser.uid);

    //parametrre pour stocker les donnes depuis firebase
    List<String> arrayFieldNames = [];

    //fonction qui recupere les donnes depuis firebase
    Future<List<String>> getArrayFieldNames() async {
      try {
        DocumentSnapshot documentSnapshot = await documentReference.get();
        Map<String, dynamic> documentData =
            documentSnapshot.data() as Map<String, dynamic>;

        documentData.forEach((key, value) {
          if (value is List) {
            if (key != 'favoris') arrayFieldNames.add(key);
          }
        });
        print(
            'Champs de type tableau dans le document Firestore: $arrayFieldNames');
        return arrayFieldNames;
      } catch (e) {
        print(
            'Erreur lors de la récupération des noms de champs de type tableau: $e');
        return null;
      }
    }

//fonction qui recupere les données du champ "couelurs" depuis firebase
    Future<Map<String, dynamic>> getMapFields() async {
      // Récupération de la référence au document Firebase
      final documentReference = FirebaseFirestore.instance
          .collection('utilisateur')
          .doc(FirebaseAuth.instance.currentUser.uid);

      // Récupération du document Firebase
      final documentSnapshot = await documentReference.get();

      // Récupération du champ de type Map à partir du document
      final mapData =
          documentSnapshot.data()['couleurs'] as Map<String, dynamic>;

      return mapData;
    }

    //liste contenant titre et couleur
    List<SavedElement> savedElements = [SavedElement('', Colors.white, false)];

    //fonction qui permet de convertir un string en
    Color stringToColor(String colorString) {
      String valueString = colorString.replaceAll("#", "");
      if (valueString.length == 6) {
        valueString = "FF" + valueString;
      }
      int value = int.parse(valueString, radix: 16);
      return Color(value);
    }

//fonction qui permet de convertir un couleurs en string
    String colorToString(Color color) {
      String colorString = color.value.toRadixString(16).toUpperCase();
      if (colorString.length == 8) {
        colorString = colorString.substring(2);
      }
      return "#" + colorString;
    }

    //fonction permet de stocker les donnes recupere de firebase sur savedElements
    void myFunction(
        List<String> myList, Map<String, dynamic> mapResultat) async {
      myList = await getArrayFieldNames();
      mapResultat = await getMapFields();
      print(mapResultat);
      savedElements.clear();

      if (mapResultat.isNotEmpty) {
        for (int i = 0; i < myList.length; i++) {
          mapResultat.forEach((key, value) async {
            if (key == myList[i]) {
              savedElements
                  .add(SavedElement(myList[i], stringToColor(value), false));
            }
          });
        }
        ;
      } else {
        for (int i = 0; i < myList.length; i++) {
          savedElements.add(SavedElement(myList[i], Colors.black, false));
        }
      }
    }

    //fonction qui supprimer un valeur dans le champ couleurs depuis firebase
    Future<void> deleteMapFieldValue(String key) async {
      // Récupération de la référence au document Firebase
      final documentReference = FirebaseFirestore.instance
          .collection('utilisateur')
          .doc(FirebaseAuth.instance.currentUser.uid);

      // Récupération du document Firebase
      final documentSnapshot = await documentReference.get();

      // Récupération du champ de type Map à partir du document
      final mapData =
          documentSnapshot.data()['couleurs'] as Map<String, dynamic>;

      // Suppression de la clé et de sa valeur dans le champ de type Map
      mapData.remove(key);

      // Mise à jour du document avec la nouvelle valeur du champ de type Map
      await documentReference.update(mapData);
    }

    Future<void> deleteTexte(String currentText) async {
      //suppression de nom de champs sur firebase
      DocumentReference documentRef = FirebaseFirestore.instance
          .collection('utilisateur')
          .doc(FirebaseAuth.instance.currentUser.uid);
      Map<String, dynamic> champs = {currentText: FieldValue.delete()};
      await documentRef.update(champs);
    }

    //une liste pour stocker les donness recupere de firebase
    List<String> myList = [];
    Map<String, dynamic> mapResultat = {};
    myFunction(myList, mapResultat);

    if (gras.last.contains('&signature')) {
      var _end = gras.last.split('&signature');
      gras.removeLast();
      gras.add(_end[0]);
    }

    /// Mets en gras les String de gras lorsque [i] est impaire
    List<Widget> addBoldToText() {
      List<SelectableText> l = [];
      if (gras.length > 1) {
        for (var i = 1; i < gras.length; i++) {
          if (i % 2 == 1) {
            l.add(SelectableText(
              gras[i],
              style: TextStyle(
                fontFamily: 'myriad',
                fontSize: _sizeText,
                fontWeight: FontWeight.bold,
              ),
            ));
          } else {
            l.add(SelectableText(
              gras[i],
              style: TextStyle(
                fontFamily: 'myriad',
                fontSize: _sizeText,
              ),
            ));
          }
        }
      }
      return l;
    }

    /// @rgs - item Etiquette à afficher
    /// @return Renvoi le widget d'une étiquette
    Widget _buildChip(String label, String def) {
      return Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Color.fromRGBO(209, 62, 150, 1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: GestureDetector(
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: _sizeInfo),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    child: Dismissible(
                      movementDuration: Duration(seconds: 1),
                      key: Key("key"),
                      direction: DismissDirection.vertical,
                      onDismissed: (value) {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: AlertDialog(
                        insetPadding: EdgeInsets.zero,
                        title: Text(
                          label,
                          style: TextStyle(
                              color: Color.fromRGBO(209, 62, 150, 1),
                              fontSize: 20),
                        ),
                        content: Text(
                          def,
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  );
                },
              );
            }),
      );
    }

    /// @return Renvoi le design de chaque étiquette dans une liste
    List<Container> _buildAllChip() {
      List<Container> _chips = [];
      for (var i = 0; i < labels.length; i++) {
        for (var y = 0; y < _labels.length; y++) {
          if (!widget.trade) {
            if (labels[i].contains(_labels[y].label)) {
              _chips.add(_buildChip(labels[i], _labels[y].definition));
            }
          } else {
            if (labels[i].contains(_labels[y].labelEN)) {
              _chips.add(_buildChip(labels[i], _labels[y].definitionEN));
            }
          }
        }
      }
      return _chips;
    }

    void fonctionStockeFirebase(String newText) {
      // Référence du document à mettre à jour
      final documentReference = FirebaseFirestore.instance
          .collection('utilisateur')
          .doc(FirebaseAuth.instance.currentUser.uid);

      // Utiliser la méthode update() pour ajouter un champ de type tableau
      documentReference
          .update({newText: []})
          .then((value) => print("Champ ajouté avec succès"))
          .catchError(
              (error) => print("Erreur lors de l'ajout du champ : $error"));
    }

    void fonctionAjoutCouleur(String newText, String hexColor) async {
      // Récupération de la référence à la collection Firestore
      final CollectionReference articlesCollection =
          FirebaseFirestore.instance.collection('utilisateur');
      // Nouvelle clé et valeur à ajouter
      Map<String, dynamic> nouvelleValeur = {newText: hexColor};
      // Mise à jour du champ de type Map
      Map<String, dynamic> monChamp =
          await getMapFields(); // Champ de type Map existant
      monChamp.addAll(nouvelleValeur); // Ajouter la nouvelle clé et valeur
      articlesCollection
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update({'couleurs': monChamp})
          .then((value) => print("Champ Map ajouté avec succès"))
          .catchError(
              (error) => print("Erreur lors de l'ajout du champ : $error"));
    }

    void fonctionStcokeIdArticle(String text, String id) {
      // Récupération de la référence à la collection Firestore
      final CollectionReference articlesCollection =
          FirebaseFirestore.instance.collection('utilisateur');
      // Mise à jour du champ de type tableau
      articlesCollection.doc(FirebaseAuth.instance.currentUser.uid).update({
        text: FieldValue.arrayUnion([id]),
      }).then((_) {
        print('Chaine ajoutée avec succès.');
      }).catchError((error) {
        print('Erreur lors de l\'ajout de la chaine : $error');
      });
    }

    // Supprimer un élément de la liste
    Future<void> deleteItem(String itemName, String text) async {
      final CollectionReference collection =
          FirebaseFirestore.instance.collection('utilisateur');

      try {
        DocumentSnapshot documentSnapshot = await documentReference.get();
        Map<String, dynamic> documentData =
            documentSnapshot.data() as Map<String, dynamic>;

        documentData.forEach((key, value) async {
          if (value is List) {
            if (key != 'favoris') {
              // Supprimer l'élément de la liste
              await collection
                  .doc(FirebaseAuth.instance.currentUser.uid)
                  .update({
                text: FieldValue.arrayRemove([itemName])
              });
            }
          }
        });

        print('Élément supprimé avec succès');
      } catch (e) {
        print('Erreur lors de la suppression de l\'élément : $e');
      }
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (widget.article.title
                .contains("Manufacture sur Seine - Quartier Terre"))
              Container(
                height: 180,
                width: MediaQuery.of(context).size.width,
                child: Image(
                  image: AssetImage(
                      "assets/Manufacture sur Seine Quartier Terre/reinventer-seine-manufacture-seine-amateur.jpg"),
                  fit: BoxFit.cover,
                ),
              ),

            if (widget.article.title == "Centre ville de Montreuil Sous Bois")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/Centre Ville de Montreuil sous Bois Alvaro Siza/Croquis Siza Centre Ville Montreuil.jpg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "La Grande Arche")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/La Grande Arche/IMG_3992.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Fondation Louis Vuitton")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/Fondation Louis Vuitton/IMG_1330.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "100 logements sociaux")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/IMG_4027.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Stade Jean Bouin")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/IMG_2083.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "La Tour Triangle")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/La Tour Triangle/La Tour Triangle.jpg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Hôpital Cognacq-Jay")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/Hôpital Cognacq-Jay - Toyo Ito/IMG_9574.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Musée du quai Branly")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/Musée Quai Branly/IMG_3690.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Espace de méditation UNESCO")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/Espace de Méditation UNESCO - Tadao Ando/IMG_3819.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Showroom Citroën")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/Showroom Citroën/IMG_3651.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "57 logements Rue Des Suisses")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/57 logements - Herzog et Demeuron/IMG_2681.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title ==
                "Fondation Cartier pour l'art contemporain")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/Fondation Cartier/IMG_2195.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Galerie marchande Gaîté Montparnasse")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/Galerie Marchande Gaîté Montparnasse/03_Gaîté_Montparnasse_MVRDV_©Ossip van Duivenbode.jpg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title ==
                "Le département des Arts de l'Islam du Louvre")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/Département des Arts de l_Islam du Louvre/PARIS_Departement-des-Arts-de-l-Islam-du-musee-du-Louvre_02b.jpg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "La Pyramide du Louvre")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/La Pyramide du Louvre/IMG_3222.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "La Nouvelle Samaritaine")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/La Nouvelle Saint Maritaine - SANAA/IMG_3967.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "La Fondation Pinault")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/téléchargement.jpg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "La Canopée")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/La Canopée/IMG_3297.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Lafayette Anticipation")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/IMG_3353.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Pavillon Mobile Art Chanel")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/Pavillon Mobile Art Chanel/chanel_mobile_art_pavilion-zaha_hadid_2_photo AA13.jpg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "La Fondation Jérôme Seydoux-Pathé")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/téléchargement (1).jpg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Pushed Slab")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/Pushed Slab/IMG_5889.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "M6B2 Tour de la Biodiversité")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/IMG_7619.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title ==
                "La Bibliothèque Nationale de France (François Mitterand)")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/Bibliothèque François Mitterand/IMG_6855.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Cité de la mode et du design")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/Cité de la mode/IMG_7176.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "La Cinémathèque Française")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/La Cinémathèque Française/IMG_8448.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Eden bio")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/Eden Bio/IMG_4174.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "La Philharmonie")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/La Philharmonie/IMG_4684.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Le Parc de la Villette")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/Cité de la mode/Le Parc Lavillette/IMG_4727.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "220 logements Rue de Meaux")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/220 Logements rue de Meaux/IMG_2681.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Siège du Parti Communiste Français")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/Siège Parti Communiste/IMG_4383.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.architecte ==
                    "ANNE LACATON et JEAN PHILLIPE VASSAL (France)" &&
                widget.article.date == "2009")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/La Tour Bois Le Prêtre - Lacaton Vassal/IMG_0689.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.architecte ==
                    "Aires Mateus (Portugal) et AAVP (France)" &&
                widget.article.date == "2018")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/Emergence/IMG_0324.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Tower Flower")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/Tower Flower/IMG_0269.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Beaubourg")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage("assets/Beaubourg/IMG_3334.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Institut du Monde Arabe")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image:
                        AssetImage("assets/Institut Monde Arabe/IMG_8831.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Le Tribunal de Paris")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/Cité de la mode/Le Tribunal de Paris/IMG_0321.jpeg"),
                    fit: BoxFit.cover,
                  )),
            if (widget.article.title == "Villa Dall'Ava")
              Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(
                        "assets/Villa d_all_Ava - Oma/IMG_3076.jpeg"),
                    fit: BoxFit.cover,
                  )),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (!widget.like) {
                            if (!widget.trade) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        title: Text("Ajouter à un parcours ?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              widget.changeFavorite(
                                                  widget.idMaker);
                                              widget.deleteItem(
                                                  widget.article.id);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Non"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);

                                              return showModalBottomSheet(
                                                context: context,
                                                builder: (context) => Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.6,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              '   Enregistrer dans ...',
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                                fontFamily:
                                                                    'myriad',
                                                              ),
                                                            ),
                                                            SingleChildScrollView(
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed: () {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                        title: Text(
                                                                            'Nom du parcours'),
                                                                        content:
                                                                            SingleChildScrollView(
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Text('Couleur du texte :'),
                                                                              SizedBox(height: 10),
                                                                              ColorPicker(
                                                                                pickerColor: textColor,
                                                                                onColorChanged: changeTextColor,
                                                                                pickerAreaHeightPercent: 0.8,
                                                                              ),
                                                                              SizedBox(height: 10),
                                                                              TextField(
                                                                                controller: _textEditingController,
                                                                                decoration: InputDecoration(hintText: 'Entrez le texte ici'),
                                                                                onChanged: (text) {
                                                                                  // Convertit la première lettre en majuscule
                                                                                  _textEditingController.value = TextEditingValue(
                                                                                    text: text.length > 0 ? text[0].toUpperCase() + text.substring(1) : '',
                                                                                    selection: _textEditingController.selection,
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        actions: <
                                                                            Widget>[
                                                                          TextButton(
                                                                            child:
                                                                                Text('Annuler'),
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                          ),
                                                                          TextButton(
                                                                            child:
                                                                                Text('OK'),
                                                                            onPressed:
                                                                                () {
                                                                              // Sauvegarde du texte entré
                                                                              final newText = _textEditingController.text;
                                                                              //couleur en hexadecimal
                                                                              String hexColor = colorToString(textColor);
                                                                              fonctionStockeFirebase(newText);
                                                                              fonctionAjoutCouleur(newText, hexColor);
                                                                              if (newText.isNotEmpty) {
                                                                                savedElements.add(SavedElement(newText, textColor, false));
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
                                                                  '+ Parcours',
                                                                  style: TextStyle(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          33,
                                                                          44,
                                                                          243)),
                                                                ),
                                                                style:
                                                                    ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStateProperty.all<
                                                                              Color>(
                                                                          Colors
                                                                              .white),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                          child: ParcoursItem(
                                                        taille: savedElements
                                                            .length,
                                                        liste: savedElements,
                                                        deleteTexte:
                                                            deleteTexte,
                                                        deleteItem: deleteItem,
                                                        fonctionStcokeIdArticle:
                                                            fonctionStcokeIdArticle,
                                                        idMarker:
                                                            widget.article.id,
                                                        trade: widget.trade,
                                                      ))
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text("Oui"),
                                          ),
                                        ]);
                                  });
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        title: Text("Add to a course ?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              widget.changeFavorite(
                                                  widget.idMaker);
                                              widget.deleteItem(
                                                  widget.article.id);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("No"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);

                                              return showModalBottomSheet(
                                                context: context,
                                                builder: (context) => Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.6,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              '   Save in ...',
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                                fontFamily:
                                                                    'myriad',
                                                              ),
                                                            ),
                                                            SingleChildScrollView(
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed: () {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                        title: Text(
                                                                            'course name'),
                                                                        content:
                                                                            SingleChildScrollView(
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Text('Course color :'),
                                                                              SizedBox(height: 10),
                                                                              ColorPicker(
                                                                                pickerColor: textColor,
                                                                                onColorChanged: changeTextColor,
                                                                                pickerAreaHeightPercent: 0.8,
                                                                              ),
                                                                              SizedBox(height: 10),
                                                                              TextField(
                                                                                controller: _textEditingController,
                                                                                decoration: InputDecoration(hintText: 'Enter the name of the course'),
                                                                                onChanged: (text) {
                                                                                  // Convertit la première lettre en majuscule
                                                                                  _textEditingController.value = TextEditingValue(
                                                                                    text: text.length > 0 ? text[0].toUpperCase() + text.substring(1) : '',
                                                                                    selection: _textEditingController.selection,
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        actions: <
                                                                            Widget>[
                                                                          TextButton(
                                                                            child:
                                                                                Text('Cancel'),
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                          ),
                                                                          TextButton(
                                                                            child:
                                                                                Text('OK'),
                                                                            onPressed:
                                                                                () {
                                                                              // Sauvegarde du texte entré
                                                                              final newText = _textEditingController.text;
                                                                              //couleur en hexadecimal
                                                                              String hexColor = colorToString(textColor);
                                                                              fonctionStockeFirebase(newText);
                                                                              fonctionAjoutCouleur(newText, hexColor);
                                                                              if (newText.isNotEmpty) {
                                                                                savedElements.add(SavedElement(newText, textColor, false));
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
                                                                  '+ Course',
                                                                  style: TextStyle(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          33,
                                                                          44,
                                                                          243)),
                                                                ),
                                                                style:
                                                                    ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStateProperty.all<
                                                                              Color>(
                                                                          Colors
                                                                              .white),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                          child: ParcoursItem(
                                                        taille: savedElements
                                                            .length,
                                                        liste: savedElements,
                                                        deleteTexte:
                                                            deleteTexte,
                                                        deleteItem: deleteItem,
                                                        fonctionStcokeIdArticle:
                                                            fonctionStcokeIdArticle,
                                                        idMarker:
                                                            widget.article.id,
                                                        trade: widget.trade,
                                                      ))
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text("Yes"),
                                          ),
                                        ]);
                                  });
                            }
                          }
                          widget.changeFavorite(widget.idMaker);
                          widget.deleteItem(widget.article.id);
                        },
                        child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 1,
                                  child: Icon(
                                    Icons.add,
                                    size: 18,
                                    color: widget.like
                                        ? Colors.red
                                        : Colors.black45,
                                  ),
                                ),
                                /*Align(
                                    alignment: Alignment.center,
                                    child: widget.like
                                        ? CustomPaint(
                                            size: Size(100.0, 100.0),
                                            painter: MyPainter(),
                                          )
                                        : /*child:*/ Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: widget.like
                                                  ? Colors.red
                                                  : Colors.black45,
                                            ),
                                          ))*/
                                Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: widget.like
                                            ? Colors.red
                                            : Colors.black45,
                                      ),
                                    ))
                              ],
                            )),
                      ),
                      if (widget.article.audio.isNotEmpty)
                        Center(
                          child: IconButton(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            iconSize: 26,
                            icon: (!widget.firstLaunchOfArticle)
                                ? Image.asset(
                                    "assets/images/ICON_VOLUME_VIOLET.png")
                                : (widget.article == widget.secondArticle)
                                    ? Image.asset(
                                        "assets/images/ICON_VOLUME.png")
                                    : Image.asset(
                                        "assets/images/ICON_VOLUME_VIOLET.png"),
                            onPressed: () {
                              newState = widget.audioState;

                              //Les nouvelles durée initialisé à 0 si on change d'article
                              //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                              Duration savedPosition = new Duration();
                              Duration savedMaxDuration = new Duration();

                              if (widget.secondArticle != widget.article ||
                                  (widget.audioState &&
                                      widget.secondArticle != widget.article)) {
                                widget.play(widget.snapshot);
                                newState = true;
                              }
                              //Le statefulbuilder ne sert plus a rien normalement
                              showDialog(
                                  context: context,
                                  builder: (context) => StatefulBuilder(
                                          builder: (context, setState) {
                                        return GestureDetector(
                                          onTap: () => Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop(),
                                          child: Dismissible(
                                              movementDuration:
                                                  Duration(seconds: 1),
                                              key: Key("key"),
                                              direction:
                                                  DismissDirection.vertical,
                                              onDismissed: (value) {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();
                                              },
                                              child: Audio(
                                                article: widget.article,
                                                trade: widget.trade,
                                                audioPlayer: widget.audioPlayer,
                                                snapshot: widget.snapshot,
                                                audioState:
                                                    widget.firstLaunchOfArticle
                                                        ? newState != null
                                                            ? newState
                                                            : widget.audioState
                                                        : widget.audioState,
                                                lance: widget.lance,
                                                play: widget.play,
                                                pausePlayer: widget.pausePlayer,
                                                stopPlayer: widget.stopPlayer,
                                                cameFromArticeItem: true,
                                                isPopupOpen: widget.isPopUpOpen,
                                                updateDuration:
                                                    widget.updateDuration,
                                                savedMaxDuration: (widget
                                                            .secondArticle ==
                                                        widget.article)
                                                    ? widget.savedMaxDuration
                                                    : savedMaxDuration,
                                                savedPosition:
                                                    (widget.secondArticle ==
                                                            widget.article)
                                                        ? widget.savedPosition
                                                        : savedPosition,
                                                firstLaunchOfArticle:
                                                    widget.firstLaunchOfArticle,
                                                setFirstLaunchOfArticle: widget
                                                    .setFirstLaunchOfArticle,
                                                afficherArticle:
                                                    widget.afficherArticle,
                                                marker: widget.marker,
                                                updateMarkerForPopUp:
                                                    widget.updateMarkerForPopUp,
                                                articleCallback:
                                                    widget.articleCallback,
                                                randomAudioCallback:
                                                    randomAudioCallback,
                                                articlesData:
                                                    widget.articlesData,
                                                markersData: widget.markersData,
                                              )),
                                        );
                                      })).then((value) => setStateLance());
                            },
                          ),
                        ),
                    ],
                  ),

                  ///Affiche button Commentaire
                  TextButton(
                    child: Row(
                      children: [
                        Text(
                          'DISCUSS',
                          style: TextStyle(
                              fontFamily: 'myriad',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color.fromRGBO(209, 62, 150, 1)),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.black45, size: 17)
                      ],
                    ),
                    onPressed: widget.switchToComm,
                  )
                ],
              ),
              width: double.infinity,
              height: 40,
            ),

            /// Affiche Body
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: SingleChildScrollView(
                  child: Scrollbar(
                    child: GestureDetector(
                      onScaleUpdate: (ScaleUpdateDetails details) {
                        _pinch(details);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Affiche titre de l'article

                          Container(
                            color: Colors.white,
                            margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SelectableText(
                                !widget.trade
                                    ? widget.article.title
                                    : widget.article.titleEN.isEmpty
                                        ? widget.article.title
                                        : widget.article.titleEN,
                                style: TextStyle(
                                  fontFamily: 'myriad',
                                  color: Colors.black,
                                  fontSize: _sizeTitre,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),

                          // Affiche les mots cles
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
                            child: Wrap(
                              spacing: 5,
                              children: _buildAllChip(),
                              runSpacing: 3,
                            ),
                          ),

                          /// Affiche les architectes
                          if (widget.article.architecte.isNotEmpty)
                            !widget.trade
                                ? buildInfo(
                                    widget.article.architecte, 'Architecte ')
                                : buildInfo(
                                    widget.article.architecte, 'Architect '),

                          /// Affiche les architectes associes
                          if (widget.article.associe.isNotEmpty)
                            !widget.trade
                                ? buildInfo(widget.article.associe,
                                    'Architecte associé ')
                                : buildInfo(widget.article.associe,
                                    'Associate architect '),

                          /// Affiche les architecte transformation
                          if (widget.article.transformation.isNotEmpty)
                            !widget.trade
                                ? buildInfo(widget.article.transformation,
                                    'Architecte transformation ')
                                : buildInfo(widget.article.transformation,
                                    'Transformation architect '),

                          /// Affiche les architecte des monuments historiques
                          if (widget.article.monument.isNotEmpty)
                            !widget.trade
                                ? buildInfo(widget.article.monument,
                                    'Architecte des Monuments Historiques ')
                                : buildInfo(widget.article.monument,
                                    'Architect of the historical monuments '),

                          /// Affiche les architectes de projet
                          if (widget.article.projet.isNotEmpty)
                            !widget.trade
                                ? buildInfo(widget.article.projet,
                                    'Architecte de projet ')
                                : buildInfo(widget.article.projet,
                                    'Project architect '),

                          /// Affiche architecte local
                          if (widget.article.local.isNotEmpty)
                            !widget.trade
                                ? buildInfo(
                                    widget.article.local, 'Architecte local ')
                                : buildInfo(
                                    widget.article.local, 'Local architect '),

                          /// Affiche les architectes des opérations connexes
                          if (widget.article.operation.isNotEmpty)
                            !widget.trade
                                ? buildInfo(widget.article.operation,
                                    'Architecte des opérations connexes ')
                                : buildInfo(widget.article.operation,
                                    'Related operations architect '),

                          /// Affiche les architectes du patrimoine
                          if (widget.article.patrimoine.isNotEmpty)
                            !widget.trade
                                ? buildInfo(widget.article.patrimoine,
                                    'Architecte du patrimoine ')
                                : buildInfo(widget.article.patrimoine,
                                    'Heritage architect '),

                          /// Affiche le chef de projet
                          if (widget.article.chef.isNotEmpty)
                            !widget.trade
                                ? buildInfo(
                                    widget.article.chef, 'Chef de projet ')
                                : buildInfo(
                                    widget.article.chef, 'Project manager '),

                          /// Affiche l'ingenieur
                          if (widget.article.ingenieur.isNotEmpty)
                            !widget.trade
                                ? buildInfo(
                                    widget.article.ingenieur, 'Ingénieur ')
                                : buildInfo(
                                    widget.article.ingenieur, 'Ingenieur '),

                          /// Affiche le paysagiste
                          if (widget.article.paysagiste.isNotEmpty)
                            !widget.trade
                                ? buildInfo(
                                    widget.article.paysagiste, 'Paysagiste ')
                                : buildInfo(
                                    widget.article.paysagiste, 'Landscaper '),

                          /// Affiche l'urbaniste
                          if (widget.article.urbaniste.isNotEmpty)
                            !widget.trade
                                ? buildInfo(
                                    widget.article.urbaniste, 'Urbaniste ')
                                : buildInfo(
                                    widget.article.urbaniste, 'Urban planner '),

                          /// Affiche l'artiste
                          if (widget.article.artiste.isNotEmpty)
                            !widget.trade
                                ? buildInfo(widget.article.artiste, 'Artiste ')
                                : buildInfo(widget.article.artiste, 'Artist '),

                          /// Affiche l'eclairagiste
                          if (widget.article.eclairagiste.isNotEmpty)
                            !widget.trade
                                ? buildInfo(widget.article.eclairagiste,
                                    'Eclairagiste ')
                                : buildInfo(widget.article.eclairagiste,
                                    'Lighting designer '),

                          /// Affiche le conservateur du musée
                          if (widget.article.musee.isNotEmpty)
                            !widget.trade
                                ? buildInfo(widget.article.musee,
                                    'Conservateur du musée ')
                                : buildInfo(
                                    widget.article.musee, 'Museum curator '),

                          /// Affiche le site
                          if (widget.article.lieu.isNotEmpty)
                            !widget.trade
                                ? buildInfo(widget.article.lieu, 'Adresse ')
                                : buildInfo(widget.article.lieu, 'Address '),

                          /// Affiche la date
                          if (widget.article.date.isNotEmpty)
                            !widget.trade
                                ? buildInfo(widget.article.date, 'Année ')
                                : buildInfo(widget.article.date, 'Year '),

                          /// Affiche l'année d'installation à Paris
                          if (widget.article.installation.isNotEmpty)
                            !widget.trade
                                ? buildInfo(widget.article.installation,
                                    'Année d\'installation à Paris ')
                                : buildInfo(widget.article.installation,
                                    'Year of settlement in Paris '),

                          /// Affiche les dimensions
                          if (widget.article.dimensions.isNotEmpty)
                            buildInfo(widget.article.dimensions, 'Dimensions '),

                          /// Affiche les Expositions
                          if (widget.article.expositions.isNotEmpty)
                            !widget.trade
                                ? buildInfo(
                                    widget.article.expositions, 'Expositions ')
                                : buildInfo(
                                    widget.article.expositions, 'Exhibitions '),

                          /// Affiche la surface
                          if (widget.article.surface.isNotEmpty)
                            buildInfo(widget.article.surface, 'Surface '),

                          /// Affiche la surface à construire
                          if (widget.article.construire.isNotEmpty)
                            !widget.trade
                                ? buildInfo(widget.article.construire,
                                    'Surface à construire ')
                                : buildInfo(widget.article.construire,
                                    'Building area '),

                          /// Affiche la surface d'exposition
                          if (widget.article.surfaceExpo.isNotEmpty)
                            !widget.trade
                                ? buildInfo(widget.article.surfaceExpo,
                                    'Surface d\'exposition ')
                                : buildInfo(widget.article.surfaceExpo,
                                    'Exhibition area '),

                          SizedBox(
                            height: 10,
                          ),

                          ///Affiche l'introduction de l'article
                          if (intro.length == 2)
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                              margin: EdgeInsets.all(10),
                              child: SelectableText(
                                intro[0],
                                style: TextStyle(
                                  fontFamily: 'myriad',
                                  fontSize: _sizeIntro,
                                ),
                              ),
                            ),
                          SizedBox(
                            height: 20,
                          ),

                          Divider(
                            thickness: 2,
                            color: Colors.black54,
                            endIndent: 20,
                            indent: 20,
                          ),

                          ///Affiche la description de l'article
                          Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  SelectableText(
                                    gras[0],
                                    style: TextStyle(
                                      fontFamily: 'myriad',
                                      fontSize: _sizeText,
                                    ),
                                  ),
                                  ...addBoldToText(),
                                  if (widget.article.text
                                      .contains('&signature'))
                                    Container(
                                      width: double.infinity,
                                      child: SelectableText(
                                        sign,
                                        style: TextStyle(
                                          fontFamily: 'myriad',
                                          fontSize: 13,
                                        ),
                                      ),
                                    )
                                ],
                              )),

                          SizedBox(
                            height: 350,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  // info Information à afficher
  Container buildInfo(info, txt) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SelectableText.rich(TextSpan(
          text: txt + "  ",
          style: TextStyle(
            fontFamily: 'myriad',
            fontSize: _sizeInfo,
            color: Colors.black,
          ),
          children: [
            TextSpan(
                text: info,
                style: TextStyle(
                    fontFamily: 'myriad',
                    fontSize: _sizeInfo,
                    fontWeight: FontWeight.bold,
                    color: Colors.black))
          ])),
    );
  }
}

class SavedElement {
  final String text;
  final Color color;

  bool selected;

  SavedElement(this.text, this.color, this.selected);
}
