import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mesrecettes/models/category.dart';
import 'package:mesrecettes/models/recipe.dart';
import 'package:mesrecettes/screens/create_recipe/components/body.dart';

class CreateRecipeScreen extends StatefulWidget {
  final Recipe edit;
  final List<Category> defaultSelectedCategories;

  const CreateRecipeScreen({Key key, this.edit, this.defaultSelectedCategories})
      : super(key: key);

  @override
  _CreateRecipeScreenState createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une recette'),
      ),
      body: Body(
        edit: widget.edit,
        defaultSelectedCategories: widget.defaultSelectedCategories,
      ),
    );
  }
}
