import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mesrecettes/size_config.dart';

class RecipeInformation extends StatelessWidget {
  final String prepTime, cookTime, people;

  const RecipeInformation({Key key, this.people, this.prepTime, this.cookTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultSize * 0.4)),
      child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(defaultSize * 0.6),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/timer.svg'),
                    SizedBox(
                      width: defaultSize * 0.4,
                    ),
                    Text(this.prepTime),
                  ],
                ),
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/cook.svg'),
                    SizedBox(
                      width: defaultSize * 0.4,
                    ),
                    Text(this.cookTime),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(
                      width: defaultSize * 0.4,
                    ),
                    Text(this.people)
                  ],
                ),
              ])),
    );
  }
}
