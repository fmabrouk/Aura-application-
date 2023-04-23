import 'package:aura2/models/article.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/User.dart';
import '../../models/customMarker.dart';
import '../../providers/articleProvider.dart';
import '../../providers/markerProvider.dart';
import '../../screens/carteScreen.dart';
import '../../screens/rechercheScreen.dart';

class barreRecherche extends SearchDelegate<Article> {
  final ArticleProvider articleProvider;
  final User login;
  double latling1;
  double latling2;
  final bool auth;

  final UserCustom user;
  bool trade;
  //final Function centerMarker;
  //CustomMarker item;
  barreRecherche(
      {this.articleProvider,
      this.login,
      this.latling1,
      this.latling2,
      this.trade,
      this.auth,
      this.user});

  @override
  List<Widget> buildActions(BuildContext context) {
    // actions for app bar
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: Icon(Icons.clear))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ));
  }

  @override
  Widget buildResults(BuildContext context) {
    final articlesFiltres = articleProvider.articles
        .where((article) =>
            article.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: articlesFiltres.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(articlesFiltres[index].title),
          onTap: () {
            close(context, articlesFiltres[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // show when someone searches for something
    final articleList = Provider.of<ArticleProvider>(context).getAllArticles();
    //trie les articles dans l'ordre alphabetique
    articleList.sort((a, b) => a.title.compareTo(b.title));

    final articleListImage =
        Provider.of<ArticleProvider>(context).getAllArticlesImage().toList();
    final articleListWithoutImage = Provider.of<ArticleProvider>(context)
        .getAllArticlesWithoutImage()
        .toList();

    articleListImage.sort(((a, b) => a.title.compareTo(b.title)));
    articleListWithoutImage.sort(((a, b) => a.title.compareTo(b.title)));

    final articleLists = articleListImage + articleListWithoutImage;
    final articleMarker = Provider.of<MarkerProvider>(context).getAllMarkers();

    final suggestionsList = query.isEmpty
        ? articleLists
        : articleLists.where((article) {
            final titreLower = article.title.toLowerCase();
            final queryLower = query.toLowerCase();
            final architecteLower = article.architecte.toLowerCase();
            return titreLower.contains(queryLower) ||
                architecteLower.contains(queryLower);
          }).toList();

    return ListView.builder(
      itemCount: suggestionsList.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => {
          for (int i = 0; i < articleMarker.length; i++)
            {
              if (articleMarker[i].idArticle == suggestionsList[index].id)
                {
                  latling1 = articleMarker[i].latitude,
                  latling2 = articleMarker[i].longitude,
                }
            },
          if (latling1 != null && latling2 != null)
            {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RechercheScreen(
                          auth: auth,
                          login: login,
                          trade: trade,
                          article1: suggestionsList[index].id,
                          latling1: latling1,
                          latling2: latling2,
                          user: user,
                        )),
              ),
            }
        },
        child: ListTile(
            title: !trade
                ? Text(
                    suggestionsList[index].title +
                        ' , ' +
                        suggestionsList[index].architecte,
                    maxLines: 1,
                  )
                : suggestionsList[index].titleEN.isEmpty
                    ? Text(
                        suggestionsList[index].title +
                            ' , ' +
                            suggestionsList[index].architecte,
                        maxLines: 1,
                      )
                    : Text(
                        suggestionsList[index].titleEN +
                            ' , ' +
                            suggestionsList[index].architecte,
                        maxLines: 1,
                      )),
      ),
    );
  }
}
