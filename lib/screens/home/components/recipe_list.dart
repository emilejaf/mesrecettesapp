import 'package:mesrecettes/screens/recipe/components/recipe_preview.dart';
import 'package:mesrecettes/screens/recipe/recipe_screen.dart';
import 'package:mesrecettes/size_config.dart';
import 'package:mesrecettes/models/recipe.dart';
import 'package:flutter/material.dart';

class RecipeList extends StatelessWidget {
  final List<Recipe> recipeList;

  const RecipeList({Key key, this.recipeList}) : super(key: key);

  void openRecipeScreen(context, recipe) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => RecipeScreen(recipe: recipe)));
  }

  @override
  Widget build(BuildContext context) {
    if (recipeList.length > 0) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.defaultSize * 0.6,
        ),
        child: GridView.builder(
          itemCount: recipeList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  SizeConfig.orientation == Orientation.landscape ? 2 : 1,
              mainAxisSpacing: SizeConfig.defaultSize * 0.3,
              crossAxisSpacing: SizeConfig.orientation == Orientation.landscape
                  ? SizeConfig.defaultSize * 2
                  : 0,
              childAspectRatio: 16 / 9),
          itemBuilder: (context, index) =>
              buildRecipePreviewCard(context, recipeList[index]),
        ),
      );
    } else {
      return Container();
    }
  }

  GestureDetector buildRecipePreviewCard(BuildContext context, Recipe recipe) {
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
