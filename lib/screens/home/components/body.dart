import 'package:flutter/material.dart';
import 'package:mesrecettes/models/category.dart';
import 'package:mesrecettes/models/recipe.dart';
import 'package:mesrecettes/screens/recipe/components/recipe_preview.dart';
import 'package:mesrecettes/screens/recipe/recipe_screen.dart';
import 'package:mesrecettes/size_config.dart';
import 'package:provider/provider.dart';

class Body extends StatelessWidget {
  void openRecipeScreen(context, recipe) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => RecipeScreen(recipe: recipe)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<Recipes, Categories>(
        builder: (context, recipes, categories, child) => TabBarView(
              children: [
                buildRecipeList(recipes.items),
                ...categories.items.map((category) => buildRecipeList(recipes
                    .items
                    .where((recipe) => category.recipeIds.contains(recipe.id))
                    .toList()))
              ],
            ));
  }

  Widget buildRecipeList(List<Recipe> recipes) {
    if (recipes.length > 0) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.defaultSize * 0.6,
        ),
        child: GridView.builder(
          itemCount: recipes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  SizeConfig.orientation == Orientation.landscape ? 2 : 1,
              mainAxisSpacing: SizeConfig.defaultSize * 0.3,
              crossAxisSpacing: SizeConfig.orientation == Orientation.landscape
                  ? SizeConfig.defaultSize * 2
                  : 0,
              childAspectRatio: 16 / 9),
          itemBuilder: (context, index) =>
              buildRecipePreviewCard(context, recipes[index]),
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
      ),
    );
  }
}
