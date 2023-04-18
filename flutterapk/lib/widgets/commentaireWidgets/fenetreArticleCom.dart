import 'package:audioplayers/audioplayers.dart';
import 'package:aura2/providers/markerProvider.dart';
import 'package:provider/provider.dart';

import '../../models/User.dart';

import '../../models/customMarker.dart';
import '../../providers/articleProvider.dart';
import '../markerWidgets/articleItem.dart';
import 'listeCommentaires.dart';
import '../../models/article.dart';
import 'package:flutter/material.dart';

class FenetreArticleCom extends StatefulWidget {
  final UserCustom user;

  final bool auth;

  /// Position de l'article sur l'écran
  final double position;

  /// Fonction premettant le slide
  final Function slide;

  /// Article à afficher
  final Article article;

  /// Function permettant le changement de l'attribut isFavorite d'un marqueur
  final Function changeFavorite;

  final Function deleteItem;

  /// Identifiant du marqueur à changer
  final String idMaker;

  /// Etat du bouton Favori
  final bool like;

  /// Fonction permettant de changer la position
  final Function setPosition;

  /// true si on passe d'un article à un autre
  /// false si on ouvre la fenetre d'article
  final bool switchArticle;

  // Permet de verifier s'il l'on passe d'un article à un autre
  final Function switchFalse;

  /// Permet de savoir si la page doit être traduite en anglais
  bool trade;

  //Bool qui permet de savoir si le popUp est lancé ou non
  final bool lance;

  //Snapshot contenant les données de l'audio
  final String snapshot;

  //Fonction callBack qui permet de "faire remonter" les données d'un article vers "CarteScreen"
  final Function(Article, AudioPlayer, bool, String) articleCallback;

  //Le player permettant de manipuler l'audio
  final AudioPlayer audioPlayer;

  //Permet de savoir si l'audio est en cours ou en paue
  final bool audioState;

  //Un second article
  final Article secondArticle;

  //Fonction callBack qui permet de renvoyer le booleen vers CarteScreen permettant de savoir si le popUp est ouvert
  final Function(bool) isPopUpOpen;

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

  //Fonction pour actualiser le marker utilisé dans audioBottomBars
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

  //image de l'article
  final String image;

  FenetreArticleCom(
      {this.position,
      this.user,
      this.slide,
      this.article,
      this.changeFavorite,
      this.deleteItem,
      this.idMaker,
      this.switchArticle,
      this.switchFalse,
      this.like,
      this.setPosition,
      this.auth,
      this.trade,
      this.articleCallback,
      this.snapshot,
      this.lance,
      this.audioPlayer,
      this.audioState,
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
      this.markersData,
      this.articlesData,
      this.image});

  @override
  _FenetreArticleComState createState() => _FenetreArticleComState();
}

class _FenetreArticleComState extends State<FenetreArticleCom> {
  bool _comm = false;

  /// Switch entre la section article et commentaire
  void _switch() {
    setState(() {
      _comm = !_comm;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Taille de la fenêtre article
    double _height = MediaQuery.of(context).size.height - widget.position;

    void _onMarkerClick(double newHeight) {
      setState(() {
        _height = newHeight;
      });
    }

    //print(widget.position);

    /// Cache l'article totalement
    void _hide() {
      if (widget.position >
          MediaQuery.of(context).size.height -
              200 -
              kBottomNavigationBarHeight) {
        widget.setPosition(MediaQuery.of(context).size.height);
        Provider.of<MarkerProvider>(context, listen: false).resetAllMarker();
      }
    }

    /// Permet le plein écran de la fenetre
    void _fullWidth() {
      if (widget.position < MediaQuery.of(context).size.height * 0.1) {
        widget.setPosition(MediaQuery.of(context).size.height * 0.1 - 0.1);
        setState(() {
          _height = MediaQuery.of(context).size.height;
        });
      } else
        _height = MediaQuery.of(context).size.height * 0.9;
    }

    // _fullWidth();
    // _hide();

    return AnimatedPositioned(
      duration: Duration(
        milliseconds: widget.position < MediaQuery.of(context).size.height * 0.9
            ? 1
            : 300,
      ),
      curve: Curves.linear,
      top: widget.position < MediaQuery.of(context).size.height * 0.1
          ? 0
          : widget.position,
      height: _height,
      child: GestureDetector(
        onVerticalDragUpdate: (DragUpdateDetails details) {
          widget.slide(details);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.linear,
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: _height,
          padding: EdgeInsets.all(0),
          child: SafeArea(
              child: Column(
            children: [
              /*Container(
                  height: 25,
                  color: Colors.white,
                  width: double.infinity,
                  child: Icon(
                    _height == MediaQuery.of(context).size.height
                        ? Icons.expand_more
                        : Icons.expand_less_rounded,
                    size: 30,
                    color: Colors.black54,
                  )),*/
              Expanded(
                child: _comm
                    ? ListCommentaire(
                        switchToArticle: _switch,
                        article: widget.article.id,
                        user: widget.user,
                        trade: widget.trade,
                      )
                    : ArticleItem(
                        article: widget.article,
                        changeFavorite: widget.changeFavorite,
                        deleteItem: widget.deleteItem,
                        idMaker: widget.idMaker,
                        like: widget.like,
                        switchArticle: widget.switchArticle,
                        switchFalse: widget.switchFalse,
                        switchToComm: _switch,
                        trade: widget.trade,
                        articleCallback: widget.articleCallback,
                        snapshot: widget.snapshot,
                        lance: widget.lance,
                        audioPlayer: widget.audioPlayer,
                        audioState: widget.audioState,
                        secondArticle: widget.secondArticle,
                        isPopUpOpen: widget.isPopUpOpen,
                        updateDuration: widget.updateDuration,
                        savedMaxDuration: widget.savedMaxDuration,
                        savedPosition: widget.savedPosition,
                        firstLaunchOfArticle: widget.firstLaunchOfArticle,
                        setFirstLaunchOfArticle: widget.setFirstLaunchOfArticle,
                        afficherArticle: widget.afficherArticle,
                        marker: widget.marker,
                        updateMarkerForPopUp: widget.updateMarkerForPopUp,
                        play: widget.play,
                        pausePlayer: widget.pausePlayer,
                        stopPlayer: widget.stopPlayer,
                        markersData: widget.markersData,
                        articlesData: widget.articlesData,
                      ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
