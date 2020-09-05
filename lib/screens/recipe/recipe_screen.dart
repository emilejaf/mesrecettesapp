import 'package:flutter/material.dart';
import 'package:mesrecettes/helpers/dynamic_link_helper.dart';
import 'package:mesrecettes/models/category.dart';
import 'package:mesrecettes/models/recipe.dart';
import 'package:mesrecettes/models/user.dart';
import 'package:mesrecettes/screens/create_recipe/create_recipe_screen.dart';
import 'package:mesrecettes/screens/recipe/components/body.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class RecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeScreen({Key key, this.recipe}) : super(key: key);

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void removeRecipe() async {
    Categories categories = Provider.of<Categories>(context, listen: false);
    await categories.removeRecipeId(widget.recipe.id);
    Provider.of<Recipes>(context, listen: false).deleteRecipe(widget.recipe,
        categories: categories.serverCategories != null
            ? categories.serverCategories.toList()
            : null,
        callback: () => {categories.syncCategories(categories.items)});
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void editRecipe() {
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateRecipeScreen(
                  edit: widget.recipe,
                  defaultSelectedCategories:
                      Provider.of<Categories>(context, listen: false)
                          .getCategoriesByRecipeId(widget.recipe.id),
                )));
  }

  void shareRecipe() async {
    User user = Provider.of<User>(context, listen: false);

    if (user.isAuthenticated() && widget.recipe.sync) {
      String recipeId = widget.recipe.id;

      String link = await dynamicLinkHelper.createRecipeLink(recipeId);

      Navigator.pop(context);
      Share.share('Découvre ma recette ' + widget.recipe.name + ' ici : $link');
    } else {
      Navigator.pop(context);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Vous devez être connecté pour partager une recette'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => openBottomSheet(context),
            )
          ],
        ),
        body: Body(widget.recipe));
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
                leading: Icon(Icons.share),
                title: Text('Partager'),
                onTap: () => shareRecipe(),
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Modifier'),
                onTap: () => editRecipe(),
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Supprimer'),
                onTap: () => removeRecipe(),
              )
            ],
          ),
        );
      },
    );
  }
}
