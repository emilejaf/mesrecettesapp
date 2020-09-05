import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mesrecettes/size_config.dart';

class RecipePreview extends StatelessWidget {
  final String name;
  final bool hasImage;
  final String path;
  final bool localImage;

  const RecipePreview(
      {Key key, this.name, this.hasImage, this.path, this.localImage = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultSize * 0.4)),
          child: Stack(children: [
            if (hasImage) buildImage(),
            Positioned.fill(
                child: Container(
              padding:
                  EdgeInsets.fromLTRB(defaultSize * 1, 0, 0, defaultSize * 0.5),
              alignment: Alignment.bottomLeft,
              child: Text(
                name,
                style: TextStyle(
                    color: hasImage ? Colors.white : Colors.black,
                    fontSize: defaultSize * 2,
                    fontWeight: FontWeight.w500),
              ),
            ))
          ])),
    );
  }

  Image buildImage() {
    if (localImage) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else {
      return Image.network(path, fit: BoxFit.cover, width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return Center(
            child: SizedBox(
              child: CircularProgressIndicator(),
              width: 40,
              height: 40,
            ),
          );
        }
      });
    }
  }
}
