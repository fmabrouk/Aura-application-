import 'package:awesome_notifications/awesome_notifications.dart';

import '../../widgets/customAppBar.dart';
import 'package:flutter/material.dart';

/// affchage de la fenetre contacter nous (avec le mail de contact)
class ContacterScreen extends StatefulWidget {
  /// Permet de savoir si la page doit être traduite en anglais
  bool trade;

  static const routeName = '/contacter.dart';

  ContacterScreen({Key key, this.trade}) : super(key: key);

  @override
  contacterScreenState createState() => contacterScreenState();
}

class contacterScreenState extends State<ContacterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leadingWidth: 100,
          leading: CustomAppBar(
            from: '',
          ),
        ),
        body: Column(children: [
          SizedBox(height: 200),
          Container(
            //color: Colors.white,
            width: double.infinity,
            child: Center(
              child: Container(
                height: 300,
                width: 250,
                child: !widget.trade
                    ? Text(
                        'Merci de nous contacter à l\'adresse suivante : \n auraguidearchitecture@gmail.com',
                        style: TextStyle(fontFamily: 'myriad', fontSize: 23),
                      )
                    : Text(
                        'Please contact us at the following address :\n auraguidearchitecture@gmail.com',
                        style: TextStyle(fontFamily: 'myriad', fontSize: 23),
                      ),
              ),
            ),
          ),
        ]));
  }
}
