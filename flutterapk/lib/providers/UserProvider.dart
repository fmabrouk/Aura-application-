import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import '../models/User.dart';

class UserProvider with ChangeNotifier {
  List<UserCustom> _users = [];

  Future<void> fetchAndSetUser() async {
    final List<UserCustom> _liste = [];
    await FirebaseFirestore.instance
        .collection('utilisateur')
        .get()
        .then((QuerySnapshot querySnapshot) =>
            querySnapshot.docs.forEach((QueryDocumentSnapshot element) {
              _liste.add(UserCustom(
                  id: element.id,
                  nom: element.get('name'),
                  prenom: element.get('prenom'),
                  eMail: element.get('eMail'),
                  phone: element.get('phone'),
                  dateNaissance: element.get('dateNaissance'),
                  passeword: element.get('password'),
                  sexe: element.get('sexe')));
              //range: element.get('range'),
              //couleurs: element.get('couleurs')));
              //trade: element.get('trade')));
              //freq: element.get('freq')));
            }))
        .catchError((onError) => throw onError);
    _users = [..._liste];
    //
    notifyListeners();
  }

  Future<void> exempleAsync() async {
    await fetchAndSetUser();
    // Maintenant que fetchAndSetUser est terminé, _users doit être initialisé
    List<String> fayez = [];
    for (int i = 0; i < users.length; i++) {
      fayez.add(users[i].id);
    }
    //print(fayez);
    print(users.length);
    // print(_users);
  }

  /// @return renvoie la liste des utilisateurs
  List<UserCustom> get users {
    return [..._users];
  }

  /// @args l'identifiant de l'utilisateur recherché
  /// @return renvoie un utilisateur dont l'identifiant = à id
  UserCustom searchUser(String id) {
    //return _users.firstWhere(((user) => user.id == id));
    for (var i = 0; i < _users.length; i++) {
      if (_users[i].id == id) {
        return _users[i];
      }
    }
    return null;
  }

  bool getTrade(String id) {
    for (var i = 0; i < _users.length; i++) {
      if (_users[i] == id) {
        return _users[i].trade;
      }
    }
  }

  /// @args l'utilisateur à ajouter
  /// permet d'ajouter un utilisateur dans la liste des utilisateurs
  void addUser(UserCustom at) {
    _users.add(at);
    notifyListeners();
  }

  /// @args l'utilisateur à supprimer
  /// permet de supprimer un utilisateur de la liste
  void delete(UserCustom user) {
    _users.removeWhere((item) => item.id == user.id);
    notifyListeners();
  }
}
