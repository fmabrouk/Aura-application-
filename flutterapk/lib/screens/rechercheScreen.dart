import 'dart:async';

import 'dart:ui';
import 'dart:math' as math;

import 'package:aura2/widgets/rechercheWidgets/barreRecherche.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:cron/cron.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../models/User.dart';
import '../models/tag.dart';
import '../widgets/audioWidgets/audio.dart';
import '../widgets/audioWidgets/audioBottomBar.dart';
import '../widgets/favorisWidgets/animatedbuttom.dart';
import '../widgets/favorisWidgets/boutonNord.dart';
import '../widgets/favorisWidgets/parcoursSupprime.dart';
import 'authentificationScreen/LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/tagProvider.dart';
import '../widgets/commentaireWidgets/fenetreArticleCom.dart';
import '../widgets/markerWidgets/balise.dart';
import '../models/article.dart';
import '../models/customMarker.dart';
import '../providers/articleProvider.dart';
import '../providers/favoriteProvider.dart';
import '../providers/markerProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../widgets/favorisWidgets/listeFavoris.dart';
import '../widgets/markerWidgets/recherche.dart';
import '../widgets/drawer.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class RechercheScreen extends StatefulWidget {
  RechercheScreen(
      {Key key,
      this.user,
      this.auth,
      this.login,
      this.trade,
      this.article1,
      this.latling1,
      this.latling2})
      : super(key: key);

  final bool auth;

  final User login;
  double latling1;
  double latling2;

  final UserCustom user;
  String article1;

  /// Permet de savoir si la page doit être traduite en anglais
  bool trade;

  @override
  _RechercheScreenState createState() => _RechercheScreenState();
}

class _RechercheScreenState extends State<RechercheScreen> {
  /// Etat de la fenetre Favori
  bool _favorisVisible = false;

  ///Etat de la fenetre Liste
  bool _listeVisible = false;

  /// Etat de la fenetre Recherche
  bool _rechercheVisible = false;

  /// Donnée de la position courant de l'utilisateur
  LocationData _currentLocation;

  /// Statut des permissions
  PermissionStatus _permissionGranted;

  /// List des marquers filtrés à afficher
  List<CustomMarker> _markersFiltered = [];

  /// Verifie si c'est la premiere fois que le widget est build
  bool firstRun = true;

  /// Indique s'il on fait directement la transition entre deux articles
  bool _switchArticle = false;

  /// Position initiale de la map
  LatLng centerMap = LatLng(48.85952489020911, 2.3406119299690786);

  /// Position d'un article
  double _position = (window.physicalSize.height / window.devicePixelRatio) -
      200 -
      kBottomNavigationBarHeight;

  bool _serviceEnabled;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  MapController mapController = MapController();

  /// Zoom de la map
  double zoomMap = 13.5;

  bool isInit = false;

  /// Marker qui va permettre de se rendre sur le marker apres l'appuie de la notif (geoloc)
  CustomMarker last_art_geoloc;

  /// Marker qui va permettre de se rendre sur le marker apres l'appuie de la notif (freq)
  CustomMarker last_art_freq;

  /// Liste de 3 markers qui va permettre de se rendre sur le marker apres l'appuie de la notif (geoloc)
  List<CustomMarker> art_geoloc = [];

  /// Liste de 3 markers qui va permettre de se rendre sur le marker apres l'appuie de la notif (freq)
  List<CustomMarker> art_freq = [];

  /// Liste de tous les markers
  List<CustomMarker> list;

  /// Liste de tous les articles
  List<Article> list_article = [];

  /// Liste de tous les tags
  List<Tag> liste_tags = [];

  /// Liste de tous les articles avec du texte
  List<Article> list_articles_pink = [];

  /// Cron qui permet d'executer un script a une heure donnée
  final cron = Cron();

  ///Taille du telephone
  Size windowSize = MediaQueryData.fromWindow(window).size;

  /// Utilisateur courant
  UserCustom user;

  //Le player permettant de gerer l'audio
  AudioPlayer audioPlayer = new AudioPlayer();

  /// Vrai si l'audio est en cours
  /// Faux si l'audio est Ã  l'arret
  bool audioState = false;

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

  //Permet de savoir si une notification a été créée.
  Map notifCreated = new Map();

  bool test = false;

  var resultList = [];

  @override
  void initState() {
    super.initState();

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Allow Notification'),
                  content: Text('We want to send you notifications'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Dont allow',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    ),
                    TextButton(
                      onPressed: () => AwesomeNotifications()
                          .requestPermissionToSendNotifications()
                          .then((_) => Navigator.pop(context)),
                      child: Text(
                        'Allow',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ));
      }

      AwesomeNotifications().actionStream.listen((recievedNotification) {
        if (recievedNotification.id > 2 && recievedNotification.id < 6) {
          setState(() {
            mapController.move(
                LatLng(last_art_freq.latitude, last_art_freq.longitude), 17);
          });

          ///Simule un appuie sur l'ecran pour pouvoir afficher l'article
          Timer(const Duration(milliseconds: 700), (() {
            WidgetsBinding.instance.handlePointerEvent(PointerDownEvent(
              pointer: 0,
              position: Offset(windowSize.width / 2, windowSize.height / 2),
            ));
            WidgetsBinding.instance.handlePointerEvent(PointerUpEvent(
              pointer: 0,
              position: Offset(windowSize.width / 2, windowSize.height / 2),
            ));
          }));
        }
        if (recievedNotification.id <= 2 && recievedNotification.id >= 0) {
          setState(() {
            mapController.move(
                LatLng(last_art_geoloc.latitude, last_art_geoloc.longitude),
                17);
          });
          Timer(const Duration(milliseconds: 700), (() {
            WidgetsBinding.instance.handlePointerEvent(PointerDownEvent(
              pointer: 0,
              position: Offset(windowSize.width / 2, windowSize.height / 2),
            ));
            WidgetsBinding.instance.handlePointerEvent(PointerUpEvent(
              pointer: 0,
              position: Offset(windowSize.width / 2, windowSize.height / 2),
            ));
          }));
          // art_geoloc[recievedNotification.id] = null;
        }
      });
    });
    _getCurrentUserLocation();

    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      await Provider.of<ArticleProvider>(context, listen: false)
          .fetchAndSetArticle();
      Provider.of<MarkerProvider>(context, listen: false).fetchAndSetMarker();
      Provider.of<TagProvider>(context, listen: false).fetchAndSetTag();

      if (widget.login != null) {
        await FirebaseFirestore.instance
            .collection('utilisateur')
            .get()
            .then((QuerySnapshot querySnapshot) => querySnapshot.docs
                    .forEach((QueryDocumentSnapshot element) async {
                  if (element.id == widget.login.uid) {
                    var x = element.get('favoris');
                    List<String> listFav = [...x];
                    user = UserCustom(
                      id: element.id,
                      nom: element.get('name'),
                      prenom: element.get('prenom'),
                      eMail: element.get('eMail'),
                      phone: element.get('phone'),
                      dateNaissance: element.get('dateNaissance'),
                      passeword: element.get('password'),
                      sexe: element.get('sexe'),
                      favoris: listFav,
                      isAdmin: element.get('isAdmin'),
                      range: element.get('range'),
                      freq: element.get('freq'),
                    );
                  }
                }))
            .catchError((onError) => throw onError);
      } else {
        user = widget.user;
      }

      if (widget.auth) {
        Provider.of<FavoriteProvider>(context, listen: false)
            .fetchAndSetFavoris();
      }
    });

    Timer.periodic(Duration(minutes: 5), (timer) {
      if (user != null) {
        if (user.range == false && _currentLocation != null) {
          isNearMarkers(list, list_article, liste_tags, 100);
        }
        if (user.range == true && _currentLocation != null) {
          isNearMarkers(list, list_article, liste_tags, 300);
        }
      }
    });
    Timer.periodic(Duration(seconds: 1), (timer) {
      Cron croon = new Cron();
      if (user != null && list_articles_pink.length != 0 && !test) {
        if (user.freq == 0) {
          croon.schedule(Schedule.parse('30 9 * * *'), () async {
            discoverMarker(list_articles_pink, list, liste_tags);
            croon.close();
          });
        }
        if (user.freq == 1) {
          croon.schedule(Schedule.parse('30 9 * * 1'), () async {
            discoverMarker(list_articles_pink, list, liste_tags);
            croon.close();
          });
        }
        if (user.freq == 2) {
          croon.schedule(Schedule.parse('30 9 1 * *'), () async {
            discoverMarker(list_articles_pink, list, liste_tags);
            croon.close();
          });
        }
        test = true;
      }
    });
  }

  Future<void> _getCurrentUserLocation() async {
    Location location = Location();

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        location.enableBackgroundMode(enable: true);
        return;
      }
    }

    _currentLocation = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation != null) {
        setState(() {
          _currentLocation = currentLocation;
        });
      }
    });
  }

  /// Fonction qui envoie une notif "geolocalisation"
  void isNearMarkers(List<CustomMarker> liste, List<Article> article,
      List<Tag> tags, int rayon) {
    if (_currentLocation != null) {
      for (int i = 0; i < liste.length; i++) {
        double dist = calculateDist(_currentLocation.latitude,
            liste[i].latitude, _currentLocation.longitude, liste[i].longitude);
        if (dist < rayon) {
          Article art;
          last_art_geoloc = liste[i];
          String str = "";
          for (int j = 0; j < article.length; j++) {
            if (liste[i].idArticle == article[j].id) {
              art = article[j];
              for (int k = 0; k < art.tags.length; k++) {
                for (int m = 0; m < tags.length; m++) {
                  if (art.tags[k] == tags[m].id && art.tags.length > 0) {
                    str = str + ', ' + tags[m].label;
                  }
                }
              }
              if (str.length > 3) {
                str = str.substring(2, str.length);
              }
            }
          }
          if (!notifCreated.containsKey(art.id)) {
            //createNotifs(art, str);
            notifCreated[art.id] = true;
          }
        }
      }
    }
  }

  /// Fonction qui envoie une notifs "fréquence"
  void discoverMarker(
      List<Article> articlePink, List<CustomMarker> liste, List<Tag> tags) {
    var rng = math.Random();
    int random = rng.nextInt(articlePink.length);
    Article art;

    art = articlePink[random];
    for (int i = 0; i < liste.length; i++) {
      if (art.id == liste[i].idArticle) {
        last_art_freq = liste[i];
        print(art.id);
        print(last_art_freq.id);
        print(liste[i].idArticle);

        print(art.id == liste[i].idArticle);
        break;
      }
    }

    String str = "";
    for (int k = 0; k < art.tags.length; k++) {
      for (int m = 0; m < tags.length; m++) {
        if (art.tags[k] == tags[m].id && art.tags.length > 0) {
          str = str + ', ' + tags[m].label;
        }
      }
    }
    if (str.length > 3) {
      str = str.substring(2, str.length);
    }
    //createNotifFreq(art, str);
  }

  /// Fonction qui calcule la distance en mètres entre deux points point en fonctions de leur latitude et longitude
  double calculateDist(double lat1, double lat2, double long1, double long2) {
    int r = 6371;
    double dlat = (lat2 - lat1) * (math.pi / 180);
    double dlong = (long2 - long1) * (math.pi / 180);
    double a = math.sin(dlat / 2) * math.sin(dlat / 2) +
        math.cos(lat1 * (math.pi / 180)) *
            math.cos(lat2 * (math.pi / 180)) *
            math.sin(dlong / 2) *
            math.sin(dlong / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double dist = r * c * 1000;
    return dist;
  }

  /// permet d'indiquer si l'on est passé d'un article à un autre
  void _setSwitchFalse() {
    _switchArticle = false;
  }

  /// Ferme les fenetres 'list des favoris' et 'recherche'
  void _showMap() {
    setState(() {
      _favorisVisible = false;
      _rechercheVisible = false;
      _listeVisible = false;
    });
  }

  //permet de changer la valeur de traduction dans cette page lorsqu'on le change dans DrawerCustom
  void _tradeCallBack(bool tradu) {
    setState(() {
      widget.trade = tradu;
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

  int tag = 0;

  @override
  Widget build(BuildContext context) {
    final markersData = Provider.of<MarkerProvider>(context);
    final favoriteData = Provider.of<FavoriteProvider>(context);
    final _height = MediaQuery.of(context).size.height;
    final articleData = Provider.of<ArticleProvider>(context);
    final tags = Provider.of<TagProvider>(context);

    list = markersData.getAllMarkers();
    list_article = articleData.getAllArticles();
    liste_tags = tags.tags;
    list_articles_pink = articleData.getAllArticlesWithText();

    final articleProvider = Provider.of<ArticleProvider>(context);
    final articleListImage =
        Provider.of<ArticleProvider>(context).getAllArticlesImage().toList();
    final articleListWithoutImage = Provider.of<ArticleProvider>(context)
        .getAllArticlesWithoutImage()
        .toList();

    articleListImage.sort(((a, b) => a.title.compareTo(b.title)));
    articleListWithoutImage.sort(((a, b) => a.title.compareTo(b.title)));
    //articleList.sort(((a, b) => a.title.compareTo(b.title)));

    final articleLists = articleListImage + articleListWithoutImage;
    final TextEditingController _textEditingController =
        TextEditingController();

    final DocumentReference documentReference = FirebaseFirestore.instance
        .collection('utilisateur')
        .doc(FirebaseAuth.instance.currentUser.uid);

    //parametrre pour stocker les donnes depuis firebase
    List<String> arrayFieldNames = [];

    //fonction qui recupere les donnes de type tableau  depuis firebase
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

    //fonction qui récupere la taille des tableau parcours
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

    //Coleur par defaut
    Color textColor = Colors.black;

    //fonction changer de couelur pour color picker
    void changeTextColor(Color color) {
      setState(() {
        textColor = color;
      });
    }

    /// Liste des markers (id) en favori de l'utilisateur
    List<String> listeUserFavori;

    List<String> options = ['Carte', 'Liste'];

    if (widget.auth) {
      listeUserFavori = [...favoriteData.favoris];
    }

    /// @args - id Identifiant d'un marqueur
    /// Change l'etat 'isFavorite' d'un marker
    void changeFavorite(String id) {
      CustomMarker _marker =
          markersData.markers.firstWhere((item) => item.id == id);
      if (_marker.isFavorite) {
        markersData.unfavorite(id);
        favoriteData.delete(_marker.id, _marker);
      } else {
        markersData.favorite(id);
        favoriteData.add(_marker);
        favoriteData.addFavoris(_marker.id);

        FirebaseFirestore.instance
            .collection('/utilisateur')
            .doc(user.id)
            .update({'favoris': favoriteData.favoris});
      }
    }

    // Supprimer un élément de la liste
    Future<void> deleteItem(String itemName) async {
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

    // Initialise le visuelle des markers favoris

    if (widget.auth) {
      listeUserFavori.forEach((element) {
        CustomMarker _marker =
            markersData.markers.firstWhere((item) => item.id == element);
        _marker.isFavorite = true;
      });
    }
    if (_permissionGranted == PermissionStatus.granted &&
        _currentLocation != null &&
        firstRun == true) {
      setState(() {
        firstRun = false;
      });
    }

    // Ferme l'article si la fenêtre est totalement caché
    if (_position == _height) {
      setState(() {
        _position = _height - 200 - kBottomNavigationBarHeight;

        widget.article1 = null;
        markersData.resetAllMarker();
      });
    }

    /// @args details Donnée du mouvement d'un pointer
    /// Change la position de l'article
    void _slide(DragUpdateDetails details) {
      setState(() {
        _position += details.delta.dy * 1.5;
      });
    }

    /// @args la nouvelle position de l'article
    /// permet de modifier la position de l'article
    void _setPosition(double pos) {
      _position = pos;
    }

    /// Ouvre un article
    void openMarker(CustomMarker item) {
      setState(() {
        mapController.moveAndRotate(
            LatLng(item.latitude, item.longitude), 17, 0);
        if (widget.auth) {
          _position = _height - 200 - kBottomNavigationBarHeight;
          markersData.resetMarker(item);
          item.isVisible = !item.isVisible;

          if (widget.article1 != null) {
            if (markersData.markerOpen()) {
              widget.article1 = item.idArticle;
              _switchArticle = true;
            } else
              widget.article1 = null;
          } else
            widget.article1 = item.idArticle;
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      });
    }

    if (widget.article1 == null) {
      setState(() {
        _switchArticle = false;
      });
    }

    /// Représente toutes les balises
    final balises = Balise(
        context: context,
        markersFiltered: _markersFiltered,
        zoomMap: zoomMap,
        openMarker: openMarker);

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

    /// @args - marker marqueur
    /// Affiche l'article sélectionné depuis la liste des favoris
    void _afficherArticle(CustomMarker marker) {
      setState(() {
        _favorisVisible = false;
        _rechercheVisible = false;
        widget.article1 = marker.idArticle;
        _position = 1;
        marker.isVisible = true;

        mapController.moveAndRotate(
            LatLng(marker.latitude, marker.longitude), 17, 0);
      });
    }

    /// @args - marker marqueur
    /// Affiche l'article sélectionné depuis la liste des favoris
    void _centerMarker(CustomMarker marker) {
      setState(() {
        _favorisVisible = false;
        _rechercheVisible = false;
        mapController.moveAndRotate(
            LatLng(marker.latitude, marker.longitude), 17, 0);
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
                      user: widget.user,
                      auth: widget.auth,
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
            //Affiche la map
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                onTap: (map, x) {
                  setState(() {
                    _position = _height;
                  });
                },
                onPositionChanged: (map, x) {
                  if (x) {
                    setState(() {
                      zoomMap = map.zoom;
                    });
                  }
                },
                center: LatLng(widget.latling1, widget.latling2),
                zoom: 17.0,
                maxZoom: 19.0,
                minZoom: 4.2,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      //"https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}",

                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
                ),
                MarkerLayer(
                  markers: [
                    ///Affiche tous les marqueurs
                    ...balises.buildAllMarker(),

                    ///Affiche l'utilisateur
                    if (_currentLocation != null)
                      Marker(
                          width: 35.0,
                          height: 35.0,
                          point: LatLng(_currentLocation.latitude,
                              _currentLocation.longitude),
                          builder: (ctx) => Image(
                              image:
                                  AssetImage('assets/images/utilisateur.png'))),
                  ],
                ),
              ],
            ),

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
            //bouton "Carte" et "liste"
            AnimatedButtom(
              auth: widget.auth,
              user: widget.user,
              login: widget.login,
              trade: widget.trade,
            ),

            ///Affiche le bouton Favori

            Positioned(
              right: 15,
              top: 15,
              child: GestureDetector(
                onTap: () {
                  return showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Column(
                            children: [
                              if (!widget.trade)
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
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                      Text('Créer un parcours'),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                            'Couleur du parcours :'),
                                                        SizedBox(height: 10),
                                                        ColorPicker(
                                                          pickerColor:
                                                              textColor,
                                                          onColorChanged:
                                                              changeTextColor,
                                                          pickerAreaHeightPercent:
                                                              0.8,
                                                        ),
                                                        SizedBox(height: 10),
                                                        TextField(
                                                          controller:
                                                              _textEditingController,
                                                          decoration:
                                                              InputDecoration(
                                                                  hintText:
                                                                      'Entrez le nom du parcours'),
                                                          onChanged: (text) {
                                                            // Convertit la première lettre en majuscule
                                                            _textEditingController
                                                                    .value =
                                                                TextEditingValue(
                                                              text: text.length >
                                                                      0
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
                                                        Navigator.of(context)
                                                            .pop();
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
                                                            colorToString(
                                                                textColor);
                                                        fonctionStockeFirebase(
                                                            newText);
                                                        fonctionAjoutCouleur(
                                                            newText, hexColor);
                                                        if (newText
                                                            .isNotEmpty) {
                                                          savedElements.add(
                                                              SavedElement(
                                                                  newText,
                                                                  textColor,
                                                                  '0',
                                                                  false));
                                                        }
                                                        Navigator.of(context)
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
                              if (widget.trade)
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                                  title:
                                                      Text('Create a course'),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text('Course color :'),
                                                        SizedBox(height: 10),
                                                        ColorPicker(
                                                          pickerColor:
                                                              textColor,
                                                          onColorChanged:
                                                              changeTextColor,
                                                          pickerAreaHeightPercent:
                                                              0.8,
                                                        ),
                                                        SizedBox(height: 10),
                                                        TextField(
                                                          controller:
                                                              _textEditingController,
                                                          decoration:
                                                              InputDecoration(
                                                                  hintText:
                                                                      'Enter the name of the course'),
                                                          onChanged: (text) {
                                                            // Convertit la première lettre en majuscule
                                                            _textEditingController
                                                                    .value =
                                                                TextEditingValue(
                                                              text: text.length >
                                                                      0
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
                                                        Navigator.of(context)
                                                            .pop();
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
                                                            colorToString(
                                                                textColor);
                                                        fonctionStockeFirebase(
                                                            newText);
                                                        fonctionAjoutCouleur(
                                                            newText, hexColor);
                                                        if (newText
                                                            .isNotEmpty) {
                                                          savedElements.add(
                                                              SavedElement(
                                                                  newText,
                                                                  textColor,
                                                                  '0',
                                                                  false));
                                                        }
                                                        Navigator.of(context)
                                                            .pop();
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
                              parcoursSupprime(
                                trade: widget.trade,
                                liste: savedElements,
                                deleteTexte: deleteTexte,
                              )
                            ],
                          ),
                        );
                      });
                },
                child: Container(
                    width: 40,
                    height: 40,
                    child: Stack(
                      children: [
                        Positioned(
                          right: -6.5,
                          child: Icon(
                            Icons.add,
                            size: 22,
                            color: Color.fromRGBO(206, 63, 143, 1),
                          ),
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 18,
                              height: 18,
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
                right: 63,
                top: 13,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.article1 = null;
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

            ///Affiche le bouton Centrer

            BoutonNord(
              setRotationImage: setRotationImage,
              mapController: mapController,
            ),

            ///Affiche l'article
            if (widget.article1 != null)
              Consumer<ArticleProvider>(
                builder: (_, articlesData, child) {
                  _article = articlesData.markerToArticle(widget.article1);
                  if (_article.audio.isNotEmpty && _articleWithAudio == null)
                    _articleWithAudio = _article;

                  return FutureBuilder<Object>(
                      future: _article.audio.isEmpty
                          ? null
                          : (!widget.trade)
                              ? firebase_storage.FirebaseStorage.instance
                                  .ref()
                                  .child(_article.audio)
                                  .getDownloadURL()
                              : (_article.audioEN.isNotEmpty)
                                  ? firebase_storage.FirebaseStorage.instance
                                      .ref()
                                      .child(_article.audioEN)
                                      .getDownloadURL()
                                  : null,
                      builder: (context, snapshot) {
                        if (_article.audio.isNotEmpty && _snapshot == null)
                          _snapshot = snapshot.data;

                        return FenetreArticleCom(
                            user: user,
                            auth: widget.auth,
                            position: _position,
                            slide: _slide,
                            article: _article,
                            changeFavorite: changeFavorite,
                            deleteItem: deleteItem,
                            idMaker: markersData.markers
                                .firstWhere(
                                    (data) => data.idArticle == widget.article1)
                                .id,
                            like: markersData.markers
                                .firstWhere(
                                    (data) => data.idArticle == widget.article1)
                                .isFavorite,
                            setPosition: _setPosition,
                            switchArticle: _switchArticle,
                            switchFalse: _setSwitchFalse,
                            trade: widget.trade,
                            articleCallback: _articleCallback,
                            snapshot: snapshot.data,
                            lance: lance,
                            audioPlayer: audioPlayer,
                            audioState: audioState,
                            secondArticle: _articleWithAudio,
                            isPopUpOpen: _isPopupOpen,
                            updateDuration: updateDuration,
                            savedMaxDuration: savedMaxDuration,
                            savedPosition: savedPosition,
                            firstLaunchOfArticle: firstLaunchOfArticle,
                            setFirstLaunchOfArticle: setFirstLaunchOfArticle,
                            afficherArticle: _afficherArticle,
                            marker: markersData.markers.firstWhere(
                              (data) => data.idArticle == widget.article1,
                            ),
                            updateMarkerForPopUp: updateMarkerForPopUp,
                            play: play,
                            pausePlayer: pausePlayer,
                            stopPlayer: stopPlayer,
                            markersData: markersData,
                            articlesData: articleData);
                      });
                },
              ),

            ///Affiche la liste des favoris
            if (_favorisVisible)
              ListFavoris(
                afficherArticle: _afficherArticle,
                showMap: _showMap,
                centerMarker: _centerMarker,
                trade: widget.trade,
              ),

            ///Affiche les recherches
            if (_rechercheVisible)
              Recherche(
                showMap: _showMap,
                filterMap: filterMap,
                trade: widget.trade,
              ),
          ],
        ),
      ),
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

  setRotationImage(double degrees) {
    final angle = degrees * math.pi / 180;
    return angle;
  }
}
