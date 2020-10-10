import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
  NativeAdmobController _controller;

  void openRecipeScreen(context, recipe) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => RecipeScreen(recipe: recipe)));
  }

  int getDivider(Orientation orientation) {
    return orientation == Orientation.portrait ? 3 : 6;
  }

  int getItemCount(int listLength, Orientation orientation) {
    print(listLength);
    int divider = getDivider(orientation);
    int adsCount = (listLength / divider).floor();
    if (adsCount >= 1 && (listLength + 1) % divider == 0) {
      adsCount = adsCount - 1;
    }

    print(listLength + adsCount);

    return listLength + adsCount;
  }

  @override
  void initState() {
    super.initState();
    _controller = NativeAdmobController();
    _controller.setTestDeviceIds(testDevices);

    if (consent == null) {
      _controller.setNonPersonalizedAds(true);
    } else {
      _controller.setNonPersonalizedAds(!consent);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recipeList.length > 0) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.defaultSize * 0.6,
        ),
        child: OrientationBuilder(
          builder: (context, orientation) => StaggeredGridView.countBuilder(
              itemCount: getItemCount(widget.recipeList.length, orientation),
              primary: true,
              crossAxisCount: orientation == Orientation.portrait ? 1 : 2,
              mainAxisSpacing: SizeConfig.defaultSize * 0.5,
              crossAxisSpacing: orientation == Orientation.portrait
                  ? 0
                  : SizeConfig.defaultSize * 0.5,
              staggeredTileBuilder: (index) {
                return new StaggeredTile.fit(1);
              },
              itemBuilder: (context, index) {
                if ((index + 1) % getDivider(orientation) == 0) {
                  return StreamBuilder<Object>(
                      stream: _controller.stateChanged,
                      builder: (context, snapshot) {
                        if (snapshot.hasError ||
                            snapshot.data == AdLoadState.loadError ||
                            snapshot.data == AdLoadState.loading) {
                          return Container(
                            height: 0,
                          );
                        } else {
                          return Container(
                            height: 100,
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      SizeConfig.defaultSize * 0.4)),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: NativeAdmob(
                                  adUnitID:
                                      'ca-app-pub-8850562463084333/4731800008',
                                  controller: _controller,
                                  type: NativeAdmobType.banner,
                                  error: Container(),
                                ),
                              ),
                            ),
                          );
                        }
                      });
                } else {
                  int newIndex = index -
                      ((index + 1) / (getDivider(orientation) + 1)).floor();
                  return buildRecipePreviewCard(
                      context, widget.recipeList[newIndex]);
                }
              }),
        ),
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
