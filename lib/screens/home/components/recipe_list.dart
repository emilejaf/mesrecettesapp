import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_native_admob/native_admob_options.dart';
import 'package:mesrecettes/constants.dart';
import 'package:mesrecettes/screens/recipe/components/recipe_preview.dart';
import 'package:mesrecettes/screens/recipe/recipe_screen.dart';
import 'package:mesrecettes/size_config.dart';
import 'package:mesrecettes/models/recipe.dart';
import 'package:flutter/material.dart';

class RecipeList extends StatefulWidget {
  final List<Recipe> recipeList;

  const RecipeList({Key key, this.recipeList}) : super(key: key);

  @override
  _RecipeListState createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  List<NativeAdmobController> _controllers;

  void openRecipeScreen(context, recipe) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => RecipeScreen(recipe: recipe)));
  }

  int getItemCount(int listLength) {
    int adsCount = (listLength / 3).floor();
    if (adsCount >= 1 && listLength % 3 == 0) {
      adsCount = adsCount - 1;
    }

    return listLength + adsCount;
  }

  @override
  void initState() {
    super.initState();
    _controllers = [];
  }

  @override
  void dispose() {
    super.dispose();

    _controllers.forEach((controller) {
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recipeList.length > 0) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.defaultSize * 0.6,
        ),
        child: GridView.builder(
            itemCount: getItemCount(widget.recipeList.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    SizeConfig.orientation == Orientation.landscape ? 2 : 1,
                mainAxisSpacing: SizeConfig.defaultSize * 0.3,
                crossAxisSpacing:
                    SizeConfig.orientation == Orientation.landscape
                        ? SizeConfig.defaultSize * 2
                        : 0,
                childAspectRatio: 16 / 9),
            itemBuilder: (context, index) {
              if ((index + 1) % 4 == 0) {
                NativeAdmobController _controller = NativeAdmobController();

                _controller.setTestDeviceIds(testDevices);

                _controller.setNonPersonalizedAds(!consent);
                _controllers.add(_controller);
                return Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(SizeConfig.defaultSize * 0.4)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: NativeAdmob(
                      adUnitID: 'ca-app-pub-8850562463084333/4731800008',
                      controller: _controller,
                      type: NativeAdmobType.full,
                      loading: Container(),
                      error: Container(),
                    ),
                  ),
                );
              } else {
                int newIndex = index - ((index + 1) / 4).floor();
                return buildRecipePreviewCard(
                    context, widget.recipeList[newIndex]);
              }
            }),
      );
    } else {
      return Container();
    }
  }

  Widget buildRecipePreviewCard(BuildContext context, Recipe recipe) {
    return GestureDetector(
      onTap: () => openRecipeScreen(context, recipe),
      child: RecipePreview(
        name: recipe.name,
        hasImage: recipe.hasImage,
        path: recipe.path,
      ),
    );
  }
}
