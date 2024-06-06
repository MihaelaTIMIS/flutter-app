import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  var queryResultSet = [];
  var tempSearchStore = [];
  
  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        tempSearchStore = []; 
      });
    }

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['first_name'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
  }

  _getSnapShots() {
    SearchService().searchByName().map((snapshot){
      snapshot.then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          queryResultSet.add(docs.documents[i].data);
        }
      });
    }).toList();
  }

  @override
  void initState() {
    _getSnapShots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
              hintText: "Search",
            hintStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold
            )
          ),
        onChanged: (val) {
      initiateSearch(val.toUpperCase());
    },),
      ),

        body: ListView(children: <Widget>[
          SizedBox(height: 10.0),
          GridView.count(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              crossAxisCount: 2,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              primary: false,
              shrinkWrap: true,
              children: tempSearchStore.map((element) {
                return buildResultCard(element);
              }).toList())
        ]));
  }
}

Widget buildResultCard(data) {
  return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 2.0,
      child: Container(
          child: Center(
              child: Text(data['first_name'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              )
          )
      )
  );
}

class SearchService {
  List<Future<QuerySnapshot>> searchByName() {
    return [
      Firestore.instance
          .collection('users')
          .where('first_name')
          .getDocuments(),

      // Firestore.instance
      //     .collection('users')
      //     .where('description')
      //     .getDocuments(),
    ];
  }
}