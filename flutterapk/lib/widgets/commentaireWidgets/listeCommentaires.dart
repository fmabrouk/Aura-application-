import 'package:aura2/screens/carteScreen.dart';
import 'package:aura2/widgets/markerWidgets/articleItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/CommentaireModel.dart';
import '../../models/User.dart';
import '../../providers/commentProvider.dart';
import 'dart:math' as math;
import 'commentsItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:awesome_notifications/awesome_notifications.dart';

class ListCommentaire extends StatefulWidget {
  final UserCustom user;

  /// Permet de passer à l'article
  final Function switchToArticle;

  /// Identifiant de l'article
  final String article;

  /// Permet de savoir si la page doit être traduite en anglais
  bool trade;

  ListCommentaire({this.switchToArticle, this.article, this.user, this.trade});

  @override
  State<StatefulWidget> createState() {
    return new ListCommentaireState();
  }
}

/// Represente la fenêtre liste Commentaire
class ListCommentaireState extends State<ListCommentaire> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _controller = new TextEditingController();

  String _texte = ' ';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<CommentaireProvider>(context, listen: false)
          .fetchAndSetComment();
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Liste des commentaires
    final commentairesList = Provider.of<CommentaireProvider>(context)
        .commentaireFrom(widget.article);

    /// permet d'envoyer le commentaire
    void _sendCommentaire() {
      FocusScope.of(context).unfocus();

      //Provider.of<UserProvider>(context, listen: false).fetchAndSetUser();
      User user = FirebaseAuth.instance.currentUser;
      CommentaireModel c = new CommentaireModel(
          identifiant: math.Random().nextInt(100).toString(),
          auteur: widget.user,
          date: DateTime.now(),
          idArticle: widget.article,
          contenu: _texte);

      Provider.of<CommentaireProvider>(context, listen: false).add(c);

      FirebaseFirestore.instance.collection('commentaire').add({
        'date': DateTime.now(),
        'idArticle': widget.article,
        'idAuteur': user.uid,
        'contenu': _texte,
      });
      _controller.clear();
    }

    /// affichage du champ de saisie pour écrire le commentaire
    Widget _buildEnterCommentaire() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          TextField(
            controller: _controller,
            onChanged: (value) {
              setState(() {
                _texte = value;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide(
                    color: Color.fromRGBO(209, 62, 150, 1),
                    style: BorderStyle.solid),
              ),
              prefixIcon: Icon(
                Icons.forum,
              ),
              hintText: !widget.trade ? 'Votre commentaire' : 'Your comment',
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                color: Color.fromRGBO(209, 62, 150, 1),
                onPressed: _texte.trim().isEmpty
                    ? null
                    : () {
                        _sendCommentaire();
                      },
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
        ],
      );
    }

    /// la taille de la liste des commentaires
    int nombre = commentairesList.length;

    ///Affichage de la liste des commentaires (scrollable)
    return Scaffold(
      body: Builder(
        key: _formKey,
        builder: (context) => Column(
          children: [
            Container(
              alignment: Alignment.bottomLeft,
              color: Colors.white,
              child: TextButton(
                onPressed: widget.switchToArticle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    /*Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotation(math.pi),
                      child: */
                    Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black45,
                      size: 17,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    //),
                    Text(
                      'ARTICLE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color.fromRGBO(209, 62, 150, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding:
                  EdgeInsets.only(top: 10, left: 35, right: 35, bottom: 40),
              child: _buildEnterCommentaire(),
            ),
            Container(
                padding: EdgeInsets.only(left: 35, top: 10),
                color: Colors.white,
                alignment: Alignment.bottomLeft,
                child: !widget.trade
                    ? Text(
                        (nombre == 0 || nombre == 1)
                            ? '($nombre commentaire)'
                            : '($nombre commentaires)',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black45,
                          decoration: TextDecoration.none,
                        ),
                      )
                    : Text(
                        (nombre == 0 || nombre == 1)
                            ? '($nombre comment)'
                            : '($nombre comments)',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black45,
                          decoration: TextDecoration.none,
                        ),
                      )),
            Container(
              height: 10,
              color: Colors.white,
            ),
            Expanded(
              child: Scrollbar(
                isAlwaysShown: true,
                thickness: 5,
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(
                      itemCount: commentairesList.length,
                      itemBuilder: (ctx, index) => Column(
                            children: [
                              CommentaireItem(
                                commentaire: commentairesList[index],
                              ),
                            ],
                          )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
