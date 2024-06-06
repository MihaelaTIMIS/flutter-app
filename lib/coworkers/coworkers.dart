import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:le30_app_mobile/coworkers/profile.dart';

class CoworkersList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CoworkersListState();
  }
}

class _CoworkersListState extends State<CoworkersList> {
  var users = [];
  var queryTagSet = [];
  var tempTagStore = [];
  var tempSearchStore = [];
  var searchStore = false;
  bool showSearchModule = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    _getUsers();
    super.initState();
  }

  void refreshPage() async {
    setState(() {
      showSearchModule = true;
    });
   // await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  testAndUpdateStore(user, searchIn, value) {
    if (searchIn.toLowerCase().indexOf(value) != -1 &&
        value.length > 1 &&
        !tempSearchStore.contains(user)) tempSearchStore.add(user);
  }

  initiateSearch(values) {
    if (values == '') {
      tempSearchStore = users;
    } else {
      tempSearchStore = [];
    }

    List searchValues = values.split(' ');

    searchValues.forEach((value) {
      users.forEach((user) {
        try {
          testAndUpdateStore(user, user['first_name'], value);
          user['tags'].forEach((tag) {
            testAndUpdateStore(user, tag, value);
          });
        } catch (e) {}
      });
    });

    setState(() {
      tempSearchStore = tempSearchStore;
    });
  }

  _getUsers() {
    UsersService().allUsers().map((snapshot) {
      snapshot.then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          users.add(docs.documents[i].data);
        }
        setState(() {
          users = users;
          tempSearchStore = users;
        });
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Communauté',
            style: TextStyle(
              color: Color.fromARGB(
                255,
                254,
                234,
                12,
              ),
            )),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SmartRefresher(
        enablePullDown: true,
        controller: _refreshController,
        onRefresh: refreshPage,
        //header: 
        // CustomHeader(
        //   builder: 
        //   (BuildContext context, RefreshStatus mode)
        //    {
        //     Widget body ;
        //     if(mode==RefreshStatus.idle){
        //       body =  Text("pull up load");
        //     }
        //     // else if(mode==RefreshStatus.refreshing){
        //     //   body =  CupertinoActivityIndicator();
        //     // }
        //     // else if(mode == RefreshStatus.failed){
        //     //   body = Text("Load Failed!Click retry!");
        //     // }
        //     // else if(mode == RefreshStatus.canRefresh){
        //     //     body = Text("release to load more");
        //     // }
        //     // else{
        //     //   body = Text("No more Data");
        //     // }
        //     return Container(
        //       height: 55.0,
        //       child: Center(child:body),
        //     );
        //   },
        // ),
    
        child: ListView.builder(
          itemBuilder: (c, i) => Column(
            children: <Widget>[
              //Search TextField
              Flexible(
                  child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
                child: showSearchModule
                    ? TextField(
                        autofocus: false,
                        decoration: InputDecoration(
                            hintText: "Rechercher",
                            hintStyle: TextStyle(
                              color: Colors.black,
                            )),
                        onChanged: (val) {
                          initiateSearch(val.toLowerCase());
                        },
                      )
                    : null,
              )),

              //search result or all coworkers
              Flexible(
                child: Material(
                    child: ListView(children: <Widget>[
                  SizedBox(height: 10.0),
                  GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      children: tempSearchStore.map((element) {
                        return buildUsersResult(element, context);
                      }).toList())
                ])),
              )
            ],
          ),
          itemExtent: 800.0,
          itemCount: 1,
        ),
      ),
    );
  }
}

Widget buildUsersResult(data, context) {
  return ListTile(
    title: FadeInImage.assetNetwork(
      placeholder: 'assets/images/loading.gif',
      image: data['picture'],
      width: 100.0,
      height: 100.0,
    ),
    subtitle: Text(
      data['first_name'],
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.black),
    ),
    onTap: () {
      Navigator.of(context).push(FadeRoute(page: ProfilePage(user: data)));
    },
  );
}

class UsersService {
  List<Future<QuerySnapshot>> allUsers() {
    return [
      Firestore.instance
          .collection('users')
          .orderBy('first_name')
          .getDocuments(),
    ];
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}
