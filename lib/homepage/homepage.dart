import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:le30_app_mobile/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:le30_app_mobile/coworkers/coworkers.dart';
import 'package:le30_app_mobile/profile/editprofile.dart';
import 'package:le30_app_mobile/password/update-password.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> news =
      Firestore.instance.collection('news').snapshots();
  
  String _locale='fr';

     @override
   void initState() {
    super.initState(); 
    initializeDateFormatting(_locale, null);
   }

  @override
  Widget build(BuildContext context) {
    _launchURL(url) async {
      //const url = 'https://www.letrente.paris-saclay.com/';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    updatePassword() async {
      final FirebaseUser user = await FirebaseAuth.instance.currentUser();
      FirebaseAuth.instance
          .sendPasswordResetEmail(email: user.email)
          .catchError((onError) => print(onError));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Actualités',
          style: TextStyle(color: Color.fromARGB(255, 254, 234, 12)),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Material(
        child: StreamBuilder<QuerySnapshot>(
          stream: news,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Scaffold(
                  body: Container(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  ),
                );

              default:
                return ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            children: [
                              Row(children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: Text( 
                                      DateFormat('EEE d MMM', _locale) 
                                        .format(snapshot
                                            .data.documents[index]['date']
                                            .toDate()),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(
                                      '|',
                                    )),
                                Text(
                                  'Le Trente',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                VerticalDivider(
                                  color: Colors.black,
                                  thickness: 2.0,
                                ),
                              ]),
                              Row(
                                children: <Widget>[
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.85,
                                      child: Text(snapshot.data.documents[index]
                                          ['resume']))
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  RaisedButton(
                                    color: Color.fromARGB(255, 235, 235, 234),
                                    onPressed: () => _launchURL(snapshot.data.documents[index]['link_more']),
                                    child: Text('En savoir plus'),
                                  ),
                                  RaisedButton(
                                    color: Color.fromARGB(255, 254, 234, 12),
                                    onPressed: () => _launchURL(snapshot.data.documents[index]['link_subscribe']),
                                    child: Text('S\'inscrire'),
                                  ),
                                ],
                              ),
                            ],
                          ));
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Divider(
                                height: 15.0,
                                color: Color.fromARGB(255, 254, 234, 12),
                                thickness: 2.0)));
            }
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 254, 234, 12),
              ),
              child: Image.asset('assets/images/logo-seul.png'),
            ),
            ListTile(
              leading: Icon(Icons.featured_play_list),
              title: Text('Actualités'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(FadeRoute(page: HomePage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Communauté'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(FadeRoute(page: CoworkersList()));
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Mon profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(FadeRoute(page: EditProfilePage()));
              },
            ),
            ListTile(
                leading: Icon(Icons.lock),
                title: Text('Modifer le mot de passe'),
                onTap: () {
                  updatePassword();
                  Navigator.of(context)
                      .push(FadeRoute(page: UpdatePasswordPage()));
                }),
            ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Déconnection'),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).push(FadeRoute(page: MyApp()));
                })
          ],
        ),
      ),
    );
  }
}
