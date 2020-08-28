import 'package:flutter/material.dart';
import 'package:mesrecettes/models/category.dart';
import 'package:mesrecettes/models/recipe.dart';
import 'package:mesrecettes/screens/create_recipe/create_recipe_screen.dart';
import 'package:mesrecettes/screens/recipe/components/body.dart';
import 'package:provider/provider.dart';

class RecipeScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeScreen({Key key, this.recipe}) : super(key: key);

  void removeRecipe(BuildContext context, Recipe recipe) async {
    Categories categories = Provider.of<Categories>(context, listen: false);
    await categories.removeRecipeId(recipe.id);
    Provider.of<Recipes>(context, listen: false).deleteRecipe(recipe,
        categories: categories.serverCategories != null
            ? categories.serverCategories.toList()
            : null);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void editRecipe(BuildContext context, Recipe recipe) {
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateRecipeScreen(
                  edit: recipe,
                  defaultSelectedCategories:
                      Provider.of<Categories>(context, listen: false)
                          .getCategoriesByRecipeId(recipe.id),
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => openBottomSheet(context),
            )
          ],
        ),
        body: Body(recipe));
  }

  void openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Modifier'),
                onTap: () => editRecipe(context, recipe),
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Supprimer'),
                onTap: () => removeRecipe(context, recipe),
              )
            ],
          ),
        );
      },
    );
  }
}
