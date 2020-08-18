import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mesrecettes/models/category.dart';
import 'package:mesrecettes/models/recipe.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            RaisedButton(
              child: Text(
                'Importer les recettes',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => importRecipe(context),
            ),
            RaisedButton(
              child: Text(
                'Exporter les recettes',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => exportRecipe(context),
            )
          ],
        ),
      ],
    );
  }

  void importRecipe(BuildContext context) async {
    final String path = (await getExternalStorageDirectory()).path;
    final File dataFile = File(join(path, 'data.json'));
    String json = await dataFile.readAsString();

    final data = (jsonDecode(json));
    //print(data['categories']);

    final Recipes recipes = Provider.of<Recipes>(context, listen: false);

    final List recipesList = data['recipes'];
    recipesList.forEach((recipeData) {
      Recipe recipe = Recipe(
          id: recipeData['id'] ?? Uuid().v4(),
          name: recipeData['name'] ?? '',
          cookTime: recipeData['cookTime'] ?? '',
          prepTime: recipeData['prepTime'] ?? '',
          people: recipeData['people'] ?? '',
          hasImage: recipeData['hasImage'] ?? false,
          ingredients: recipeData['ingredients'].cast<String>() ?? [],
          steps: recipeData['steps'].cast<String>() ?? [],
          notes: recipeData['notes'] ?? '');
      recipes.addRecipe(recipe);
    });

    final Categories categories =
        Provider.of<Categories>(context, listen: false);
    final List categoriesList = data['categories'];
    categoriesList.forEach((categoryData) {
      Category category;
      if (categoryData is Map) {
        category = Category(
            name: categoryData['name'] ?? '',
            recipeIds: categoryData['recipeIds'] ?? []);
      } else if (categoryData is String) {
        category = Category(name: categoryData, recipeIds: []);
      }
      categories.addCategory(category);
    });
  }

  void exportRecipe(BuildContext context) async {
    final Recipes recipes = Provider.of<Recipes>(context, listen: false);
    final Categories categories =
        Provider.of<Categories>(context, listen: false);

    Map obj = {
      'recipes': recipes.items
          .map((recipe) => {
                'id': recipe.id,
                'name': recipe.name,
                'cookTime': recipe.cookTime,
                'prepTime': recipe.prepTime,
                'people': recipe.people,
                'hasImage': recipe.hasImage,
                'ingredients': recipe.ingredients,
                'steps': recipe.steps,
                'notes': recipe.notes
              })
          .toList(),
      'categories': categories.items
          .map((category) =>
              {'name': category.name, 'recipeIds': category.recipeIds})
          .toList()
    };

    String data = jsonEncode(obj);

    final String path = (await getExternalStorageDirectory()).path;
    final File dataFile = File(join(path, 'data.json'));

    dataFile.writeAsString(data);
  }
}
