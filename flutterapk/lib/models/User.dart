class UserCustom {
  // identifiant
  final String id;
  // Nom de l'utilsiateur
  final String nom;
  // Prenom de l'utilisateur
  final String prenom;
  // Date de naissance
  final String dateNaissance;
  // Email
  final String eMail;
  // Numero de telephone
  final String phone;
  // Mot de passe
  final String passeword;
  // Liste des favoris
  final List<String> favoris;
  final Map<String, dynamic> couleurs;

  /// sexe
  final String sexe;

  /// indique s'il est administrateur ou non
  final bool isAdmin;

  /// indique la range pour la notification
  final bool range;

  /// indique la fréquence de l'envoie de la notif de suggestions
  final int freq;

  final bool trade;

  const UserCustom(
      {this.isAdmin = false,
      this.id,
      this.nom,
      this.prenom,
      this.dateNaissance,
      this.eMail,
      this.phone,
      this.passeword,
      this.favoris,
      this.sexe,
      this.range,
      this.couleurs,
      this.freq,
      this.trade});
}
