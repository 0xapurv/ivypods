import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ivypods/data_holder.dart';
import 'package:ivypods/photo_upload.dart';
import 'package:ivypods/photo_upload.dart' as upload;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IvyPods',
      home: UploadPhotoPage(),
    );
  }
}

class ImageScreen extends StatefulWidget {

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  Widget makeImageGrid() {
    return GridView.builder(
        itemCount: 10,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context,index){
      return ImageGridItem(index+1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Grid"),
      ),
      body: Container(
        child : Center(
          child: makeImageGrid(),
        ),
      ),
      floatingActionButton:  FloatingActionButton(
          tooltip: "Add Image",
          child: Icon(Icons.add_a_photo),
          onPressed: () async{
            gotoUploadImage();
          }
      ),
    );
  }

  void gotoUploadImage(){
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return UploadPhotoPage();
    }));
  }
}

class ImageGridItem extends StatefulWidget {

  int _index;

  ImageGridItem(int index){
    this._index = index;
  }
  @override
  _ImageGridItemState createState() => _ImageGridItemState();
}

class _ImageGridItemState extends State<ImageGridItem> {

  Uint8List imageFile;
  StorageReference photosReference = FirebaseStorage.instance.ref().child("Post images");

  getImage(){
    if(!requestedIndexes.contains(widget._index)){
      int MAX_SIZE = 7*1024*1024;
      photosReference.child("${widget._index}.jpg").getData(MAX_SIZE).then((data){
        this.setState(() {
          imageFile = data;
        });
        imageData.putIfAbsent(widget._index, (){
          return data;
        });
      }).catchError((error){
        debugPrint(error.toString());
      });
     requestedIndexes.add(widget._index);
    }
  }
  
  Widget decideGridTileWidget(){
    if(imageFile == null){
      return Center(child : Text("No Data"));
    }
    else{
      return Image.memory(imageFile,fit: BoxFit.cover,);
    }
  }

  @override
  void initState(){
    super.initState();
    if(!imageData.containsKey(widget._index)){
      getImage();
    }
    else{
      this.setState(() {
        imageFile = imageData[widget._index];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridTile(child: decideGridTileWidget(),);
  }
}

