import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mesrecettes/size_config.dart';

class Page3 extends StatefulWidget {
  final File image;
  final Function callback;

  const Page3({Key key, this.image, this.callback}) : super(key: key);

  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  final picker = ImagePicker();

  Future pickImage(ImageSource source, BuildContext context) async {
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      final cropped = await ImageCropper.cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
          androidUiSettings:
              AndroidUiSettings(toolbarTitle: "Modifier l'image"),
          iosUiSettings: IOSUiSettings(title: "Modifier l'image"));
      widget.callback(cropped ?? File(pickedFile.path));
    }

    FocusScope.of(context).unfocus();
    Navigator.pop(context);
  }

  void openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Appareil photo'),
                onTap: () => pickImage(ImageSource.camera, context),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galerie'),
                onTap: () => pickImage(ImageSource.gallery, context),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Container(
      alignment: Alignment.topCenter,
      child: Card(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (widget.image != null)
                Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultSize * 0.4)),
                  child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.file(
                        widget.image,
                        fit: BoxFit.cover,
                      )),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    onPressed: () => openBottomSheet(context),
                    child: Text('Choisir une photo'),
                  ),
                  IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => widget.callback(null))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
