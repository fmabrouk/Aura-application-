import 'dart:async';

import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:aura2/screens/rechercheScreen.dart';
import 'package:aura2/widgets/listeWidgets/BoutonParcoursItem.dart';
import 'package:chips_choice_null_safety/chips_choice_null_safety.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:swipedetector/swipedetector.dart';

import '../models/User.dart';
import '../models/article.dart';
import '../models/customMarker.dart';
import '../providers/articleProvider.dart';
import '../providers/markerProvider.dart';
import '../widgets/audioWidgets/audio.dart';
import '../widgets/audioWidgets/audioBottomBar.dart';
import '../widgets/drawer.dart';
import '../widgets/favorisWidgets/animatedbuttom3.dart';
import '../widgets/favorisWidgets/listeFavoris.dart';

import '../widgets/favorisWidgets/parcoursSupprime.dart';
import '../widgets/listeWidgets/listeItem.dart';
import '../widgets/listeWidgets/parcoursItemListe.dart';
import '../widgets/markerWidgets/recherche.dart';
import '../widgets/rechercheWidgets/barreRecherche.dart';

import 'carteScreen.dart';

class ParcoursScreen extends StatefulWidget {
  ParcoursScreen(
      {Key key,
      this.user,
      this.auth,
      this.login,
      this.trade,
      this.latling1,
      this.latling2,
      this.articless,
      this.dropDownValue})
      : super(key: key);

  final bool auth;

  final User login;
  double latling1;
  double latling2;

  String dropDownValue;

  final UserCustom user;

  List<Article> articless;

  /// Permet de savoir si la page doit être traduite en anglais
  bool trade;
  @override
  _ParcoursScreenState createState() => _ParcoursScreenState();
}

class _ParcoursScreenState extends State<ParcoursScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  /// Identifiant de l'article à ouvrir
  String _idArticle;

  /// Utilisateur courant
  UserCustom user;

  /// Etat de la fenetre Favori
  bool _favorisVisible = false;

  ///Etat de la fenetre Liste
  bool _listeVisible = true;

  /// Etat de la fenetre Recherche
  bool _rechercheVisible = false;

  //Le player permettant de gerer l'audio
  AudioPlayer audioPlayer = new AudioPlayer();

  /// Vrai si l'audio est en cours
  /// Faux si l'audio est Ã  l'arret
  bool audioState = false;

  /// Position d'un article
  double _position = (window.physicalSize.height / window.devicePixelRatio) -
      200 -
      kBottomNavigationBarHeight;

  /// Permet de savoir si on a dÃ©jÃ  cliquÃ© sur le bouton pour Ã©couter l'audio
  bool lance = false;

  //Les données de l'audio qui sont récupéré lorsque l'utilisateur ouvre un article, s'il y a un audio
  String _snapshot;

  // L'article qui est récupéré lorsque l'utilisateur clique sur un marqueur
  Article _article;

  //L'article qui a un audio. Permet de laisser à l'écran le AudioBottomBar ligne
  //692 lorsqu'on écoute un audio alors que l'on est dans un article qui n'a pas d'audio
  Article _articleWithAudio;

  //Permet de sauvegarder la durée maximal de l'audio
  Duration savedMaxDuration = new Duration();

  //Permet de sauvegarder la position de l'audio
  Duration savedPosition = new Duration();

  //Devient true dès qu'on lance le tout premier article
  //Permet de lancer le tout premier audio
  bool firstLaunchOfArticle = false;

  //Permet d'acceder à un article depuis le popup ouvert depuis audioBottomBar
  CustomMarker markerForBottomBar;

  /// List des marquers filtrés à afficher
  List<CustomMarker> _markersFiltered = [];

  //permet de changer la valeur de traduction dans cette page lorsqu'on le change dans DrawerCustom
  void _tradeCallBack(bool tradu) {
    setState(() {
      widget.trade = tradu;
    });
  }

  /// Ferme les fenetres 'list des favoris' et 'recherche'
  void _showMap() {
    setState(() {
      _favorisVisible = false;
      _rechercheVisible = false;
      _listeVisible = false;
    });
  }

  /// Joue le fichier audio
  void play(String url) async {
    setState(() {
      audioState = true;
    });
    if (!audioState) {
      await audioPlayer.resume();
    } else
      await audioPlayer.play(UrlSource(url));

    //setState(() {});
  }

  /// Met en pause le fichier audio
  Future<void> pausePlayer() async {
    setState(() {
      audioState = false;
    });
    if (!audioState) {
      await audioPlayer.pause();
    }
  }

  /// Stop le fichier audio
  Future<void> stopPlayer() async {
    setState(() {
      audioState = false;
    });
    if (audioPlayer != null) {
      await audioPlayer.stop();
    }
  }

  //Permet de mettre à jour les données d'un article
  void _articleCallback(article, audioPlayer, audioState, snapshot) {
    setState(() {
      this._article = article;
      this._articleWithAudio = article;
      this.audioPlayer = audioPlayer;
      this.audioState = audioState;
      this._snapshot = snapshot;
    });
  }

  void randomAudioCallback(
      Article newArticle, String newSnapshot, bool newState, bool newAudio) {
    this._article = newArticle;
    this._articleWithAudio = newArticle;
    this._snapshot = newSnapshot;
    this.audioState = newState;
  }

  //Fonction pour actualiser le marker utilisé dans audioBottomBar
  void updateMarkerForPopUp(marker) {
    this.markerForBottomBar = marker;
  }

  //Permet de mettre à jour la valeur du bool lance
  void _isPopupOpen(lance) async {
    await Future.delayed(Duration(milliseconds: 1));
    setState(() {
      this.lance = lance;
    });
  }

  //Permet de mettre à jour les données sur la durée de l'audio
  void updateDuration(maxDuration, position) {
    this.savedMaxDuration = maxDuration;
    this.savedPosition = position;
  }

  //Permet de mettre firstLaunchOfArticle à true
  void setFirstLaunchOfArticle() {
    this.firstLaunchOfArticle = true;
  }

  ///Une liste contenat les valeurs des animations pour le parcours liste ou carte
  List<String> options = ['Carte', 'Liste'];

  ///Valeur pour les animations au niveau du parcours liste ou carte
  int tag = 1;

  ///valeur par défaut pour le dropDown pour le bouton "Tous"
  String dropdownValue = 'Tous';

  ///Manager firebase pour le bouton "Tous"

  Widget build(BuildContext context) {
    final markersData = Provider.of<MarkerProvider>(context);
    final articleData = Provider.of<ArticleProvider>(context);
    final articleProvider = Provider.of<ArticleProvider>(context);
    final articleMarker = Provider.of<MarkerProvider>(context).getAllMarkers();

    ///Liste contenant toute les articles
    final articleList =
        Provider.of<ArticleProvider>(context).getAllArticles().toList();

    ///Liste contenanat les articles qui possedent des images
    final articleListImage =
        Provider.of<ArticleProvider>(context).getAllArticlesImage().toList();

    ///Liste contenanat des articles qui possedent pas des images
    final articleListWithoutImage = Provider.of<ArticleProvider>(context)
        .getAllArticlesWithoutImage()
        .toList();

    ///Trier les articles par ordre alphabétiques selon leur titres
    articleListImage.sort(((a, b) => a.title.compareTo(b.title)));
    articleListWithoutImage.sort(((a, b) => a.title.compareTo(b.title)));
    articleList.sort(((a, b) => a.title.compareTo(b.title)));

    ///Fusionner les deux listes
    final articleLists = articleListImage + articleListWithoutImage;

    ///Initialisation de Firebase
    final DocumentReference documentReference = FirebaseFirestore.instance
        .collection('utilisateur')
        .doc(FirebaseAuth.instance.currentUser.uid);

    //parametrre pour stocker les donnes depuis firebase
    List<String> arrayFieldNames = [];

    ///fonction qui recupere les donnes  de  champ de type tableau depuis firebase
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
    List<SavedElement> savedElements = [
      SavedElement('', Colors.white, '10', false)
    ];

    ///fonction qui récupere la taille de tableau depuis Firebase
    Future<String> parcoursFunction(String id) async {
      final utilisateurData = await documentReference.get();
      final texteSize = utilisateurData[id].length;

      return texteSize.toString();
    }

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

    /// fonction qui recupere les données stockant dans le champ parcours
    Future<List<String>> stcokeeParcours(String parcours) async {
      final firestoreInstance = FirebaseFirestore.instance;
      final collectionRef = firestoreInstance.collection('utilisateur');
      final documentRef =
          collectionRef.doc(FirebaseAuth.instance.currentUser.uid);

      final DocumentSnapshot documentSnapshot = await documentRef.get();
      if (documentSnapshot.exists) {
        final baladeList = List<String>.from(documentSnapshot.get(parcours));
        return baladeList;
      } else {
        print('Document does not exist on the database');
        return null;
      }
    }

    Future<bool> recupereValeurTrade() async {
      final docRef = FirebaseFirestore.instance
          .collection('utilisateur')
          .doc(FirebaseAuth.instance.currentUser.uid);
      var doc = await docRef.get();

      if (doc.exists) {
        bool trade = doc.data()['trade'];
        return trade;
        // utilisez la variable 'trade' ici
        //print(trade);
        //return trade;
      }
      return false;
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
              savedElements.add(SavedElement(
                  myList[i],
                  stringToColor(value),
                  await parcoursFunction(myList[i]),
                  await recupereValeurTrade()));
            }
          });
        }
        ;
      } else {
        for (int i = 0; i < myList.length; i++) {
          savedElements.add(SavedElement(myList[i], Colors.black,
              await parcoursFunction(myList[i]), await recupereValeurTrade()));
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

    ///Couleur par défaut si 'l'utilisateur n'a rien choisi
    Color textColor = Colors.black;

    ///Fonction pour changer le couleur au niveau de COlorPïcker
    void changeTextColor(Color color) {
      setState(() {
        textColor = color;
      });
    }

    ///parametre pour enregistrer les valeurs ecrits par l'utilisateur
    final TextEditingController _textEditingController =
        TextEditingController();

    /// Affiche l'article sélectionné depuis la liste des favoris
    void _afficherArticle(CustomMarker marker) {
      setState(() {
        _favorisVisible = false;
        _rechercheVisible = false;
        _idArticle = marker.idArticle;
        _position = 1;
        marker.isVisible = true;
      });
    }

    /// @args - articles Liste d'article
    /// Affiche la carte avec les marqueurs filtrés
    void filterMap(List<Article> articles, bool afficher) {
      if (articles.isEmpty) {
        return;
      }
      setState(() {
        if (afficher) {
          _favorisVisible = false;
          _rechercheVisible = false;
        }
        _markersFiltered = markersData.markersFilter(articles);
      });
    }

    void openAudio() {
      //Le statefulbuilder ne sert plus a rien normalement
      showDialog(
          context: context,
          builder: (context) => StatefulBuilder(builder: (context, setState) {
                return GestureDetector(
                  onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                  child: Dismissible(
                    movementDuration: Duration(seconds: 1),
                    key: Key("key"),
                    direction: DismissDirection.vertical,
                    onDismissed: (value) {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Audio(
                        article: _articleWithAudio,
                        trade: widget.trade,
                        audioPlayer: audioPlayer,
                        snapshot: _snapshot,
                        audioState: audioState,
                        lance: lance,
                        play: play,
                        pausePlayer: pausePlayer,
                        stopPlayer: stopPlayer,
                        isPopupOpen: _isPopupOpen,
                        cameFromArticeItem: false,
                        updateDuration: updateDuration,
                        savedMaxDuration: savedMaxDuration,
                        savedPosition: savedPosition,
                        afficherArticle: _afficherArticle,
                        marker: markerForBottomBar,
                        articleCallback: _articleCallback,
                        updateMarkerForPopUp: updateMarkerForPopUp,
                        markersData: markersData,
                        articlesData: articleData,
                        randomAudioCallback: randomAudioCallback),
                  ),
                );
              })).then(
        (_) => _isPopupOpen(!lance),
      );
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

    // Supprimer un élément de la liste
    Future<void> deleteItemParcours(String itemName, String nomParcours) async {
      final CollectionReference collection =
          FirebaseFirestore.instance.collection('utilisateur');

      try {
        DocumentSnapshot documentSnapshot = await documentReference.get();
        Map<String, dynamic> documentData =
            documentSnapshot.data() as Map<String, dynamic>;

        documentData.forEach((key, value) async {
          if (value is List) {
            if (key == nomParcours) {
              // Supprimer l'élément de la liste
              await collection
                  .doc(FirebaseAuth.instance.currentUser.uid)
                  .update({
                key: FieldValue.arrayRemove([itemName])
              });
            }
          }
        });

        print('Élément supprimé avec succès');
      } catch (e) {
        print('Erreur lors de la suppression de l\'élément : $e');
      }
    }

    //parametres par défaut pour le bouton "tous"
    String dropdownValue = 'Tous';
    String buttonText = 'balade';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      drawer: DrawerCustom(
        auth: widget.auth,
        user: user,
        trade: widget.trade,
        tradeCallBack: _tradeCallBack,
      ),
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: barreRecherche(
                      articleProvider: articleProvider,
                      login: widget.login,
                      auth: widget.auth,
                      user: widget.user,
                      trade: widget.trade));
            },
            icon: Icon(
              Icons.search,
              color: Colors.black,
            )),
        title: GestureDetector(
          onTap: () {
            showSearch(
              context: context,
              delegate: barreRecherche(
                  articleProvider: articleProvider,
                  login: widget.login,
                  user: widget.user,
                  auth: widget.auth,
                  trade: widget.trade),
            );
          },
          child: Text("Mon application MOn application mon application Mon"),
        ),
      ),
      body: SafeArea(
          child: Stack(
        children: [
          ///Affiche le bouton Drawer
          Positioned(
            left: 15,
            top: 5,
            child: IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.black,
                size: 40,
              ),
              onPressed: () => scaffoldKey.currentState.openDrawer(),
            ),
          ),

          AnimatedButtom3(
            auth: widget.auth,
            user: widget.user,
            login: widget.login,
            trade: widget.trade,
          ),
          Positioned(
            right: 15,
            top: 15,
            child: GestureDetector(
              onTap: () {
                return showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Column(
                      children: [
                        if (!widget.trade)
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
                                SingleChildScrollView(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Créer un parcours'),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('Couleur du parcours :'),
                                                  SizedBox(height: 10),
                                                  ColorPicker(
                                                    pickerColor: textColor,
                                                    onColorChanged:
                                                        changeTextColor,
                                                    pickerAreaHeightPercent:
                                                        0.8,
                                                  ),
                                                  SizedBox(height: 10),
                                                  TextField(
                                                    controller:
                                                        _textEditingController,
                                                    decoration: InputDecoration(
                                                        hintText:
                                                            'Entrez le nom du parcours'),
                                                    onChanged: (text) {
                                                      // Convertit la première lettre en majuscule
                                                      _textEditingController
                                                              .value =
                                                          TextEditingValue(
                                                        text: text.length > 0
                                                            ? text[0]
                                                                    .toUpperCase() +
                                                                text.substring(
                                                                    1)
                                                            : '',
                                                        selection:
                                                            _textEditingController
                                                                .selection,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
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
                                                onPressed: () async {
                                                  // Sauvegarde du texte entré
                                                  final newText =
                                                      _textEditingController
                                                          .text;

                                                  //couleur en hexadecimal
                                                  String hexColor =
                                                      colorToString(textColor);
                                                  fonctionStockeFirebase(
                                                      newText);
                                                  fonctionAjoutCouleur(
                                                      newText, hexColor);
                                                  if (newText.isNotEmpty) {
                                                    savedElements.add(
                                                        SavedElement(
                                                            newText,
                                                            textColor,
                                                            '0',
                                                            false));
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
                                          color:
                                              Color.fromARGB(255, 33, 44, 243)),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.trade)
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '   All courses',
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
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Create a course'),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('Course color :'),
                                                  SizedBox(height: 10),
                                                  ColorPicker(
                                                    pickerColor: textColor,
                                                    onColorChanged:
                                                        changeTextColor,
                                                    pickerAreaHeightPercent:
                                                        0.8,
                                                  ),
                                                  SizedBox(height: 10),
                                                  TextField(
                                                    controller:
                                                        _textEditingController,
                                                    decoration: InputDecoration(
                                                        hintText:
                                                            'Enter the name of the course'),
                                                    onChanged: (text) {
                                                      // Convertit la première lettre en majuscule
                                                      _textEditingController
                                                              .value =
                                                          TextEditingValue(
                                                        text: text.length > 0
                                                            ? text[0]
                                                                    .toUpperCase() +
                                                                text.substring(
                                                                    1)
                                                            : '',
                                                        selection:
                                                            _textEditingController
                                                                .selection,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text('OK'),
                                                onPressed: () async {
                                                  // Sauvegarde du texte entré
                                                  final newText =
                                                      _textEditingController
                                                          .text;

                                                  //couleur en hexadecimal
                                                  String hexColor =
                                                      colorToString(textColor);
                                                  fonctionStockeFirebase(
                                                      newText);
                                                  fonctionAjoutCouleur(
                                                      newText, hexColor);
                                                  if (newText.isNotEmpty) {
                                                    savedElements.add(
                                                        SavedElement(
                                                            newText,
                                                            textColor,
                                                            '0',
                                                            false));
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
                                          color:
                                              Color.fromARGB(255, 33, 44, 243)),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        parcoursSupprime(
                          trade: widget.trade,
                          liste: savedElements,
                          deleteTexte: deleteTexte,
                        )
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                  width: 40,
                  height: 40,
                  child: Stack(
                    children: [
                      Positioned(
                        right: 1,
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: Color.fromRGBO(206, 63, 143, 1),
                        ),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromRGBO(206, 63, 143, 1),
                            ),
                          ))
                    ],
                  )),
            ),
          ),

          ///Affiche le bouton ABCD aire

          Positioned(
              right: 58,
              top: 13,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _idArticle = null;
                    _favorisVisible = false;
                    _rechercheVisible = !_rechercheVisible;
                  });
                },
                child: Container(
                  height: 40,
                  child: IconButton(
                    icon: Image.asset(
                      'assets/images/icones/ICON_LIVRE.png',
                      color: Color.fromRGBO(206, 63, 143, 1),
                    ),
                  ),
                ),
              )),
          Positioned(
            left: 0,
            top: 45,
            child: BoutonParcoursItem(
              liste: savedElements,
              dropdownValue: widget.dropDownValue,
              buttonText: buttonText,
              stcokeeParcours: stcokeeParcours,
              trade: widget.trade,
            ),
          ),
          Positioned(
            left: 0,
            top: 85,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Scrollbar(
                      child: ListView.builder(
                          itemCount: widget.articless.length,
                          itemBuilder: (ctx, index) => Column(
                                children: [
                                  Consumer<ArticleProvider>(
                                    builder: (_, articlesData, child) {
                                      _article = articlesData.markerToArticle(
                                          widget.articless[index].id);
                                      if (widget.articless[index].audio
                                              .isNotEmpty &&
                                          _articleWithAudio == null)
                                        _articleWithAudio = _article;

                                      return FutureBuilder<Object>(
                                          future: _article.audio.isEmpty
                                              ? null
                                              : (!widget.trade)
                                                  ? FirebaseStorage.instance
                                                      .ref()
                                                      .child(_article.audio)
                                                      .getDownloadURL()
                                                  : (_article
                                                          .audioEN.isNotEmpty)
                                                      ? FirebaseStorage.instance
                                                          .ref()
                                                          .child(
                                                              articleList[index]
                                                                  .audioEN)
                                                          .getDownloadURL()
                                                      : null,
                                          builder: (context, snapshot) {
                                            if (_article.audio.isNotEmpty &&
                                                _snapshot == null)
                                              _snapshot = snapshot.data;
                                            return InkWell(
                                              onTap: () {
                                                for (int i = 0;
                                                    i < articleMarker.length;
                                                    i++) {
                                                  if (articleMarker[i]
                                                          .idArticle ==
                                                      widget.articless[index]
                                                          .id) {
                                                    widget.latling1 =
                                                        articleMarker[i]
                                                            .latitude;
                                                    widget.latling2 =
                                                        articleMarker[i]
                                                            .longitude;
                                                  }
                                                }
                                                ;
                                                if (widget.latling1 != null &&
                                                    widget.latling2 != null) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            RechercheScreen(
                                                              auth: widget.auth,
                                                              user: widget.user,
                                                              login:
                                                                  widget.login,
                                                              trade:
                                                                  widget.trade,
                                                              article1: widget
                                                                  .articless[
                                                                      index]
                                                                  .id,
                                                              latling1: widget
                                                                  .latling1,
                                                              latling2: widget
                                                                  .latling2,
                                                            )),
                                                  );
                                                }
                                              },
                                              child: FutureBuilder<Object>(
                                                  future: _article.audio.isEmpty
                                                      ? null
                                                      : (!widget.trade)
                                                          ? FirebaseStorage
                                                              .instance
                                                              .ref()
                                                              .child(_article
                                                                  .audio)
                                                              .getDownloadURL()
                                                          : (_article.audioEN
                                                                  .isNotEmpty)
                                                              ? FirebaseStorage
                                                                  .instance
                                                                  .ref()
                                                                  .child(articleList[
                                                                          index]
                                                                      .audioEN)
                                                                  .getDownloadURL()
                                                              : null,
                                                  builder: (context, snapshot) {
                                                    if (_article
                                                            .audio.isNotEmpty &&
                                                        _snapshot == null)
                                                      _snapshot = snapshot.data;

                                                    return parcoursItemList(
                                                        delete:
                                                            deleteItemParcours,
                                                        idarticle: widget
                                                            .articless[index]
                                                            .id,
                                                        nomParcours: widget
                                                            .dropDownValue,
                                                        article: widget
                                                            .articless[index],
                                                        trade: widget.trade,
                                                        articleCallback:
                                                            _articleCallback,
                                                        snapshot: snapshot.data,
                                                        lance: lance,
                                                        audioPlayer:
                                                            audioPlayer,
                                                        audioState: audioState,
                                                        secondArticle:
                                                            _articleWithAudio,
                                                        isPopUpOpen:
                                                            _isPopupOpen,
                                                        updateDuration:
                                                            updateDuration,
                                                        savedMaxDuration:
                                                            savedMaxDuration,
                                                        savedPosition:
                                                            savedPosition,
                                                        firstLaunchOfArticle:
                                                            firstLaunchOfArticle,
                                                        setFirstLaunchOfArticle:
                                                            setFirstLaunchOfArticle,
                                                        afficherArticle:
                                                            _afficherArticle,
                                                        updateMarkerForPopUp:
                                                            updateMarkerForPopUp,
                                                        play: play,
                                                        pausePlayer:
                                                            pausePlayer,
                                                        stopPlayer: stopPlayer,
                                                        markersData:
                                                            markersData,
                                                        articlesData:
                                                            articlesData);
                                                  }),
                                            );
                                          });
                                    },
                                  ),
                                  Divider(
                                    color: Colors.white,
                                    height: 4,
                                    endIndent: 40,
                                    indent: 40,
                                    thickness: 1,
                                  )
                                ],
                              )),
                    ),
                  ),
                ],
              ),
            ),
          ),

          ///Affiche les recherches
          if (_rechercheVisible)
            Recherche(
              showMap: _showMap,
              filterMap: filterMap,
              trade: widget.trade,
            ),
        ],
      )),

      //Afficher la bouton verte tout en bas de l'audio
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ((lance && _article.audio.isNotEmpty) ||
              (lance && _article.audio.isEmpty))
          ? SwipeDetector(
              swipeConfiguration: SwipeConfiguration(
                verticalSwipeMinVelocity: 1.0,
                verticalSwipeMinDisplacement: 1.0,
              ),
              onSwipeUp: () => openAudio(),
              child: AudioBottomBar(
                article: _articleWithAudio,
                trade: widget.trade,
                audioPlayer: audioPlayer,
                snapshot: _snapshot,
                audioState: audioState,
                lance: lance,
                play: play,
                pausePlayer: pausePlayer,
                stopPlayer: stopPlayer,
                isPopupOpen: _isPopupOpen,
                articleCallback: _articleCallback,
                savedMaxDuration: savedMaxDuration,
                savedPosition: savedPosition,
                updateDuration: updateDuration,
                afficherArticle: _afficherArticle,
                marker: markerForBottomBar,
                updateMarkerForPopUp: updateMarkerForPopUp,
                markersData: markersData,
                articlesData: articleData,
              ),
            )
          : Container(),
    );
  }
}
