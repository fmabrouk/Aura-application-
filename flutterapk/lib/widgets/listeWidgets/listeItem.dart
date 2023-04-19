import 'package:firebase_storage/firebase_storage.dart';

import '../../models/article.dart';

import '../../models/customMarker.dart';
import '../../models/tag.dart';
import '../../providers/articleProvider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/markerProvider.dart';
import '../../providers/tagProvider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../audioWidgets/audio.dart';

class ListeItem extends StatefulWidget {
  ListeItem(
      {this.trade,
      this.article,
      this.firstLaunchOfArticle,
      this.secondArticle,
      this.audioState,
      this.play,
      this.snapshot,
      this.audioPlayer,
      this.lance,
      this.pausePlayer,
      this.stopPlayer,
      this.isPopUpOpen,
      this.savedMaxDuration,
      this.savedPosition,
      this.updateDuration,
      this.afficherArticle,
      this.marker,
      this.setFirstLaunchOfArticle,
      this.updateMarkerForPopUp,
      this.articleCallback,
      this.articlesData,
      this.markersData});

  final Article article;
  final bool firstLaunchOfArticle;
  //Un second article
  final Article secondArticle;
//Permet de savoir si l'audio est en cours ou non
  final bool audioState;

  //La fonction qui permet de lancer l'audio
  final Function play;

  //Snapshot d'où provient l'audio
  final String snapshot;

  /// Permet de savoir si la page doit être traduite en anglais
  bool trade;

  //L'audioPlayer qui permet de jouer/mettre en pause un article
  final AudioPlayer audioPlayer;
  //Permet de savoir si le popUp est lancé ou non
  final bool lance;

  //La fonction qui permet de pause l'audio
  final Function pausePlayer;

  //La fonction qui permet d'areter l'audio
  final Function stopPlayer;

  //Fonction callBack qui permet de renvoyer le booleen vers CarteScreen permettant de savoir si le popUp est ouvert
  final Function(bool) isPopUpOpen;

  //Permet de sauvegarder la durée max d'un audio
  final Duration savedMaxDuration;

  //Permet de sauvegarder la position d'un audio
  final Duration savedPosition;

  //Fonction callBack permettant de remonter les données de savedPosition et savedMaxPosition vers CarteScreen
  final Function(Duration, Duration) updateDuration;

  //Permet de set le bool à true
  final Function setFirstLaunchOfArticle;

  //Fonction qui permet d'ouvrir un article depuis le popupp audio
  final Function afficherArticle;

  //Le marker conrrespondant à l'article courant
  final CustomMarker marker;

  //Fonction pour actualiser le marker utilisé dans audioBottomBar
  final Function(CustomMarker) updateMarkerForPopUp;

  //Fonction callBack qui permet de "faire remonter" les données d'un article vers "CarteScreen"
  final Function(Article, AudioPlayer, bool, String) articleCallback;

  //Les markers de l'application
  final MarkerProvider markersData;

  //Les articles de l'application
  final ArticleProvider articlesData;
  @override
  _ListeItemState createState() => _ListeItemState();
}

class _ListeItemState extends State<ListeItem> {
  Article article;

  // Le nouvel article qui sera retourner dans carteScreen
  Article newArticle;

  //La nouvelle snapshot qui sera retourné dans carteScreen
  String newSnapshot;

  // Savoir si c'est un nouvel audio ou pas
  bool newAudio = false;

  // Le nouveau state qui sera retourner dans carteScreen
  bool newState;

  Future<String> getImage(Article article, [bool test = false]) async {
    String snap = "";
    if (test) {
      snap = await FirebaseStorage.instance
          .ref()
          .child(article.image)
          .getDownloadURL();
    }
    return snap;
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

  double _sizeInfo = 16;
  @override
  Widget build(BuildContext context) {
    final articlesData = Provider.of<ArticleProvider>(context, listen: false);
    List<String> options = articlesData.getListTitle();
    options.sort((a, b) => a.compareTo(b));
    List<String> labels = Provider.of<TagProvider>(context, listen: false)
        .listLabel(widget.article.tags, widget.trade);
    List<Tag> _labels = Provider.of<TagProvider>(context).tags;
    labels.sort((a, b) => a.compareTo(b));

    /// @return Renvoi le titre de l'article
    String getTitle() {
      return articlesData.markerToArticle(widget.article.id).title;
    }

    /// @return Renvoi le titre de l'article
    String getTitleEn() {
      return articlesData.markerToArticle(widget.article.id).titleEN;
    }

    /// @return Renvoi l'architecte titre de l'article
    String getArchitecte() {
      return articlesData.markerToArticle(widget.article.id).architecte;
    }

    /// @return Renvoi la date de l'article
    String getDate() {
      return articlesData.markerToArticle(widget.article.id).date;
    }

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

    return ClipRect(
      child: Container(
        child: Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.article.title ==
                  "Manufacture sur Seine - Quartier Terre")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/Manufacture sur Seine Quartier Terre/reinventer-seine-manufacture-seine-amateur.jpg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Centre ville de Montreuil Sous Bois")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/Centre Ville de Montreuil sous Bois Alvaro Siza/Croquis Siza Centre Ville Montreuil.jpg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "La Grande Arche")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage("assets/La Grande Arche/IMG_3992.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Fondation Louis Vuitton")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/Fondation Louis Vuitton/IMG_1330.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "100 logements sociaux")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage("assets/IMG_4027.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Stade Jean Bouin")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage("assets/IMG_2083.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "La Tour Triangle")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/La Tour Triangle/La Tour Triangle.jpg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Hôpital Cognacq-Jay")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/Hôpital Cognacq-Jay - Toyo Ito/IMG_9574.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Musée du quai Branly")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image:
                          AssetImage("assets/Musée Quai Branly/IMG_3690.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Espace de méditation UNESCO")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/Espace de Méditation UNESCO - Tadao Ando/IMG_3819.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Showroom Citroën")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image:
                          AssetImage("assets/Showroom Citroën/IMG_3651.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "57 logements Rue Des Suisses")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/57 logements - Herzog et Demeuron/IMG_2681.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title ==
                  "Fondation Cartier pour l'art contemporain")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image:
                          AssetImage("assets/Fondation Cartier/IMG_2195.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title ==
                  "Galerie marchande Gaîté Montparnasse")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/Galerie Marchande Gaîté Montparnasse/03_Gaîté_Montparnasse_MVRDV_©Ossip van Duivenbode.jpg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title ==
                  "Le département des Arts de l'Islam du Louvre")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/Département des Arts de l_Islam du Louvre/PARIS_Departement-des-Arts-de-l-Islam-du-musee-du-Louvre_02b.jpg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "La Pyramide du Louvre")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/La Pyramide du Louvre/IMG_3222.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "La Nouvelle Samaritaine")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/La Nouvelle Saint Maritaine - SANAA/IMG_3967.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "La Fondation Pinault")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage("assets/téléchargement.jpg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "La Canopée")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage("assets/La Canopée/IMG_3297.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Lafayette Anticipation")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage("assets/IMG_3353.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Pavillon Mobile Art Chanel")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/Pavillon Mobile Art Chanel/chanel_mobile_art_pavilion-zaha_hadid_2_photo AA13.jpg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "La Fondation Jérôme Seydoux-Pathé")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage("assets/téléchargement (1).jpg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Pushed Slab")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage("assets/Pushed Slab/IMG_5889.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "M6B2 Tour de la Biodiversité")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage("assets/IMG_7619.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title ==
                  "La Bibliothèque Nationale de France (François Mitterand)")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/Bibliothèque François Mitterand/IMG_6855.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Cité de la mode et du design")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage("assets/Cité de la mode/IMG_7176.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "La Cinémathèque Française")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/La Cinémathèque Française/IMG_8448.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Eden bio")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage("assets/Eden Bio/IMG_4174.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "La Philharmonie")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage("assets/La Philharmonie/IMG_4684.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Le Parc de la Villette")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/Cité de la mode/Le Parc Lavillette/IMG_4727.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "220 logements Rue de Meaux")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/220 Logements rue de Meaux/IMG_2681.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Siège du Parti Communiste Français")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/Siège Parti Communiste/IMG_4383.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.architecte ==
                      "ANNE LACATON et JEAN PHILLIPE VASSAL (France)" &&
                  widget.article.date == "2009")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/La Tour Bois Le Prêtre - Lacaton Vassal/IMG_0689.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.architecte ==
                      "Aires Mateus (Portugal) et AAVP (France)" &&
                  widget.article.date == "2018")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage("assets/Emergence/IMG_0324.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Tower Flower")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage("assets/Tower Flower/IMG_0269.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Beaubourg")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage("assets/Beaubourg/IMG_3334.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Institut du Monde Arabe")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/Institut Monde Arabe/IMG_8831.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Le Tribunal de Paris")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/Cité de la mode/Le Tribunal de Paris/IMG_0321.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.title == "Villa Dall'Ava")
                Container(
                    height: 120,
                    width: 120,
                    child: Image(
                      image: AssetImage(
                          "assets/Villa d_all_Ava - Oma/IMG_3076.jpeg"),
                      fit: BoxFit.cover,
                    )),
              if (widget.article.image.isEmpty)
                Container(
                  height: 120,
                  width: 120,
                  child: Image.asset('assets/images/AURA_VISUEL02.jpg'),
                ),
              /*if (widget.article.title ==
                  "Manufacture sur Seine - Quartier Terre")
                Expanded(
                  child: Container(
                      height: 120,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "Centre ville de Montreuil Sous Bois")
                !widget.trade
                    ? Expanded(
                        child: Container(
                            height: 189,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      )
                    : Expanded(
                        child: Container(
                            height: 160,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      ),
              if (widget.article.title == "La Grande Arche")
                !widget.trade
                    ? Expanded(
                        child: Container(
                            height: 180,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      )
                    : Expanded(
                        child: Container(
                            height: 150,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      ),
              if (widget.article.title == "Fondation Louis Vuitton")
                Expanded(
                  child: Container(
                      height: 120,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "Stade Jean Bouin")
                !widget.trade
                    ? Expanded(
                        child: Container(
                            height: 120,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      )
                    : Expanded(
                        child: Container(
                            height: 150,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      ),
              if (widget.article.title == "La Tour Triangle")
                Expanded(
                  child: Container(
                      height: 120,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "Hôpital Cognacq-Jay")
                Expanded(
                  child: Container(
                      height: 210,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "Musée du quai Branly")
                Expanded(
                  child: Container(
                      height: 150,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "Espace de méditation UNESCO")
                Expanded(
                  child: Container(
                      height: 120,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "Showroom Citroën")
                Expanded(
                  child: Container(
                      height: 150,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "57 logements Rue Des Suisses")
                Expanded(
                  child: Container(
                      height: 180,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title ==
                  "Fondation Cartier pour l'art contemporain")
                Expanded(
                  child: Container(
                      height: 120,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title ==
                  "Galerie marchande Gaîté Montparnasse")
                Expanded(
                  child: Container(
                      height: 150,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title ==
                  "Le département des Arts de l'Islam du Louvre")
                Expanded(
                  child: Container(
                      height: 130,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "La Pyramide du Louvre")
                Expanded(
                  child: Container(
                      height: 160,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "La Nouvelle Samaritaine")
                Expanded(
                  child: Container(
                      height: 120,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "La Fondation Pinault")
                Expanded(
                  child: Container(
                      height: 180,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "La Canopée")
                !widget.trade
                    ? Expanded(
                        child: Container(
                            height: 120,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      )
                    : Expanded(
                        child: Container(
                            height: 90,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      ),
              if (widget.article.title == "Lafayette Anticipation")
                Expanded(
                  child: Container(
                      height: 120,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "Pavillon Mobile Art Chanel")
                !widget.trade
                    ? Expanded(
                        child: Container(
                            height: 150,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      )
                    : Expanded(
                        child: Container(
                            height: 180,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      ),
              if (widget.article.title == "La Fondation Jérôme Seydoux-Pathé")
                Expanded(
                  child: Container(
                      height: 120,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "Pushed Slab")
                Expanded(
                  child: Container(
                      height: 150,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "M6B2 Tour de la Biodiversité")
                Expanded(
                  child: Container(
                      height: 150,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title ==
                  "La Bibliothèque Nationale de France (François Mitterand)")
                !widget.trade
                    ? Expanded(
                        child: Container(
                            height: 150,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      )
                    : Expanded(
                        child: Container(
                            height: 120,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      ),
              if (widget.article.title == "Cité de la mode et du design")
                Expanded(
                  child: Container(
                      height: 159,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "La Cinémathèque Française")
                Expanded(
                  child: Container(
                      height: 150,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "Eden bio")
                Expanded(
                  child: Container(
                      height: 150,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "La Philharmonie")
                Expanded(
                  child: Container(
                      height: 150,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "Le Parc de la Villette")
                Expanded(
                  child: Container(
                      height: 150,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "Siège du Parti Communiste Français")
                Expanded(
                  child: Container(
                      height: 155,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.architecte ==
                      "ANNE LACATON et JEAN PHILLIPE VASSAL (France)" &&
                  widget.article.date == "2009")
                Expanded(
                  child: Container(
                      height: 220,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.architecte ==
                      "Aires Mateus (Portugal) et AAVP (France)" &&
                  widget.article.date == "2018")
                Expanded(
                  child: Container(
                      height: 190,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "Tower Flower")
                !widget.trade
                    ? Expanded(
                        child: Container(
                            height: 180,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      )
                    : Expanded(
                        child: Container(
                            height: 160,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      ),
              if (widget.article.title == "Beaubourg")
                !widget.trade
                    ? Expanded(
                        child: Container(
                            height: 150,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      )
                    : Expanded(
                        child: Container(
                            height: 180,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      ),
              if (widget.article.title == "Institut du Monde Arabe")
                !widget.trade
                    ? Expanded(
                        child: Container(
                            height: 150,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      )
                    : Expanded(
                        child: Container(
                            height: 180,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: !widget.trade
                                                  ? Text(
                                                      getTitle(),
                                                      // gettitlefromliste(options),
                                                      style: TextStyle(
                                                        fontFamily: 'myriad',
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                      //maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : widget.article.titleEN
                                                          .isEmpty
                                                      ? Text(
                                                          getTitle(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          getTitleEn(),
                                                          // gettitlefromliste(options),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'myriad',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                          //maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                          if (widget.article.audio.isNotEmpty)
                                            IconButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25),
                                              //padding: EdgeInsets.only(top: 4.0),
                                              iconSize: 26,
                                              icon: (!widget
                                                      .firstLaunchOfArticle)
                                                  ? Image.asset(
                                                      "assets/images/ICON_VOLUME_VIOLET.png")
                                                  : (widget.article ==
                                                          widget.secondArticle)
                                                      ? Image.asset(
                                                          "assets/images/ICON_VOLUME.png")
                                                      : Image.asset(
                                                          "assets/images/ICON_VOLUME_VIOLET.png"),
                                              onPressed: () {
                                                newState = widget.audioState;

                                                //Les nouvelles durée initialisé à 0 si on change d'article
                                                //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                                Duration savedPosition =
                                                    new Duration();
                                                Duration savedMaxDuration =
                                                    new Duration();

                                                if (widget.secondArticle !=
                                                        widget.article ||
                                                    (widget.audioState &&
                                                        widget.secondArticle !=
                                                            widget.article)) {
                                                  widget.play(widget.snapshot);
                                                  newState = true;
                                                }
                                                //Le statefulbuilder ne sert plus a rien normalement
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child: Dismissible(
                                                                movementDuration: Duration(
                                                                    seconds: 1),
                                                                key: Key("key"),
                                                                direction:
                                                                    DismissDirection
                                                                        .vertical,
                                                                onDismissed:
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Audio(
                                                                  article: widget
                                                                      .article,
                                                                  trade: widget
                                                                      .trade,
                                                                  audioPlayer:
                                                                      widget
                                                                          .audioPlayer,
                                                                  snapshot: widget
                                                                      .snapshot,
                                                                  audioState: widget
                                                                          .firstLaunchOfArticle
                                                                      ? newState !=
                                                                              null
                                                                          ? newState
                                                                          : widget
                                                                              .audioState
                                                                      : widget
                                                                          .audioState,
                                                                  lance: widget
                                                                      .lance,
                                                                  play: widget
                                                                      .play,
                                                                  pausePlayer:
                                                                      widget
                                                                          .pausePlayer,
                                                                  stopPlayer: widget
                                                                      .stopPlayer,
                                                                  cameFromArticeItem:
                                                                      true,
                                                                  isPopupOpen:
                                                                      widget
                                                                          .isPopUpOpen,
                                                                  updateDuration:
                                                                      widget
                                                                          .updateDuration,
                                                                  savedMaxDuration: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedMaxDuration
                                                                      : savedMaxDuration,
                                                                  savedPosition: (widget
                                                                              .secondArticle ==
                                                                          widget
                                                                              .article)
                                                                      ? widget
                                                                          .savedPosition
                                                                      : savedPosition,
                                                                  firstLaunchOfArticle:
                                                                      widget
                                                                          .firstLaunchOfArticle,
                                                                  setFirstLaunchOfArticle:
                                                                      widget
                                                                          .setFirstLaunchOfArticle,
                                                                  afficherArticle:
                                                                      widget
                                                                          .afficherArticle,
                                                                  marker: widget
                                                                      .marker,
                                                                  updateMarkerForPopUp:
                                                                      widget
                                                                          .updateMarkerForPopUp,
                                                                  articleCallback:
                                                                      widget
                                                                          .articleCallback,
                                                                  randomAudioCallback:
                                                                      randomAudioCallback,
                                                                  articlesData:
                                                                      widget
                                                                          .articlesData,
                                                                  markersData:
                                                                      widget
                                                                          .markersData,
                                                                )),
                                                          );
                                                        })).then(
                                                    (value) => setStateLance());
                                              },
                                            ),
                                        ]),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getArchitecte(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      getDate(),
                                      style: TextStyle(
                                          fontFamily: 'myriad',
                                          color: Colors.black54,
                                          fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    spacing: 3,
                                    children: _buildAllChip().toList(),
                                    runSpacing: 2,
                                  ),
                                ),
                              ],
                            )),
                      ),
              if (widget.article.title == "Le Tribunal de Paris")
                Expanded(
                  child: Container(
                      height: 120,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "Villa Dall'Ava")
                Expanded(
                  child: Container(
                      height: 90,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.title == "100 logements sociaux")
                Expanded(
                  child: Container(
                      height: 120,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),*/
              if (widget.article.image.isNotEmpty)
                Expanded(
                  child: Container(
                      height: 220,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              if (widget.article.image.isEmpty)
                Expanded(
                  child: Container(
                      height: 200,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),
              /*if (widget.article.title == "220 logements Rue de Meaux")
                Expanded(
                  child: Container(
                      height: 155,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: !widget.trade
                                            ? Text(
                                                getTitle(),
                                                // gettitlefromliste(options),
                                                style: TextStyle(
                                                  fontFamily: 'myriad',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                //maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : widget.article.titleEN.isEmpty
                                                ? Text(
                                                    getTitle(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(
                                                    getTitleEn(),
                                                    // gettitlefromliste(options),
                                                    style: TextStyle(
                                                      fontFamily: 'myriad',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    //maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                    if (widget.article.audio.isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        //padding: EdgeInsets.only(top: 4.0),
                                        iconSize: 26,
                                        icon: (!widget.firstLaunchOfArticle)
                                            ? Image.asset(
                                                "assets/images/ICON_VOLUME_VIOLET.png")
                                            : (widget.article ==
                                                    widget.secondArticle)
                                                ? Image.asset(
                                                    "assets/images/ICON_VOLUME.png")
                                                : Image.asset(
                                                    "assets/images/ICON_VOLUME_VIOLET.png"),
                                        onPressed: () {
                                          newState = widget.audioState;

                                          //Les nouvelles durée initialisé à 0 si on change d'article
                                          //voir condition ternaire dans l'appel du constructeur de Audio juste en dessous
                                          Duration savedPosition =
                                              new Duration();
                                          Duration savedMaxDuration =
                                              new Duration();

                                          if (widget.secondArticle !=
                                                  widget.article ||
                                              (widget.audioState &&
                                                  widget.secondArticle !=
                                                      widget.article)) {
                                            widget.play(widget.snapshot);
                                            newState = true;
                                          }
                                          //Le statefulbuilder ne sert plus a rien normalement
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () => Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop(),
                                                      child: Dismissible(
                                                          movementDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          key: Key("key"),
                                                          direction:
                                                              DismissDirection
                                                                  .vertical,
                                                          onDismissed: (value) {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Audio(
                                                            article:
                                                                widget.article,
                                                            trade: widget.trade,
                                                            audioPlayer: widget
                                                                .audioPlayer,
                                                            snapshot:
                                                                widget.snapshot,
                                                            audioState: widget
                                                                    .firstLaunchOfArticle
                                                                ? newState !=
                                                                        null
                                                                    ? newState
                                                                    : widget
                                                                        .audioState
                                                                : widget
                                                                    .audioState,
                                                            lance: widget.lance,
                                                            play: widget.play,
                                                            pausePlayer: widget
                                                                .pausePlayer,
                                                            stopPlayer: widget
                                                                .stopPlayer,
                                                            cameFromArticeItem:
                                                                true,
                                                            isPopupOpen: widget
                                                                .isPopUpOpen,
                                                            updateDuration: widget
                                                                .updateDuration,
                                                            savedMaxDuration: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedMaxDuration
                                                                : savedMaxDuration,
                                                            savedPosition: (widget
                                                                        .secondArticle ==
                                                                    widget
                                                                        .article)
                                                                ? widget
                                                                    .savedPosition
                                                                : savedPosition,
                                                            firstLaunchOfArticle:
                                                                widget
                                                                    .firstLaunchOfArticle,
                                                            setFirstLaunchOfArticle:
                                                                widget
                                                                    .setFirstLaunchOfArticle,
                                                            afficherArticle: widget
                                                                .afficherArticle,
                                                            marker:
                                                                widget.marker,
                                                            updateMarkerForPopUp:
                                                                widget
                                                                    .updateMarkerForPopUp,
                                                            articleCallback: widget
                                                                .articleCallback,
                                                            randomAudioCallback:
                                                                randomAudioCallback,
                                                            articlesData: widget
                                                                .articlesData,
                                                            markersData: widget
                                                                .markersData,
                                                          )),
                                                    );
                                                  })).then(
                                              (value) => setStateLance());
                                        },
                                      ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getArchitecte(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          /*SizedBox(
                            height: 10,
                          ),*/
                          Expanded(
                            child: Container(
                              child: Text(
                                getDate(),
                                style: TextStyle(
                                    fontFamily: 'myriad',
                                    color: Colors.black54,
                                    fontSize: 14),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Container(
                            child: Wrap(
                              spacing: 3,
                              children: _buildAllChip().toList(),
                              runSpacing: 2,
                            ),
                          ),
                        ],
                      )),
                ),*/
            ]),
      ),
    );
  }
}
