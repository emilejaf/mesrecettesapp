import 'package:flutter/material.dart';
import 'package:mesrecettes/constants.dart';
import 'package:mesrecettes/models/recipe.dart';
import 'package:mesrecettes/screens/recipe/recipe_screen.dart';
import 'package:provider/provider.dart';

class Search extends SearchDelegate<Recipe> {
  @override
  String get searchFieldLabel => 'Rechercher des recettes ou des ingredients';

  @override
  TextStyle get searchFieldStyle =>
      TextStyle(color: kTextColor, fontSize: 16, fontWeight: FontWeight.w400);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  void close(BuildContext context, Recipe result) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => RecipeScreen(recipe: result)));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Recipes recipes = Provider.of<Recipes>(context, listen: false);
    List<Recipe> suggestionList = [];
    suggestionList = getRecipeList(recipes.items);
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(suggestionList[index].name),
        //leading: query.isEmpty ? Icon(Icons.access_time) : SizedBox(),
        leading: SizedBox(),
        onTap: () {
          close(context, suggestionList[index]);
        },
      ),
    );
  }

  List<Recipe> getRecipeList(List<Recipe> recipes) {
    return recipes
        .where((recipe) =>
            recipe.name.toLowerCase().contains(query.toLowerCase()) ||
            recipe.ingredients.any((ingredient) =>
                ingredient.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }
}
