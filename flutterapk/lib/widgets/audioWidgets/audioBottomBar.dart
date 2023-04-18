import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../models/article.dart';
import 'package:after_layout/after_layout.dart';

import '../../models/customMarker.dart';
import '../../providers/articleProvider.dart';
import '../../providers/markerProvider.dart';
import 'audio.dart';

class AudioBottomBar extends StatefulWidget {
  /// Article correspondant à l'audio qu'on écoute
  final Article article;

  ///Boolean correspondant à si l'article est traduit ou non
  final bool trade;

  // L'audioPlayer qui permet de gerer l'audio
  final AudioPlayer audioPlayer;

  //Snapshot d'où provient l'audio
  final String snapshot;

  //PErmet de savoir si l'audio est en cours
  final bool audioState;

  //Permet de savoir si le popup est lancé
  final bool lance;

  //La fonction qui permet de lancer l'audio
  final Function play;

  //La fonction qui permet de pause l'audio
  final Function pausePlayer;

  final Function stopPlayer;

  //Fonction callBack qui permet de renvoyer le booleen vers CarteScreen permettant de savoir si le popUp est ouvert
  final Function(bool) isPopupOpen;

  //Fonction callBack qui permet de "faire remonter" les données d'un article vers "CarteScreen"
  final Function(Article, AudioPlayer, bool, String) articleCallback;

  //Permet de sauvegarder la durée maximal de l'audio
  final Duration savedMaxDuration;

  //Permet de sauvegarder la position de l'audio
  final Duration savedPosition;

  //Fonction callBack permettant de remonter les données de savedPosition et savedMaxPosition vers CarteScreen
  final Function(Duration, Duration) updateDuration;

  //Fonction qui permet d'ouvrir un article depuis le popupp audio
  final Function afficherArticle;

  //Le marker conrrespondant à l'article courant
  final CustomMarker marker;

  final Function(CustomMarker) updateMarkerForPopUp;

  //Les markers de l'application
  final MarkerProvider markersData;

  //Les articles de l'application
  final ArticleProvider articlesData;

  AudioBottomBar(
      {this.article,
      this.trade,
      this.audioPlayer,
      this.snapshot,
      this.audioState,
      this.lance,
      this.play,
      this.pausePlayer,
      this.stopPlayer,
      this.isPopupOpen,
      this.articleCallback,
      this.savedMaxDuration,
      this.savedPosition,
      this.updateDuration,
      this.afficherArticle,
      this.marker,
      this.updateMarkerForPopUp,
      this.articlesData,
      this.markersData});

  @override
  State<AudioBottomBar> createState() => _AudioBottomBarState();
}

class _AudioBottomBarState extends State<AudioBottomBar> {
  // Le nouvel article qui sera retourner dans carteScreen
  Article newArticle;

  //La nouvelle snapshot qui sera retourné dans carteScreen
  String newSnapshot;

  // Savoir si c'est un nouvel audio ou pas
  bool newAudio = false;

  // Le nouveau state qui sera retourner dans carteScreen
  bool newState;

  //Permet de renvoyer la valeur du bool lance
  void setStateLance() {
    widget.isPopupOpen(widget.lance);
    if (newAudio)
      widget.articleCallback(
          newArticle, widget.audioPlayer, newState, newSnapshot);
    newAudio = false;
  }

  // Le callback effectuer depuis audio.dart pour recuperer les données de l'audio courant
  void randomAudioCallback(
      Article newArticle, String newSnapshot, bool newState, bool newAudio) {
    this.newArticle = newArticle;
    this.newSnapshot = newSnapshot;
    this.newAudio = newAudio;
    this.newState = newState;
  }

  //Retourne la barre verte, affichant le titre et l'architecte et le bouton pause/play
  Widget bottomBar() {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 25),
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        decoration: BoxDecoration(color: Colors.green[300], boxShadow: [
          BoxShadow(
            color: Colors.grey[600],
            blurRadius: 8.0,
          )
        ]),
        child: SafeArea(
          child: Row(children: [
            (!widget.audioState)
                ? IconButton(
                    onPressed: () async {
                      await widget.play(widget.snapshot);
                    },
                    icon: Icon(Icons.play_arrow, color: Colors.black, size: 30),
                    padding: EdgeInsets.symmetric(horizontal: 20))
                : IconButton(
                    onPressed: () async {
                      widget.updateDuration(
                          new Duration(
                              milliseconds: await widget.audioPlayer
                                  .getDuration()
                                  .hashCode),
                          new Duration(
                              milliseconds: await widget.audioPlayer
                                  .getCurrentPosition()
                                  .hashCode));
                      widget.pausePlayer();
                    },
                    icon: Icon(Icons.pause, color: Colors.black, size: 30),
                    padding: EdgeInsets.symmetric(horizontal: 20)),
            Expanded(
                child: GestureDetector(
              onTap: () {
                //Le statefulbuilder ne sert plus a rien normalement
                showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) =>
                        StatefulBuilder(builder: (context, setState) {
                          return GestureDetector(
                            onTap: () =>
                                Navigator.of(context, rootNavigator: true)
                                    .pop(),
                            child: Dismissible(
                                movementDuration: Duration(seconds: 1),
                                key: Key("key"),
                                direction: DismissDirection.vertical,
                                onDismissed: (value) {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                child: Audio(
                                  article: widget.article,
                                  trade: widget.trade,
                                  audioPlayer: widget.audioPlayer,
                                  snapshot: widget.snapshot,
                                  audioState: widget.audioState,
                                  lance: widget.lance,
                                  play: widget.play,
                                  stopPlayer: widget.stopPlayer,
                                  pausePlayer: widget.pausePlayer,
                                  isPopupOpen: widget.isPopupOpen,
                                  cameFromArticeItem: false,
                                  updateDuration: widget.updateDuration,
                                  savedMaxDuration: widget.savedMaxDuration,
                                  savedPosition: widget.savedPosition,
                                  afficherArticle: widget.afficherArticle,
                                  marker: widget.marker,
                                  articleCallback: widget.articleCallback,
                                  randomAudioCallback: randomAudioCallback,
                                  updateMarkerForPopUp:
                                      widget.updateMarkerForPopUp,
                                  markersData: widget.markersData,
                                  articlesData: widget.articlesData,
                                )),
                          );
                        })).then((value) => setStateLance());
              },
              child: Text(
                (!widget.trade)
                    ? widget.article.title + "\n" + widget.article.architecte
                    : widget.article.titleEN + "\n" + widget.article.architecte,
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            )),
            IconButton(
                onPressed: () async {
                  widget.isPopupOpen(!widget.lance);
                  await widget.audioPlayer.stop();
                  widget.updateDuration(new Duration(), new Duration());
                  widget.articleCallback(widget.article, widget.audioPlayer,
                      false, widget.snapshot);
                },
                icon: Icon(Icons.close, color: Colors.black, size: 30))
          ]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: Container(child: bottomBar()));
  }
}
