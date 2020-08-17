import 'package:flutter/material.dart';
import 'package:mesrecettes/models/category.dart';
import 'package:mesrecettes/models/recipe.dart';
import 'package:mesrecettes/screens/home/components/recipe_list.dart';
import 'package:provider/provider.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<Recipes, Categories>(
        builder: (context, recipes, categories, child) => TabBarView(
              children: [
                RecipeList(recipeList: recipes.items),
                ...categories.items.map((category) => RecipeList(
                    recipeList: recipes.items
                        .where(
                            (recipe) => category.recipeIds.contains(recipe.id))
                        .toList()))
              ],
            ));
  }
}
