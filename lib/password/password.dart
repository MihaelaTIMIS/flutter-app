import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
class EditPasswordPage extends StatefulWidget {
  @override
  _EditPasswordPageState createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> {
  final GlobalKey<FormState> _updatePasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _actualPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();

  bool _autoValidate = false;
  bool _loading = false;

   updatePassword() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
      FirebaseAuth.instance
        .sendPasswordResetEmail(email: user.email)
        .catchError((onError) => print(onError));
    }

 

  String validatePassword(String value) {
    if (value.isEmpty) {
      return 'Veuillez fournir un mot de passe.';
    }
    if (value.length < 6) {
      return 'Le mot de passe valid doit avoir minimum 6 caractères.';
    }
    return null;
  }

  void _validateInputs() async {
    setState(() {
      _loading = true;
    });
    //1. tester if the actual password is correct
    //2. if the password is<6caractères
    //3. if the passwords match
    if (_updatePasswordFormKey.currentState.validate()) {
      _updatePasswordFormKey.currentState.save();
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  Widget buildWaitingScreen() {
    if (_loading) {
      return Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        ),
      );
    } else
      return null;
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
        body: Form(
            key: _updatePasswordFormKey,
            autovalidate: _autoValidate,
            child: Container(
              padding: EdgeInsets.all(30.0),
              child: Column(
                children: <Widget>[
                  //photo Le Trente
                  Padding(
                      padding: EdgeInsets.only(top: 30.0, bottom: 30.0),
                      child: Image.asset('assets/images/logo-le30.png',
                          width: 200, height: 200)),

                  //actual password
                  Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: TextFormField(
                        controller: _actualPassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe actuelle',
                        ),
                        validator: validatePassword,
                      )),

                  //new password
                  Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: TextFormField(
                        controller: _newPassword,
                        decoration: InputDecoration(
                          labelText: 'Nouveau mot de passe',
                        ),
                        validator: validatePassword,
                      )),

                  // password confirm

                  Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: TextFormField(
                        controller: _passwordConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirmer mot de passe',
                        ),
                        validator: validatePassword,
                      )),

                  RaisedButton(
                    color: Color.fromARGB(255, 254, 234, 12),
                    onPressed: () {
                      buildWaitingScreen();
                      _validateInputs();
                      updatePassword();
                     
                    },
                    child: Text('Enregistrer le mot de passe'),
                  ),
                ],
              ),
            )));
  }
}
