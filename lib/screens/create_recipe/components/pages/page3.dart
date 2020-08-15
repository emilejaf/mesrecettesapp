import 'package:flutter/material.dart';
import 'package:mesrecettes/size_config.dart';

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Container(
      alignment: Alignment.center,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(defaultSize * 0.4),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultSize * 0.4)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      'assets/images/recipe_picture.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {},
                      child: Text('Choisir une photo'),
                    ),
                    IconButton(icon: Icon(Icons.delete), onPressed: () {})
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
