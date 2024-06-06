import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import './../globals.dart' as globals;
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/tag.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  Map user;
  List _tags;
  File _image;
  String _imageFromDb;
  String _uploadedFileURL;
  String _defaultPhoto;
  bool _loading=false;
  CollectionReference users = Firestore.instance.collection('users');
  final TextEditingController _linkedInController = TextEditingController();
  final TextEditingController _descriptionCotroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    initUser();
   
   }

  final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();


  initUser() async {

    setState(() {
      _loading= true;
    });
    UserService().getUser().then((QuerySnapshot docs) {
      setState(() {
        user = docs.documents[0].data;
        globals.userID = docs.documents[0].documentID;
        _tags = user['tags'];
        _descriptionCotroller.text = user['description'];
        _linkedInController.text = user['linkedIn'];
        _imageFromDb = user['picture'];
        _loading=false;
         });

    });
    return _tags;
  }

  Future updateUser(user) async {
    return await users.document(globals.userID).setData({
      'auth_id': globals.authId,
      'description': _descriptionCotroller.text,
      'first_name': user['first_name'],
      'isAdmin': user['isAdmin'] !=null ? user['isAdmin']: false,
      'picture': _uploadedFileURL == null ? user['picture'] : _uploadedFileURL,
      'tags': _tags,
      'linkedIn': _linkedInController.text
    }).then((onValue) => this.showSuccessAlert());
  }

  Future takePhoto(BuildContext context) async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
    saveImageToStorage();
    Navigator.of(context).pop();
  }

  Future importPhoto(BuildContext context) async {
    print('import photo');
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
    saveImageToStorage();
    Navigator.of(context).pop();
  }

  saveImageToStorage() async {
    if (_image != null) {
      StorageReference storageReference =
          FirebaseStorage.instance.ref().child(p.basename(_image.path));

      StorageUploadTask uploadTask = storageReference.putFile(_image);

      await uploadTask.onComplete;
      storageReference.getDownloadURL().then((fileURL) {
        setState(() {
          _uploadedFileURL = fileURL;
        });
      });
    }
  }

  conditionImage(imgFromDb) {
    if (_image == null && imgFromDb != null) {
      return imgFromDb;
    } 
    else if (_image == null && imgFromDb == null) {
     return _defaultPhoto;
    } 
    else if (_image != null) {
      return _image;
    }
  }

  Future<void> showSuccessAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Votre profil a bien été mis à jour.'),
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

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker.retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = response.file;
      });
    } else {
      print(response.exception);
    }
  }

  Future _choiceUploadImage(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choisissez une action'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text(
                    'Prendre une photo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  onTap: () {
                    takePhoto(context);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                ),
                GestureDetector(
                  child: Text(
                    'Télécharger une image',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  onTap: () {
                    importPhoto(context);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _tags = _tags != null ? new List<String>.from(_tags) : [];
if(_loading) return CircularProgressIndicator();
else
    return Scaffold(
        appBar: AppBar(
            title: Text(
              'Modifier mon profil',
              style: TextStyle(color: Color.fromARGB(255, 254, 234, 12)),
            ),
            backgroundColor: Colors.black,
            centerTitle: true),
        body: Material(
            child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //image
              Container(
                width: MediaQuery.of(context).size.width * 0.55,
                height: MediaQuery.of(context).size.width * 0.55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  border: Border.all(color: Colors.black),
                ),
                child: _imageFromDb == null || _imageFromDb ==  "" ? Image.asset('assets/images/logo-seul.png'):
                 FadeInImage.assetNetwork(
                    placeholder: 'assets/images/loading.gif',
                    image: conditionImage(_imageFromDb),
                    
                    ),
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
              ),

              //update photo
              IconButton(
                  iconSize: 30.0,
                  icon: Icon(Icons.camera_alt),
                  onPressed: () {
                    _choiceUploadImage(context);
                  }),

              //description label
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Ma description ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),

              //description TextField
              Row(
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: TextFormField(
                        maxLines: 3,
                        controller: _descriptionCotroller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ))
                ],
              ),

              //linkedIn
              Row(
                // mainAxisAlignment: MainAxisAlignment.lef,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: InkWell(
                        child: Image.asset(
                            'assets/images/LinkedIn_logo_initials.png',
                            height: 30.0),
                        onTap: () async {
                          if (await canLaunch("https://fr.linkedin.com/")) {
                            await launch("https://fr.linkedin.com/");
                          }
                        },
                      )),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.70,
                    child: TextFormField(
                      controller: _linkedInController,
                      decoration:
                          InputDecoration(hintText: 'Mon lien LinkedIn '),
                    ),
                  )
                ],
              ),

              //Tags
              Row(
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      height: MediaQuery.of(context).size.width * 0.40,
                      child: Tags(
                        key: _tagStateKey,
                        verticalDirection: VerticalDirection.up,
                        textDirection: TextDirection.rtl,
                        textField: TagsTextField(
                          autofocus: false,
                          width: MediaQuery.of(context).size.width * 0.80,
                          hintText: "Ajouter un tag",
                          textStyle: TextStyle(fontSize: 14),
                          onSubmitted: (String str) {
                            setState(() {
                              _tags.add(str);
                            });
                          },
                        ),
                        itemCount: _tags.length,
                        itemBuilder: (int index) {
                          final item = _tags[index];
                          return ItemTags(
                            key: Key(index.toString()),
                            index: index,
                            title: item,
                            activeColor: Colors.grey,
                            combine: ItemTagsCombine.withTextBefore,
                            removeButton: ItemTagsRemoveButton(),
                            onRemoved: () {
                              setState(() {
                                _tags.removeAt(index);
                              });
                            },
                          );
                        },
                      ))
                ],
              ),

              //save profile button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: RaisedButton(
                  color: Color.fromARGB(255, 254, 234, 12),
                  onPressed: () {
                    updateUser(user).catchError((onError) => print(onError));
                  },
                  child: Text('Enregistrer mon profil'),
                ),
              )
            ],
          ),
        )));
  }
}

class UserService {
  Future<QuerySnapshot> getUser() {
    return Firestore.instance
        .collection('users')
        .where("auth_id", isEqualTo: globals.authId)
        .getDocuments();
  }
}
