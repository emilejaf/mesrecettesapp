import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
  void openRecipeScreen(context, recipe) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => RecipeScreen(recipe: recipe)));
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
              itemCount: widget.recipeList.length,
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
                return buildRecipePreviewCard(
                    context, widget.recipeList[index]);
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
