import '../../models/article.dart';
import '../../models/tag.dart';
import '../../providers/articleProvider.dart';
import '../../providers/tagProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Recherche extends StatefulWidget {
  Recherche({Key key, this.showMap, this.filterMap, this.trade})
      : super(key: key);

  /// Ferme la fenetre 'liste des favoris'
  final Function showMap;

  /// Filtrer la map
  final Function filterMap;

  /// Permet de savoir si la page doit être traduite en anglais
  bool trade;

  @override
  _RechercheState createState() => _RechercheState();
}

class _RechercheState extends State<Recherche> {
  final _titleController = TextEditingController();

  //booleen permettant de savoir quelle page est sélectionner afin de changer l'image affiché
  bool notion = true;

  /// Liste
  List<Tag> _listChip = [];

  ///Liste des articles à afficher
  List<Article> _articles = [];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tagsData = Provider.of<TagProvider>(context);
    tagsData.getTagsSorted(widget.trade);
    final articlesData = Provider.of<ArticleProvider>(context, listen: false);

    ///Liste des tags
    List<Tag> tags = Provider.of<TagProvider>(context).tags;
    !widget.trade
        ? tags.sort((a, b) => a.label.compareTo(b.label))
        : tags.sort((a, b) => a.labelEN.compareTo(b.labelEN));

    /// List des étiquettes sélectionnées
    final List<Tag> _isVisible = tagsData.listVisible();

    final maxLines = 10;

    /// @rgs - item Etiquette à afficher
    /// @return Renvoi le widget d'une étiquette
    Widget _buildChip(Tag item) {
      return GestureDetector(
        onTap: () {
          setState(() {
            item.isVisible = !item.isVisible;
            if (item.isVisible)
              _isVisible.contains(item)
                  ? _isVisible.remove(item)
                  : _isVisible.add(item);
          });
        },
        onLongPress: () {
          showGeneralDialog(
            transitionDuration: Duration(milliseconds: 100),
            context: context,
            pageBuilder: (context, anim1, anim2) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Dismissible(
                  direction: DismissDirection.vertical,
                  onDismissed: (_) {
                    Navigator.of(context).pop();
                  },
                  key: Key("key"),
                  child: AlertDialog(
                    insetPadding: EdgeInsets.all(0),
                    title: Text(
                      !widget.trade ? item.label : item.labelEN,
                      style: TextStyle(
                          color: Color.fromRGBO(209, 62, 150, 1), fontSize: 20),
                    ),
                    content: Text(
                      !widget.trade ? item.definition : item.definitionEN,
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
              );
            },
          );
        },
        child: Container(
          child: Text(
            !widget.trade ? item.label : item.labelEN,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: item.isVisible
                ? Color.fromRGBO(209, 62, 150, 1)
                : Colors.brown[100],
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      );
    }

    /// Change la liste des étiquettes filtrée par la recherche
    void _onChanged() {
      String label = '';
      List<Tag> _buffer = [];
      _listChip.clear();
      for (var i = 0; i < tagsData.tags.length; i++) {
        !widget.trade
            ? label = tagsData.tags[i].label
            : label = tagsData.tags[i].labelEN;
        if (label.toLowerCase().contains(_titleController.text.toLowerCase()))
          _buffer.add(tagsData.tags[i]);
      }
      setState(() {
        _listChip = _buffer;
      });
    }

    /// @return Renvoi le design de chaque étiquette dans une liste
    List<GestureDetector> _buildAllChip() {
      List<GestureDetector> _chips = [];
      if (_listChip.isEmpty)
        for (var i = 0; i < tagsData.tags.length; i++) {
          _chips.add(_buildChip(tagsData.tags[i]));
        }
      else
        for (var i = 0; i < _listChip.length; i++) {
          _chips.add(_buildChip(_listChip[i]));
        }
      return _chips;
    }

    return Dismissible(
        movementDuration: Duration(seconds: 1),
        key: Key("key"),
        direction: DismissDirection.vertical,
        onDismissed: (value) {
          FocusScope.of(context).unfocus();
          widget.showMap();
          if (_isVisible.isNotEmpty) {
            _articles = articlesData.articlesFilter(_isVisible);
          } else {
            _articles = [...articlesData.articles];
          }
          widget.filterMap(_articles, true);
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(children: [
            Flexible(
                child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                widget.showMap();

                if (_isVisible.isNotEmpty) {
                  _articles = articlesData.articlesFilter(_isVisible);
                } else {
                  _articles = [...articlesData.articles];
                }
                widget.filterMap(_articles, true);
              },
              child: Container(
                width: MediaQuery.of(context).size.height,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration:
                    const BoxDecoration(borderRadius: BorderRadius.vertical()),
              ),
            )),
            AppBar(
                leading: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Image.asset('assets/images/icones/ICON_ABC.png'),
                ),
                backgroundColor: Colors.white),
            DefaultTabController(
              length: 2,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                height: MediaQuery.of(context).size.height * 0.67,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    TabBar(
                      unselectedLabelColor: Colors.black38,
                      labelColor: const Color.fromRGBO(209, 62, 150, 1),
                      indicatorColor: Colors.pink,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onTap: (index) {
                        setState(() {
                          notion = !notion;
                        });
                      },
                      tabs: [
                        Tab(
                          icon: Image.asset(
                            notion
                                ? 'assets/images/icones/ICON_CASE.png'
                                : 'assets/images/icones/ICON_CASE+ CLAIR.png',
                            height: 44,
                            width: 44,
                            fit: BoxFit.cover,
                          ),
                          text: !widget.trade
                              ? 'Notions contemporaines'
                              : 'Contemporary notions',
                        ),
                        Tab(
                            icon: Image.asset(
                              !notion
                                  ? 'assets/images/icones/ICON_LIVRE.png'
                                  : 'assets/images/icones/ICON_LIVRE CLAIR.png',
                              height: 44,
                              width: 44,
                              fit: BoxFit.cover,
                            ),
                            text:
                                !widget.trade ? 'Définitions' : 'Definitions'),
                      ],
                    ),
                    Expanded(
                        child: TabBarView(children: [
                      ///container for menu Notions Contemporaines
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),

                            SizedBox(
                              height: 45,
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  /// Button 'Tout deselectionner'
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                    width: 190,
                                    child: TextButton(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            !widget.trade
                                                ? 'Tout dessélectionner'
                                                : 'Unselect all',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                                fontFamily: 'myriad'),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                      onPressed: () {
                                        _articles = [...articlesData.articles];
                                        tagsData.isNotVisibleAll();
                                        widget.filterMap(_articles, false);
                                      },
                                    ),
                                    height: 30,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),

                            /// List chips
                            Expanded(
                              child: SingleChildScrollView(
                                child: _titleController.text.isNotEmpty &&
                                        _listChip.isEmpty
                                    ? SizedBox(
                                        height: 500,
                                        width: 200,
                                        child: Center(
                                          child: Text(
                                            !widget.trade
                                                ? 'Aucun resultat!'
                                                : 'No result',
                                            style: TextStyle(
                                                fontFamily: 'myriad',
                                                fontSize: 24,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black54),
                                          ),
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 10, 10, 10),
                                            child: Wrap(
                                              spacing: 10,
                                              children: _buildAllChip(),
                                              runSpacing: 8,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                        color: Colors.white,
                      ),

                      ///container for menu Definitions
                      Container(
                        height: 600,
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: const EdgeInsets.all(15),

                        /// ARTICLES
                        child: ListView.builder(
                            itemCount: tags.length,
                            shrinkWrap: true,
                            itemBuilder: (ctx, index) => Container(
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            Provider.of<TagProvider>(context,
                                                listen: false);
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            SizedBox(height: 20),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                !widget.trade
                                                    ? tags[index].label
                                                    : tags[index].labelEN,
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      209, 62, 150, 1),
                                                  fontSize: 16,
                                                  fontFamily: 'myriad',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                !widget.trade
                                                    ? tags[index].definition
                                                    : tags[index].definitionEN,
                                                maxLines: maxLines,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: 'myriad',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                      )
                    ]))
                  ],
                ),
              ),
            )
          ]),
        ));
  }
}
