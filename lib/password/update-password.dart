import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_appavailability/flutter_appavailability.dart';

class UpdatePasswordPage extends StatefulWidget {
  @override
  _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {

  void openEmailApp(BuildContext context){
    try{
        AppAvailability.launchApp(Platform.isIOS ? "message:" : "com.google.android.gm").then((_) {
                print("App Email launched!");
              }).catchError((err) {
                
                print(err);
              });
    } catch(e) {
      print(e);
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              'Modifier le mot de passe',
              style: TextStyle(color: Color.fromARGB(255, 254, 234, 12)),
            ),
            backgroundColor: Colors.black,
            centerTitle: true),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              //photo Le Trente
              Padding(
                  padding: EdgeInsets.only(top: 30.0, bottom: 30.0),
                  child: Image.asset('assets/images/logo-le30.png',
                      width: 200, height: 200)),

              // password confirm
              Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  child: Text(
                      "Un lien vous a été envoyé à l'adresse mail que vous utilisez pour vous connecter à cette application. \n\nConsultez votre boîte mail pour mettre à jour le mot de passe.\n\n")),
              //button
              RaisedButton(
                color: Color.fromARGB(255, 254, 234, 12),
                onPressed: () {
                  openEmailApp(context);
                },
                child: Text('Consulter ma boîte mail'),
              ),
            ],
          ),
        ));
  }
}
