import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


import 'package:ivypods/main.dart';


class UploadPhotoPage extends StatefulWidget {
  @override
  UploadPhotoPageState createState() => UploadPhotoPageState();
}

class UploadPhotoPageState extends State<UploadPhotoPage> {
  static int index = 1;
  PickedFile sampleImage;
  final ImagePicker _picker = ImagePicker();
  String _myValue;
  String url;
  final formKey = new GlobalKey<FormState>();

  Future getImage(ImageSource source) async {
    var tempImage = await _picker.getImage(source: source);

    setState(() {
      sampleImage = tempImage;
    });
  }

  bool validateAndSave(){
    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    else{
      return false;
    }
  }
  
  void uploadStatusImage() async {
    if(validateAndSave()){
      final StorageReference postImageRef = FirebaseStorage.instance.ref().child("Post images");

      DateTime date = DateTime.now();
      final StorageUploadTask uploadTask = postImageRef.child(index.toString() + ".jpg").putFile(File(sampleImage.path));
      setState(() {
        index++;
      });
      var ImageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
      url = ImageUrl.toString();
      saveToDatabase(url);
      gotoHomepage();
    }
  }

  void saveToDatabase(url){
    var dbTimeKey =  DateTime.now();
    var formatDate =  DateFormat("MMM d, yyyy");
    var formatTime = DateFormat(" EEEE, hh:mm aaa");

    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    DatabaseReference ref = FirebaseDatabase.instance.reference();

    var data = {
      "image" : url,
      "description" : _myValue,
      "date" : date,
      "time" : time,
    };

    ref.child("Posts").push().set(data);
  }

  Widget enableUpload(){
    return SingleChildScrollView(
      child: Container(
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              Image.file(File(sampleImage.path), height: 330.0, width: 660.0,),
              SizedBox(height: 15,),
              TextFormField(
                decoration: InputDecoration(labelText: "Description"),
                validator: (value){
                  return value.isEmpty ? "Image Description is required" : null;
                },
                onSaved: (value){
                  return _myValue = value;
                },
              ),
              SizedBox(height : 15.0 ),
              RaisedButton(
                elevation: 10.0,
                child: Text("Add a New Post"),
                textColor: Colors.white,
                color : Colors.pink,
                onPressed: uploadStatusImage,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image"),
        centerTitle: true,
      ),
      body: Center(
        child: sampleImage == null ? Text("Select an Image") : enableUpload(),
      ),
      floatingActionButton:  FloatingActionButton(
        tooltip: "Add Image",
        child: Icon(Icons.add_a_photo),
        onPressed: (){
          getImage(ImageSource.gallery);
        }
      ),
    );
  }

  void gotoHomepage(){
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return ImageScreen();
    }));
  }
}
