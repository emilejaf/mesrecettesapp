import 'package:flutter/material.dart';
import 'package:mesrecettes/models/category.dart';
import 'package:mesrecettes/screens/categories/components/body.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Mes Catégories')),
      resizeToAvoidBottomInset: false,
      body: Body(
        editCategory: (Category category) {
          _showCreateDialog(context, edit: category);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateDialog(context);
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }

  _showCreateDialog(BuildContext context, {Category edit}) async {
    final _formKey = GlobalKey<FormState>();
    if (edit != null) {
      _controller.text = edit.name;
    } else {
      _controller.clear();
    }
    await showDialog<String>(
        context: context,
        child: Form(
          key: _formKey,
          child: AlertDialog(
            contentPadding: EdgeInsets.all(16),
            content: TextFormField(
              controller: _controller,
              autofocus: true,
              decoration: new InputDecoration(labelText: 'Nom de la catégorie'),
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'Un nom est requis';
                } else {
                  return null;
                }
              },
            ),
            actions: [
              FlatButton(
                child: Text(
                  'Annuler',
                  style: Theme.of(context).accentTextTheme.button,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(
                  'Terminer',
                  style: Theme.of(context).accentTextTheme.button,
                ),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    Categories categories =
                        Provider.of<Categories>(context, listen: false);
                    if (edit != null) {
                      String oldId = edit.id;
                      edit.name = _controller.text;
                      edit.id = Uuid().v4();
                      categories.editCategory(oldId, edit);
                    } else {
                      Category category = new Category(
                          name: _controller.text,
                          recipeIds: [],
                          id: Uuid().v4());
                      categories.addCategory(category);
                    }
                    Navigator.pop(context);
                  }
                },
              )
            ],
          ),
        ));
  }
}
