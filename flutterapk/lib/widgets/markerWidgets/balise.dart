import 'package:aura2/widgets/markerWidgets/Balise2.dart';
import 'package:aura2/widgets/markerWidgets/balise12.dart';
import 'package:aura2/widgets/markerWidgets/balise13.dart';
import 'package:aura2/widgets/markerWidgets/balise14.dart';
import 'package:aura2/widgets/markerWidgets/balise16.dart';
import 'package:aura2/widgets/markerWidgets/balise17.dart';
import 'package:aura2/widgets/markerWidgets/balise18.dart';
import 'package:aura2/widgets/markerWidgets/balise19.dart';
import 'package:aura2/widgets/markerWidgets/balise23.dart';
import 'package:aura2/widgets/markerWidgets/balise25.dart';
import 'package:aura2/widgets/markerWidgets/balise28.dart';
import 'package:aura2/widgets/markerWidgets/balise30.dart';
import 'package:aura2/widgets/markerWidgets/balise31.dart';
import 'package:aura2/widgets/markerWidgets/balise33.dart';
import 'package:aura2/widgets/markerWidgets/balise34.dart';
import 'package:aura2/widgets/markerWidgets/balise37.dart';
import 'package:aura2/widgets/markerWidgets/balise39.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/article.dart';
import '../../models/customMarker.dart';
import '../../providers/articleProvider.dart';
import '../../providers/markerProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:latlong/latlong.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
//import 'package:latlng/latlng.dart';
import 'dart:math' as math;

import 'balise1.dart';
import 'balise10.dart';
import 'balise11.dart';
import 'balise15.dart';
import 'balise20.dart';
import 'balise21.dart';
import 'balise22.dart';
import 'balise24.dart';
import 'balise26.dart';
import 'balise27.dart';
import 'balise29.dart';
import 'balise3.dart';
import 'balise32.dart';
import 'balise35.dart';
import 'balise36.dart';
import 'balise38.dart';
import 'balise4.dart';
import 'balise5.dart';
import 'balise6.dart';
import 'balise7.dart';
import 'balise8.dart';
import 'balise9.dart';

class Balise {
  final BuildContext context;

  /// Valeur du zoom de la map
  final double zoomMap;

  /// Liste de marker filtré
  final List<CustomMarker> markersFiltered;

  /// Permet d''ouvrir un article
  final Function openMarker;

  /// Degré de rotation de la map
  final double rotation;

  const Balise(
      {this.context,
      this.markersFiltered,
      this.zoomMap,
      this.openMarker,
      this.rotation = 0});

  /// @args - item marqueur
  /// @return Renvoie l'image du marqueur
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

  Widget _imageMarker(CustomMarker item, String type) {
    final article = Provider.of<ArticleProvider>(context, listen: false)
        .markerToArticle(item.idArticle);

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
              child: Container(
            alignment: AlignmentDirectional.bottomCenter,
            child: Text(
              article.title,
              style: TextStyle(
                fontFamily: 'myriad',
                fontSize: 23,
                //color: Colors.white,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          )),
          if (type == 'marqueurVioletSélectionné')
            GestureDetector(
              onTap: () {
                openMarker(item);
              },
              child: Container(
                  child: Image(
                height: 40,
                width: 40,
                image: AssetImage('assets/images/marker/$type.png'),
              )),
            ),
          if (type == 'marqueurViolet')
            GestureDetector(
              onTap: () {
                openMarker(item);
              },
              child: Container(
                  child: Image(
                height: 40,
                width: 40,
                image: AssetImage('assets/images/marker/$type.png'),
              )),
            ),
          if (type == 'marqueurVioletFoncé')
            GestureDetector(
              onTap: () {
                openMarker(item);
              },
              child: Container(
                  child: Image(
                height: 40,
                width: 40,
                image: AssetImage('assets/images/marker/$type.png'),
              )),
            ),
          if (type == 'marqueurVioletFoncéSélectionné')
            GestureDetector(
              onTap: () {
                openMarker(item);
              },
              child: Container(
                  child: Image(
                height: 40,
                width: 40,
                image: AssetImage('assets/images/marker/$type.png'),
              )),
            ),
          if (type == 'marqueurVioletFoncéCoeur')
            GestureDetector(
              onTap: () {
                openMarker(item);
              },
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/images/marker/marqueurVioletFoncé.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          if (type == 'marqueurVioletFavori')
            GestureDetector(
              onTap: () {
                openMarker(item);
              },
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/images/marker/marqueurViolet.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          if (type == 'marqueurVioletSélectionnéCoeur')
            GestureDetector(
              onTap: () {
                openMarker(item);
              },
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/images/marker/marqueurVioletSélectionné.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          if (type == 'marqueurVioletFoncéSélectionnéCoeur')
            GestureDetector(
              onTap: () {
                openMarker(item);
              },
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/images/marker/marqueurVioletFoncéSélectionné.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _mainImage(CustomMarker item) {
    final article = Provider.of<ArticleProvider>(context, listen: false)
        .markerToArticle(item.idArticle);

    if (article.text.isNotEmpty && item.isFavorite == false && item.isVisible) {
      if (zoomMap > 15.5)
        return _imageMarker(item, 'marqueurVioletSélectionné');
      else if (article.title == "Manufacture sur Seine - Quartier Terre") {
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/Manufacture sur Seine Quartier Terre/reinventer-seine-manufacture-seine-amateur.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));
      }
      if (article.title == "Centre ville de Montreuil Sous Bois") {
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/Centre Ville de Montreuil sous Bois Alvaro Siza/Croquis Siza Centre Ville Montreuil.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));
      }
      if (article.title == "La Grande Arche") {
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/La Grande Arche/IMG_3992.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));
      }
      if (article.title == "Fondation Louis Vuitton") {
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/Fondation Louis Vuitton/IMG_1330.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));
      }
      if (article.title == "100 logements sociaux") {
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/IMG_4027.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));
      }
      if (article.title == "Stade Jean Bouin") {
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/IMG_2083.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));
      }
      if (article.title == "La Tour Triangle") {
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/La Tour Triangle/La Tour Triangle.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));
      }

      if (article.title == "Hôpital Cognacq-Jay")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/Hôpital Cognacq-Jay - Toyo Ito/IMG_9574.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Musée du quai Branly")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/Musée Quai Branly/IMG_3690.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Espace de méditation UNESCO")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/Espace de Méditation UNESCO - Tadao Ando/IMG_3819.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Showroom Citroën")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/Showroom Citroën/IMG_3651.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "57 logements Rue Des Suisses")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/57 logements - Herzog et Demeuron/IMG_2681.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Fondation Cartier pour l'art contemporain")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/Fondation Cartier/IMG_2195.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Galerie marchande Gaîté Montparnasse")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/Galerie Marchande Gaîté Montparnasse/03_Gaîté_Montparnasse_MVRDV_©Ossip van Duivenbode.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Le département des Arts de l'Islam du Louvre")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/Département des Arts de l_Islam du Louvre/PARIS_Departement-des-Arts-de-l-Islam-du-musee-du-Louvre_02b.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "La Pyramide du Louvre")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/La Pyramide du Louvre/IMG_3222.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "La Nouvelle Samaritaine")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/La Nouvelle Saint Maritaine - SANAA/IMG_3967.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "La Fondation Pinault")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/57 logements - Herzog et Demeuron/IMG_2681.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "La Canopée")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/La Canopée/IMG_3297.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Lafayette Anticipation")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/IMG_3353.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Pavillon Mobile Art Chanel")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/Pavillon Mobile Art Chanel/chanel_mobile_art_pavilion-zaha_hadid_2_photo AA13.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "La Fondation Jérôme Seydoux-Pathé")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/57 logements - Herzog et Demeuron/IMG_2681.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Pushed Slab")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/Pushed Slab/IMG_5889.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "M6B2 Tour de la Biodiversité")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/IMG_7619.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title ==
          "La Bibliothèque Nationale de France (François Mitterand)")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/Bibliothèque François Mitterand/IMG_6855.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Cité de la mode et du design")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/Cité de la mode/IMG_7176.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "La Cinémathèque Française")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/La Cinémathèque Française/IMG_8448.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Eden bio")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/Eden Bio/IMG_4174.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "La Philharmonie")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/La Philharmonie/IMG_4684.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Le Parc de la Villette")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/Cité de la mode/Le Parc Lavillette/IMG_4727.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "220 logements Rue de Meaux")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/220 Logements rue de Meaux/IMG_2681.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Siège du Parti Communiste Français")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/Siège Parti Communiste/IMG_4383.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.architecte ==
              "ANNE LACATON et JEAN PHILLIPE VASSAL (France)" &&
          article.date == "2009")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/La Tour Bois Le Prêtre - Lacaton Vassal/IMG_0689.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.architecte == "Aires Mateus (Portugal) et AAVP (France)" &&
          article.date == "2018")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/Emergence/IMG_0324.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Tower Flower")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/Tower Flower/IMG_0269.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Beaubourg")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/Beaubourg/IMG_3334.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Institut du Monde Arabe")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image:
                        AssetImage("assets/Institut Monde Arabe/IMG_8831.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Le Tribunal de Paris")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/Cité de la mode/Le Tribunal de Paris/IMG_0321.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));

      if (article.title == "Villa Dall'Ava")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/Villa d_all_Ava - Oma/IMG_3076.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ));
    } else if (article.text.isEmpty &&
        item.isFavorite == false &&
        item.isVisible) {
      if (zoomMap > 15.5)
        return _imageMarker(item, 'marqueurVioletFoncéSélectionné');
      else
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
                scale: 1.35,
                child: Image(
                  height: 40,
                  width: 40,
                  image: AssetImage(
                      'assets/images/marker/marqueurVioletFoncéSélectionné.png'),
                )));
    } else if (article.text.isEmpty && item.isFavorite && item.isVisible) {
      if (zoomMap > 15.5)
        return _imageMarker(item, 'marqueurVioletFoncéSélectionnéCoeur');
      else
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/images/marker/marqueurVioletFoncéSélectionné.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));
    } else if (article.text.isNotEmpty && item.isFavorite && item.isVisible) {
      if (zoomMap > 15.5)
        return _imageMarker(item, 'marqueurVioletSélectionnéCoeur');
      else if (article.title == "Manufacture sur Seine - Quartier Terre") {
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Manufacture sur Seine Quartier Terre/reinventer-seine-manufacture-seine-amateur.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));
      }
      if (article.title == "Centre ville de Montreuil Sous Bois") {
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Centre Ville de Montreuil sous Bois Alvaro Siza/Croquis Siza Centre Ville Montreuil.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));
      }
      if (article.title == "La Grande Arche") {
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/La Grande Arche/IMG_3992.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));
      }
      if (article.title == "Fondation Louis Vuitton") {
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Fondation Louis Vuitton/IMG_1330.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));
      }
      if (article.title == "100 logements sociaux") {
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage("assets/IMG_4027.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));
      }
      if (article.title == "Stade Jean Bouin") {
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage("assets/IMG_2083.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));
      }
      if (article.title == "La Tour Triangle") {
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/La Tour Triangle/La Tour Triangle.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));
      }

      if (article.title == "Hôpital Cognacq-Jay")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Hôpital Cognacq-Jay - Toyo Ito/IMG_9574.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Musée du quai Branly")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Musée Quai Branly/IMG_3690.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Espace de méditation UNESCO")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Espace de Méditation UNESCO - Tadao Ando/IMG_3819.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Showroom Citroën")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Showroom Citroën/IMG_3651.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "57 logements Rue Des Suisses")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/57 logements - Herzog et Demeuron/IMG_2681.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Fondation Cartier pour l'art contemporain")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Fondation Cartier/IMG_2195.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Galerie marchande Gaîté Montparnasse")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Galerie Marchande Gaîté Montparnasse/03_Gaîté_Montparnasse_MVRDV_©Ossip van Duivenbode.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Le département des Arts de l'Islam du Louvre")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Département des Arts de l_Islam du Louvre/PARIS_Departement-des-Arts-de-l-Islam-du-musee-du-Louvre_02b.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "La Pyramide du Louvre")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/La Pyramide du Louvre/IMG_3222.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "La Nouvelle Samaritaine")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/La Nouvelle Saint Maritaine - SANAA/IMG_3967.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "La Fondation Pinault")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/57 logements - Herzog et Demeuron/IMG_2681.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "La Canopée")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage("assets/La Canopée/IMG_3297.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Lafayette Anticipation")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage("assets/IMG_3353.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Pavillon Mobile Art Chanel")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Pavillon Mobile Art Chanel/chanel_mobile_art_pavilion-zaha_hadid_2_photo AA13.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "La Fondation Jérôme Seydoux-Pathé")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/57 logements - Herzog et Demeuron/IMG_2681.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Pushed Slab")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage("assets/Pushed Slab/IMG_5889.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "M6B2 Tour de la Biodiversité")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage("assets/IMG_7619.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title ==
          "La Bibliothèque Nationale de France (François Mitterand)")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Bibliothèque François Mitterand/IMG_6855.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Cité de la mode et du design")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Cité de la mode/IMG_7176.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "La Cinémathèque Française")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/La Cinémathèque Française/IMG_8448.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Eden bio")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage("assets/Eden Bio/IMG_4174.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "La Philharmonie")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/La Philharmonie/IMG_4684.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Le Parc de la Villette")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Cité de la mode/Le Parc Lavillette/IMG_4727.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "220 logements Rue de Meaux")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Cité de la mode/Le Parc Lavillette/IMG_4727.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Siège du Parti Communiste Français")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Siège Parti Communiste/IMG_4383.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.architecte ==
              "ANNE LACATON et JEAN PHILLIPE VASSAL (France)" &&
          article.date == "2009")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/La Tour Bois Le Prêtre - Lacaton Vassal/IMG_0689.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.architecte == "Aires Mateus (Portugal) et AAVP (France)" &&
          article.date == "2018")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage("assets/Emergence/IMG_0324.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Tower Flower")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image:
                              AssetImage("assets/Tower Flower/IMG_0269.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Beaubourg")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage("assets/Beaubourg/IMG_3334.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Institut du Monde Arabe")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Institut Monde Arabe/IMG_8831.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Le Tribunal de Paris")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Cité de la mode/Le Tribunal de Paris/IMG_0321.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));

      if (article.title == "Villa Dall'Ava")
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Transform.scale(
              scale: 1.4,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/Villa d_all_Ava - Oma/IMG_3076.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -1,
                            right: 20.0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));
      return GestureDetector(
          onTap: () {
            openMarker(item);
          },
          child: Transform.scale(
              scale: 1.35,
              child: Image(
                height: 40,
                width: 40,
                image: AssetImage(
                    'assets/images/marker/marqueurVioletSélectionnéCoeur.png'),
              )));
    } else if (article.text.isEmpty && item.isFavorite == false) {
      if (zoomMap > 15.5)
        return _imageMarker(item, 'marqueurVioletFoncé');
      else
        return GestureDetector(
          onTap: () {
            openMarker(item);
          },
          child: Image(
            height: 40,
            width: 40,
            image: AssetImage('assets/images/marker/marqueurVioletFoncé.png'),
          ),
        );
    } else if (article.text.isEmpty && item.isFavorite) {
      if (zoomMap > 15.5)
        return _imageMarker(item, 'marqueurVioletFoncéCoeur');
      else
        return GestureDetector(
          onTap: () {
            openMarker(item);
          },
          child: Stack(
            children: [
              Positioned(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/marker/marqueurVioletFoncé.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -1,
                        right: 20.0,
                        child: Icon(
                          Icons.circle,
                          color: Colors.red,
                          size: 18.0,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
    } else if (article.text.isNotEmpty && item.isFavorite == false) {
      if (zoomMap > 15.5)
        return _imageMarker(item, 'marqueurViolet');
      else {
        /*return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Image(
              height: 40,
              width: 40,
              image: AssetImage('assets/images/marker/marqueurViolet.png'),
            ));*/
        /*return Balise1(
          article: article,
          openMarker: openMarker,
          item: item,
        );*/
        /*if (article.title == "Manufacture sur Seine - Quartier Terre") {
          return Balise1(
            article: article,
            openMarker: openMarker,
            item: item,
          );
        }
        if (article.title == "Centre ville de Montreuil Sous Bois") {
          return Balise2(
            article: article,
            openMarker: openMarker,
            item: item,
          );
        }
        if (article.title == "La Grande Arche") {
          return Balise3(
            article: article,
            openMarker: openMarker,
            item: item,
          );
        }
        if (article.title == "Fondation Louis Vuitton") {
          return Balise4(
            item: item,
            openMarker: openMarker,
            article: article,
          );
        }
        if (article.title == "100 logements sociaux") {
          return Balise5(
            item: item,
            openMarker: openMarker,
            article: article,
          );
        }
        if (article.title == "Stade Jean Bouin") {
          return Balise6(
            article: article,
            item: item,
            openMarker: openMarker,
          );
        }
        if (article.title == "La Tour Triangle") {
          return Balise7(article: article, item: item, openMarker: openMarker);
        }

        if (article.title == "Hôpital Cognacq-Jay") {
          return Balise8(
            item: item,
            openMarker: openMarker,
            article: article,
          );
        }

        if (article.title == "Musée du quai Branly") {
          return Balise9(item: item, openMarker: openMarker, article: article);
        }

        if (article.title == "Espace de méditation UNESCO") {
          return Balise10(
            item: item,
            openMarker: openMarker,
            article: article,
          );
        }

        if (article.title == "Showroom Citroën") {
          return Balise11(
            item: item,
            article: article,
            openMarker: openMarker,
          );
        }
        if (article.title == "57 logements Rue Des Suisses") {
          return Balise12(
            item: item,
            article: article,
            openMarker: openMarker,
          );
        }
        if (article.title == "Fondation Cartier pour l'art contemporain") {
          return Balise13(
            item: item,
            article: article,
            openMarker: openMarker,
          );
        }
        if (article.title == "Galerie marchande Gaîté Montparnasse") {
          return Balise14(
            item: item,
            article: article,
            openMarker: openMarker,
          );
        }
        if (article.title == "Le département des Arts de l'Islam du Louvre") {
          return Balise15(
            item: item,
            article: article,
            openMarker: openMarker,
          );
        }

        if (article.title == "La Pyramide du Louvre") {
          return Balise16(
            item: item,
            article: article,
            openMarker: openMarker,
          );
        }

        if (article.title == "La Nouvelle Samaritaine") {
          return Balise17(
            item: item,
            article: article,
            openMarker: openMarker,
          );
        }

        if (article.title == "La Fondation Pinault") {
          return Balise18(
            item: item,
            article: article,
            openMarker: openMarker,
          );
        }

        if (article.title == "La Canopée") {
          return Balise19(
            item: item,
            article: article,
            openMarker: openMarker,
          );
        }

        if (article.title == "Lafayette Anticipation") {
          return Balise20(
            item: item,
            article: article,
            openMarker: openMarker,
          );
        }

        if (article.title == "Pavillon Mobile Art Chanel") {
          return Balise21(
            item: item,
            article: article,
            openMarker: openMarker,
          );
        }

        if (article.title == "La Fondation Jérôme Seydoux-Pathé")
          return Balise22(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.title == "Pushed Slab")
          return Balise23(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.title == "M6B2 Tour de la Biodiversité")
          return Balise24(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.title ==
            "La Bibliothèque Nationale de France (François Mitterand)")
          return Balise25(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.title == "Cité de la mode et du design")
          return Balise26(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.title == "La Cinémathèque Française")
          return Balise27(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.title == "Eden bio")
          return Balise28(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.title == "La Philharmonie")
          return Balise29(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.title == "Le Parc de la Villette")
          return Balise30(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.title == "220 logements Rue de Meaux")
          return Balise31(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.title == "Siège du Parti Communiste Français")
          return Balise32(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.architecte ==
                "ANNE LACATON et JEAN PHILLIPE VASSAL (France)" &&
            article.date == "2009")
          return Balise33(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.architecte == "Aires Mateus (Portugal) et AAVP (France)" &&
            article.date == "2018")
          return Balise34(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.title == "Tower Flower")
          return Balise35(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.title == "Beaubourg")
          return Balise36(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.title == "Institut du Monde Arabe")
          return Balise37(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.title == "Le Tribunal de Paris")
          return Balise38(
            item: item,
            article: article,
            openMarker: openMarker,
          );

        if (article.title == "Villa Dall'Ava")
          return Balise39(
            item: item,
            article: article,
            openMarker: openMarker,
          );*/
        return GestureDetector(
            onTap: () {
              openMarker(item);
            },
            child: Image(
              height: 40,
              width: 40,
              image: AssetImage('assets/images/marker/marqueurViolet.png'),
            ));
      }
    } else {
      if (zoomMap > 15.5)
        return _imageMarker(item, 'marqueurVioletFavori');
      else {
        return GestureDetector(
          onTap: () {
            openMarker(item);
          },
          child: Stack(
            children: [
              Positioned(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage('assets/images/marker/marqueurViolet.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -1,
                        right: 20.0,
                        child: Icon(
                          Icons.circle,
                          color: Colors.red,
                          size: 18.0,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }
    }
  }

  /// @args - item marqueur
  /// @return Renvoie le design d'un marker
  Marker _buildMarker(CustomMarker item) {
    return Marker(
        anchorPos: AnchorPos.align(AnchorAlign.top),
        width: zoomMap > 15.5 ? 180 : 40,
        height: zoomMap > 15.5 ? 120 : 40,
        rotate: true,
        point: LatLng(item.latitude, item.longitude),
        builder: (ctx) => Transform.rotate(
              angle: -rotation * math.pi / 180,
              alignment: Alignment.bottomCenter,
              child: _mainImage(item),
            ));
  }

  /// @return Renvoie le design de tous les markers
  List<Marker> buildAllMarker() {
    List<Marker> _markers = [];

    final markersData = Provider.of<MarkerProvider>(context);

    if (markersFiltered.isEmpty)
      for (var i = 0; i < markersData.markers.length; i++) {
        _markers.add(_buildMarker(markersData.markers[i]));
      }
    else
      for (var i = 0; i < markersFiltered.length; i++) {
        _markers.add(_buildMarker(markersFiltered[i]));
      }

    return _markers;
  }
}
