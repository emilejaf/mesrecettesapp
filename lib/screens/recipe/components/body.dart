import 'package:flutter/material.dart';
import 'package:mesrecettes/models/recipe.dart';
import 'package:mesrecettes/screens/recipe/components/recipe_expansion_panel.dart';
import 'package:mesrecettes/screens/recipe/components/recipe_informations.dart';
import 'package:mesrecettes/screens/recipe/components/recipe_preview.dart';
import 'package:mesrecettes/screens/recipe/components/start_recipe_dialog.dart';
import 'package:mesrecettes/size_config.dart';

class Body extends StatelessWidget {
  final Recipe recipe;

  Body(this.recipe);

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: defaultSize * 0.6),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            RecipePreview(
              name: recipe.name,
              hasImage: recipe.hasImage,
              path: recipe.path,
            ),
            SizedBox(height: defaultSize * 0.6),
            RecipeInformation(
              cookTime: recipe.cookTime,
              prepTime: recipe.prepTime,
              people: recipe.people,
            ),
            SizedBox(height: defaultSize * 0.6),
            RecipeExpansionPanel(
              ingredients: recipe.ingredients,
              steps: recipe.steps,
              notes: recipe.notes,
            ),
            SizedBox(height: defaultSize * 0.6),
            if (recipe.steps.length > 0)
              FlatButton(
                onPressed: () => _showStartRecipeDialog(context, recipe.steps),
                color: Theme.of(context).buttonColor,
                child: Text(
                  'Démarrer la recette',
                  style: Theme.of(context)
                      .textTheme
                      .button
                      .copyWith(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _showStartRecipeDialog(BuildContext context, List<String> steps) async {
    await showDialog(
        context: context,
        child: StartRecipeDialog(
          steps: steps,
        ));
  }
}
