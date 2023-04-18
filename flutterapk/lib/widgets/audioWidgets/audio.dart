import 'dart:collection';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../models/article.dart';
import 'package:after_layout/after_layout.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:math' as math;

import '../../models/customMarker.dart';
import '../../providers/articleProvider.dart';
import '../../providers/markerProvider.dart';

//Bonjour
// J'ai fait tout ce qui touche a l'audio
// Désolé d'avance, je pense que c'est "mal codé", j'espere etre clair dans
// chaque commentaire
// Etant encore debutant (en L3 actuellement), j'apprends encore enormement
// Cela peut sembler "peu" pour 3 mois de travail sur ce projet, je le pense aussi
// Mais cette partie qu est l audio avec tous les autres widget,
//une partie d'articleItem, audioBottomBar, etc.. m'a donné beaucoup de mal
class Audio extends StatefulWidget {
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

  //La fonction qui permet d'areter l'audio
  final Function stopPlayer;

  //Fonction callBack qui permet de renvoyer le booleen vers CarteScreen permettant de savoir si le popUp est ouvert
  final Function(bool) isPopupOpen;

  //Booleen permettant de savoir d'où on vient
  final bool cameFromArticeItem;

  //Permet de sauvegarder la durée maximal de l'audio
  final Duration savedMaxDuration;

  //Permet de sauvegarder la position de l'audio
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

  //Fonction callBack qui permet de "faire remonter" les données d'un article vers "CarteScreen"
  final Function(Article, AudioPlayer, bool, String) articleCallback;

  // Fonction pour retourner les données de l'audio vers audioBottomBar et articleItem
  final Function(Article, String, bool, bool) randomAudioCallback;

  //Les markers de l'application
  final MarkerProvider markersData;

  //Les articles de l'application
  final ArticleProvider articlesData;

  Audio(
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
      this.cameFromArticeItem,
      this.savedMaxDuration,
      this.savedPosition,
      this.updateDuration,
      this.firstLaunchOfArticle,
      this.setFirstLaunchOfArticle,
      this.afficherArticle,
      this.marker,
      this.updateMarkerForPopUp,
      this.articleCallback,
      this.randomAudioCallback,
      this.articlesData,
      this.markersData});

  @override
  _AudioState createState() => _AudioState();
}

class _AudioState extends State<Audio> with AfterLayoutMixin<Audio> {
  //La durée max de l'audio
  Duration maxDuration = new Duration();

  //La position de l'audio
  Duration position = new Duration();

  //Double utilisé pour le curseur
  double currentPosition = 0.0;

  //La snapshot courante de l'audio
  String _snapshot;

  //L'article courant
  Article article;

  // Permet de savoir si un audio est joué aelatoirement apres qu'un audio soit finis
  // Il est en commentaire car la fonction jouant l'audio automatiquement un audio quand le précedent se termine n'est pas fonctionnel
  // bool playRandomAudio = false;

  //Le marker correspondant à l'article, permet de rediriger sur l'article en appuyant sur le bouton en bas a droiteud popup
  CustomMarker marker;

  //L'article precedent
  Article previousArticle;

  //La snapshot de l'audio precedent
  String previousSnapshot;

  //L'etat dans lequel est l'audio, vrai s'il est en cours, faux sinon
  static bool state = false;

  //Liste des precedents articles avec leur snapshot correspondante
  static List<Map<Article, String>> previousArticles = [];

  @override
  initState() {
    super.initState();
    //widget.audioPlayer.setUrl(widget.snapshot, isLocal: false);
    widget.audioPlayer.setSourceUrl(widget.snapshot);

    //Je re-affecte les valeurs provenant des widget parent pour pouvoir modifier le state dans le dialog
    //ca ne fonctionne pas si on utilise directement les valeurs provenant des widget parents.
    article = widget.article;
    _snapshot = widget.snapshot;
    marker = widget.marker;

    // Je sais que firebase retourne un warning par rapport à ca, mais je n'ai pas
    // trouve d'autre solution pour sauvergarder la position et la duree de l'audio
    widget.audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        maxDuration = event;
      });
    });

    widget.audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });

    //Permet de jouer un audio automatiquement lorsqu'un audio se termine
    //A ete implemente a la toute fin du projet, il n'est donc pas totalement fonctionnel
    // widget.audioPlayer.onPlayerCompletion.listen((_) async {
    //   List<Article> articleAvecAudio =
    //       widget.articlesData.getAllArticlesWithText();
    //   article = getRandomArticleWithAudio(articleAvecAudio);
    //   _snapshot = await getAudio(article);
    //   await widget.play(_snapshot);
    //   setState(() {
    //     state = true;
    //   });
    // });
  }

  //Permet d'executer des méthodes juste après que le Widget soit build
  @override
  void afterFirstLayout(ctx) async {
    //Si on vient d'article item et si c'est le premier article qu'on ouvre, jouer l'audio
    if (widget.cameFromArticeItem && !widget.firstLaunchOfArticle) {
      setState(() {
        state = true;
      });
      widget.setFirstLaunchOfArticle();
      await widget.play(widget.snapshot);
    } else
      setState(() {
        //state = widget.audioState;
      });
    //Permet de retourner l'id du marker pour ouvrir un article depuis audioBottomBar
    widget.updateMarkerForPopUp(marker);

    //Retourne l'inverse de lance pour fermer l'audioBottomBar
    if (widget.lance) widget.isPopupOpen(!widget.lance);
  }

  //Retourne l'ensemble des articles contenant un audio
  Article getRandomArticleWithAudio(List<Article> articleWithAudio) {
    int random = math.Random().nextInt(articleWithAudio.length);
    Article art = articleWithAudio[random];
    return art;
  }

  //Retourne l'audio correpondant à l'article en parametres
  Future<String> getAudio(Article article, [bool test = false]) async {
    String snap = "";
    if (test) {
      if (!widget.trade)
        snap = await firebase_storage.FirebaseStorage.instance
            .ref()
            .child(article.audio)
            .getDownloadURL();
      else if (article.audioEN.isNotEmpty)
        snap = await firebase_storage.FirebaseStorage.instance
            .ref()
            .child(article.audioEN)
            .getDownloadURL();
    }
    return snap;
  }

  //Permet de jouer un audio automatiquement lorsqu'un audio se termine
  //A ete implemente a la toute fin du projet, il n'est donc pas totalement fonctionnel
  // void playRandomAudioAfter(
  //     List<Article> articleAvecAudio, MarkerProvider markersData) async {
  //   widget.audioPlayer.onPlayerCompletion.listen((_) async {
  //     article = getRandomArticleWithAudio(articleAvecAudio);

  //     updateMarker(markersData);

  //     _snapshot = await getAudio(article);

  //     widget.audioPlayer.setUrl(_snapshot, isLocal: false);
  //     await widget.audioPlayer.play(_snapshot);
  //     widget.randomAudioCallback(article, _snapshot, playRandomAudio);
  //   });
  // }

  //Permet de mettre à jour le marker courant
  //Utilise lorsque qu'un nouvel audio aleatoire est joue
  void updateMarker(MarkerProvider markersData) {
    marker = markersData.markers.firstWhere(
      (data) => data.idArticle == article.id,
    );
    widget.updateMarkerForPopUp(marker);
  }

  @override
  Widget build(BuildContext context) {
    //Permet d'appeller une seul fois la fonction permettant de jouer un audio aleatoirement
    // if (!playRandomAudio) {
    //   List<Article> articleAvecAudio = articleData.getAllArticlesWithText();
    //   playRandomAudioAfter(articleAvecAudio, markersData);
    //   setState(() {
    //     playRandomAudio = true;
    //   });
    // }

    return Container(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Dialog(
        insetPadding: EdgeInsets.zero,
        child: Container(
            child: Column(children: [
          SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GestureDetector(
              child: Icon(Icons.skip_previous, color: Colors.black, size: 40),
              // DoubleTap (pas le moove sur rocket league) : permet de jouer l'audio precedent stocke dans previousArticles
              onDoubleTap: () async {
                if (previousArticles.length == 0) {
                  await widget.audioPlayer.stop();
                  await widget.play(_snapshot);
                  widget.randomAudioCallback(article, _snapshot, state, true);
                  return;
                }
                Map<Article, String> artAndSnap = previousArticles.removeLast();
                article = artAndSnap.keys.first;
                _snapshot = artAndSnap.values.first;

                updateMarker(widget.markersData);

                await widget.audioPlayer.play(UrlSource(_snapshot));
                setState(() {
                  state = true;
                });
                widget.randomAudioCallback(article, _snapshot, state, true);
              },
              // onTap : permet de rejouer l'audio courant
              onTap: () async {
                await widget.audioPlayer.stop();
                await widget.audioPlayer.play(UrlSource(_snapshot));
                setState(() {
                  state = true;
                });
                widget.randomAudioCallback(article, _snapshot, state, true);
              },
            ),
            Padding(
              padding: EdgeInsets.all(4),
            ),
            //Le bouton play/pause
            IconButton(
              onPressed: () async {
                if (!state)
                  await widget.play(_snapshot);
                else {
                  //Lorsqu'on met l'audio en pause, la position et la durée max n'est pas sauvegardé,
                  //Je fais donc un callback de ces données pour les garder en mémoire
                  widget.updateDuration(maxDuration, position);
                  widget.pausePlayer();
                }
                setState(() {
                  state = !state;
                });
              },
              icon: Icon((!state) ? Icons.play_arrow : Icons.pause,
                  color: Colors.black),
              iconSize: 40,
            ),
            //Le bouton suivant, permettant de passer à l'audio suivant aléatoire
            IconButton(
              onPressed: () async {
                previousArticle = article;
                previousSnapshot = _snapshot;
                previousArticles.add({article: _snapshot});

                widget.updateDuration(new Duration(), new Duration());

                List<Article> articleAvecAudio =
                    widget.articlesData.getAllArticlesWithText();
                article = getRandomArticleWithAudio(articleAvecAudio);
                _snapshot = await getAudio(article, true);

                await widget.play(_snapshot);
                setState(() {
                  state = true;
                });

                widget.randomAudioCallback(article, _snapshot, state, true);

                updateMarker(widget.markersData);
              },
              icon: Icon(Icons.skip_next, color: Colors.black),
              iconSize: 40,
            ),
          ]),
          SizedBox(
            height: 10,
          ),

          //La position de l'audio à gauche et le temps total à droite
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 30, 0),
              ),
              Text(
                  (position.inSeconds.toDouble() == 0.0)
                      ? widget.savedPosition
                              .toString()
                              .split(".")[0]
                              .split(":")[1] +
                          ":" +
                          widget.savedPosition
                              .toString()
                              .split(".")[0]
                              .split(":")[2]
                      : position.toString().split(".")[0].split(":")[1] +
                          ":" +
                          position.toString().split(".")[0].split(":")[2],
                  style: TextStyle(color: Colors.black, fontSize: 12))
            ]),
            Row(children: [
              Text(
                  (maxDuration.inSeconds.toDouble() == 0.0)
                      ? widget.savedMaxDuration
                              .toString()
                              .split(".")[0]
                              .split(":")[1] +
                          ":" +
                          widget.savedMaxDuration
                              .toString()
                              .split(".")[0]
                              .split(":")[2]
                      : maxDuration.toString().split(".")[0].split(":")[1] +
                          ":" +
                          maxDuration.toString().split(".")[0].split(":")[2],
                  style: TextStyle(color: Colors.black, fontSize: 12)),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 30, 0),
              ),
            ]),
          ]),
          //Slider qui permet d'avancer dans la musique
          Slider(
              thumbColor: Colors.black,
              activeColor: Colors.black,
              inactiveColor: Colors.grey,
              value: (position.inSeconds.toDouble() == 0.0)
                  ? widget.savedPosition.inSeconds.toDouble()
                  : position.inSeconds.toDouble(),
              min: 0.0,
              max: (maxDuration.inSeconds.toDouble() != 0.0)
                  ? maxDuration.inSeconds.toDouble()
                  : widget.savedMaxDuration.inSeconds.toDouble(),
              onChanged: (double value) => setState(() {
                    currentPosition = value;
                    widget.audioPlayer
                        .seek(Duration(seconds: currentPosition.toInt()));
                  })),

          //Le titre et l'arhitecte de l'article
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    (!widget.trade && article != null)
                        ? article.title + "\n" + article.architecte
                        : article.titleEN + "\n" + article.architecte,
                    style: TextStyle(color: Color.fromRGBO(209, 62, 150, 1)),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              IconButton(
                  onPressed: () =>
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        widget.afficherArticle(marker);
                        widget.isPopupOpen(!widget.lance);
                        widget.randomAudioCallback(
                            article, _snapshot, state, true);
                        Navigator.of(context, rootNavigator: true).pop();
                      }),
                  icon: Image.asset(
                    "assets/images/icones/AURA_AUDIO_BOUTON RACCOURCI.png",
                  )),
            ],
          ),
          SizedBox(
            height: 20,
          )
        ])),
        backgroundColor: Colors.white,
      )
    ]));
  }
}
