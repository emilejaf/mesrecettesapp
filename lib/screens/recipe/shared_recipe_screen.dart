import 'package:flutter/material.dart';
import 'package:mesrecettes/helpers/firestore_helper.dart';
import 'package:mesrecettes/models/recipe.dart';
import 'package:mesrecettes/screens/recipe/components/recipe_preview.dart';
import 'package:mesrecettes/screens/recipe/recipe_screen.dart';
import 'package:mesrecettes/size_config.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'components/recipe_expansion_panel.dart';
import 'components/recipe_informations.dart';
import 'components/start_recipe_dialog.dart';

class SharedRecipeScreen extends StatelessWidget {
  final String recipeId;

  const SharedRecipeScreen({Key key, this.recipeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Body(
        recipeId: recipeId,
      ),
    );
  }
}

class Body extends StatelessWidget {
  final String recipeId;

  const Body({Key key, this.recipeId}) : super(key: key);

  Future<Recipe> getRecipe() async {
    final map = await fireStoreHelper.getRecipe(recipeId);
    Recipe recipe = fromMap(map, sqlFormat: false, appPath: '');
    recipe.path = await fireStoreHelper.getFilePath(recipeId + '.jpg');
    return recipe;
  }

  Future<void> saveRecipe(BuildContext context, Recipe recipe) async {
    String oldRecipeId = recipe.id;
    recipe.id = Uuid().v4();
    recipe.sync = false;

    if (recipe.hasImage) {
      //save recipe image
      final String appPath = (await getApplicationDocumentsDirectory()).path;
      recipe.path = join(appPath, recipe.id + '.jpg');
      await fireStoreHelper.downloadFile(oldRecipeId + '.jpg', recipe.path);
    }

    Provider.of<Recipes>(context, listen: false).addRecipe(recipe);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return RecipeScreen(
        recipe: recipe,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getRecipe(),
      builder: (context, AsyncSnapshot<Recipe> snapshot) {
        if (snapshot.hasData) {
          return buildRecipe(context, snapshot.data);
        } else if (snapshot.hasError) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ],
          );
        } else {
          return Center(
            child: SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
          );
        }
      },
    );
  }

  Padding buildRecipe(BuildContext context, Recipe recipe) {
    double defaultSize = SizeConfig.defaultSize;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: defaultSize * 0.6),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  RecipePreview(
                    name: recipe.name,
                    hasImage: recipe.hasImage,
                    path: recipe.path,
                    localImage: false,
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
                      onPressed: () =>
                          _showStartRecipeDialog(context, recipe.steps),
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
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: SaveButton(callback: () => saveRecipe(context, recipe)),
          ),
        ],
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

class SaveButton extends StatefulWidget {
  final Function callback;

  const SaveButton({
    Key key,
    this.callback,
  }) : super(key: key);

  @override
  _SaveButtonState createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        widget.callback();
        setState(() {
          _loading = true;
        });
      },
      color: Theme.of(context).buttonColor,
      child: buildButtonChild(context),
    );
  }

  Widget buildButtonChild(BuildContext context) {
    if (_loading) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else {
      return Text(
        'Enregister la recette',
        style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),
      );
    }
  }
}
