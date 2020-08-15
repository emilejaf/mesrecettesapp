import 'package:flutter/material.dart';
import 'package:mesrecettes/size_config.dart';

class RecipePreview extends StatelessWidget {
  final String name;

  const RecipePreview({Key key, this.name}) : super(key: key);

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
            Image.asset(
              'assets/images/recipe_picture.jpg',
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
                    color: Colors.white,
                    fontSize: defaultSize * 2,
                    fontWeight: FontWeight.w500),
              ),
            ))
          ])),
    );
  }
}
