import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tags/tag.dart';
import 'package:le30_app_mobile/coworkers/coworkers.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({this.user});
  final user;

  @override
  _ProfilePageState createState() => _ProfilePageState(user: user);
}

class _ProfilePageState extends State<ProfilePage> {
  _ProfilePageState({this.user});
  final user;
  List _tags;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(FadeRoute(page: CoworkersList()));
              },
            ),
            title: Text(
              user['first_name'],
              style: TextStyle(color: Color.fromARGB(255, 254, 234, 12)),
            ),
            backgroundColor: Colors.black,
            centerTitle: true),
        body: Material(
            child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('users').snapshots(),
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
                _tags = user['tags'] != null
                    ? new List<String>.from(user['tags'])
                    : null;

                return Column(
                  children: <Widget>[
                    //picture
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: 30.0, bottom: 30.0),
                            child: Image.network(user['picture'],
                                width: 200, height: 200))
                      ],
                    ),

                    //LinkedIn
                    user['linkedIn'] == null  ? null:
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: 
                        InkWell(
                          child: Image.asset('assets/images/LinkedIn_logo_initials.png',
                                      height: 30.0),
                          onTap: () async {
                            if (await canLaunch(user['linkedIn'])) {
                              await launch(user['linkedIn']);
                            }
                          },
                        )),

                    //description
                    Row(
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(user['description']
                                  // overflow: TextOverflow.ellipsis,
                                  ),
                            ))
                      ],
                    ),

                    //tags label
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text('Tags:'),
                        )
                      ],
                    ),

                    //tags
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Tags(
                          itemCount: _tags != null ? _tags.length : 0,
                          itemBuilder: (int index) {
                            final item = user['tags'][index];
                            return ItemTags(
                              key: Key(_tags[index].toString()),
                              index: index,
                              title: item,
                              active: false,
                              border: Border.all(color: Colors.yellow, width: 2),
                              combine: ItemTagsCombine.onlyText,
                              pressEnabled:false,
                              elevation:0,
                              borderRadius: BorderRadius.circular(10),
                            );
                          },
                        ),
                      ],
                    ),
                  ].where((child) => child != null).toList(),
                );
            }
          },
        )));
  }
}
