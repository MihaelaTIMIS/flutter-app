import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:le30_app_mobile/homepage/homepage.dart';
import 'package:le30_app_mobile/coworkers/coworkers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController emailField = new TextEditingController();
  TextEditingController passwordField = new TextEditingController();

  String _errorMessage = "";
  bool _loadingConnect = false;
  bool _loadingForgotPassword = false;
  bool rememberMe = true;
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
 //StreamSubscription<IosNotificationSettings> iosSubscription;

  @override
  void initState() {
    super.initState();
    _getData();

    _fcm.getToken().then((token) {
      print('!!!!!!!!!!!!!!token');
      print(token);
    });

    if (Platform.isIOS) {
      print('!!!!!!!!ios!!!!!!!!!!!!!');
        _fcm.onIosSettingsRegistered.listen((data){
      //  _saveDeviceToken();
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }
      //else
      //_saveDeviceToken();

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");

        final snackbar = SnackBar(
          content: Text(message['notification']['title']),
          action: SnackBarAction(
            label: 'Go',
            onPressed: () => null,
          ),
        );

        Scaffold.of(context).showSnackBar(snackbar);
      },
    );
  }

  _saveDeviceToken() async {
    String uid = globals.authId;
    String fcmToken = await _fcm.getToken();
    if (fcmToken != null) {
      var tokenRef = _db
          .collection('users')
          .document(uid)
          .collection('tokens')
          .document(fcmToken);

      await tokenRef.setData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem
      });
    }
  }

  whenError(error) {
    print(error);
    switch (error.code) {
      case 'ERROR_MISSING_EMAIL':
        setState(() {
          _errorMessage = 'Une adresse email doit être renseignée.';
        });
        break;
      case 'ERROR_INVALID_EMAIL':
        setState(() {
          _errorMessage = 'Veuillez renseigner un email valide.';
        });
        break;
      case 'ERROR_USER_NOT_FOUND':
        setState(() {
          _errorMessage = 'Aucun utilisateur ne correspond à cet email.';
        });
        break;
      case 'ERROR_WRONG_PASSWORD':
        setState(() {
          _errorMessage = 'Le mot de passe n\'est pas valide.';
        });
        break;
      case 'ERROR_NETWORK_REQUEST_FAILED':
        setState(() {
          _errorMessage =
              'Une erreur réseau (comme un délai d\'attente, une connexion interrompue ou un hôte inaccessible) s\'est produite.';
        });
        break;
      default:
        setState(() {
          _errorMessage =
              'Une erreur interne s\'est produite. Veuillez réessayer ultérieurement.';
        });
        break;
    }
  }

  updatePassword(email) {
    setState(() {
      _errorMessage = '';
      _loadingForgotPassword = true;
    });
    FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((onValue) {
      setState(() {
        _loadingForgotPassword = false;
      });
      showSuccessAlert();
    }).catchError((error) {
      setState(() {
        _loadingForgotPassword = false;
      });
      whenError(error);
    });
  }

  Future<void> showSuccessAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title:Image.asset("assets/images/success.png", width: 1),
          content: Text(
              "Un email pour initialiser le mot de passe vous a été envoyé."),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.black),
              ),
              color: Color.fromARGB(255, 254, 234, 12),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _saveStorageData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('email', emailField.text);
  }

  _removeStorageData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
  }

  Future<String> _getData() async {
    final prefs = await SharedPreferences.getInstance();
    emailField.text = prefs.getString('email') ?? null;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
              child: Form(
                  key: _registerFormKey,
                  child: Column(children: <Widget>[
                    //logo
                    Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Image.asset('assets/images/logo-le30.png'),
                    ),

                    //email
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                      child: TextFormField(
                        autofocus: false,
                        controller: emailField,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(hintText: 'Email'),
                      ),
                    ),

                    //password
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                      child: TextFormField(
                        controller: passwordField,
                        autofocus: false,
                        obscureText: true,
                        decoration: InputDecoration(hintText: 'Mot de passe'),
                      ),
                    ),

                    //keep me signed
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Checkbox(
                          value: rememberMe,
                          onChanged: (bool value) {
                            setState(() {
                              rememberMe = value;
                            });
                          },
                        ),
                        Text("Se souvenir de moi")
                      ],
                    ),

                    //connect button
                    _loadingConnect
                        ? CircularProgressIndicator()
                        : Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: FlatButton(
                              onPressed: () {
                                setState(() {
                                  _loadingConnect = true;
                                });
                                FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                        email: emailField.text.trim(),
                                        password: passwordField.text)
                                    .then((result) {
                                  if (rememberMe)
                                    _saveStorageData();
                                  else
                                    _removeStorageData();

                                  setState(() {
                                    _loadingConnect = false;
                                  });
                                  globals.authId = result.user.uid;

                                  Navigator.of(context)
                                      .push(FadeRoute(page: HomePage()));
                                }).catchError((error) {
                                  setState(() {
                                    _loadingConnect = false;
                                  });
                                  whenError(error);
                                });
                              },
                              color: Color.fromARGB(255, 254, 234, 12),
                              child: Text('Se connecter'),
                            ),
                          ),

                    //forgot password
                    _loadingForgotPassword
                        ? CircularProgressIndicator()
                        : Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 25.0,
                            ),
                            child: GestureDetector(
                              child: Text(
                                'Mot de passe perdu ?',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              onTap: () {
                                updatePassword(emailField.text);
                              },
                            ),
                          ),

                    //error message
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 20.0),
                      child: Text(_errorMessage,
                          style: TextStyle(color: Colors.red)),
                    )
                  ])))),
    );
  }
}
