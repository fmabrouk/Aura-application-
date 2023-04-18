import 'package:aura2/models/article.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

int geoloc_notif_id = 0;
int freq_notif_id = 3;

/// fonction qui créé la notif Geolocalisation (on en affiche que 3)
Future<void> createNotifs(Article article, String str, bool trad) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
        id: geoloc_notif_id,
        channelKey: 'basic_channel',
        title: !trad
            ? '(A proximité) : ${article.title}, ${article.architecte}'
            : article.titleEN.length == 0
                ? '(Near) : ${article.title}, ${article.architecte}'
                : '(Near) : ${article.titleEN}, ${article.architecte}',
        body: str,
        displayOnBackground: true),
  );
  if (geoloc_notif_id == 2) {
    geoloc_notif_id = 0;
  } else {
    geoloc_notif_id++;
  }
}

/// fonction qui créé la notif fréquence (on en affiche que 1)
Future<void> createNotifFreq(Article article, String str, bool trad) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: freq_notif_id,
          channelKey: 'basic_channel',
          title: !trad
              ? '(A découvrir) :  ${article.title}, ${article.architecte}'
              : '(To discover) :  ${article.titleEN}, ${article.architecte}',
          body: str,
          displayOnBackground: true));
  if (freq_notif_id == 5) {
    freq_notif_id = 3;
  } else {
    freq_notif_id++;
  }
}
