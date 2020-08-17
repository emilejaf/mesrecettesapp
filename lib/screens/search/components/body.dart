import 'package:mesrecettes/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:mesrecettes/screens/home/components/recipe_list.dart';
import 'package:provider/provider.dart';

class Body extends StatelessWidget {
  final String searchedText;

  const Body({Key key, this.searchedText}) : super(key: key);

  List<Recipe> getRecipeList(List<Recipe> recipes) {
    return recipes
        .where((recipe) =>
            recipe.name.toLowerCase().contains(searchedText.toLowerCase()) ||
            recipe.ingredients.any((ingredient) =>
                ingredient.toLowerCase().contains(searchedText.toLowerCase())))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Recipes>(
      builder: (context, recipes, child) {
        List<Recipe> recipeList = getRecipeList(recipes.items);
        return RecipeList(
          recipeList: recipeList,
        );
      },
    );
  }
}
