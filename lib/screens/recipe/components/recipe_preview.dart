import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mesrecettes/size_config.dart';

class RecipePreview extends StatelessWidget {
  final String name;
  final bool hasImage;
  final String path;

  const RecipePreview({Key key, this.name, this.hasImage, this.path})
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
            if (hasImage)
              Image.file(
                File(path),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
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
}
