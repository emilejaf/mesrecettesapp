import 'package:flutter/material.dart';

class Page1 extends StatefulWidget {
  final Function callbackRecipeName;
  final String name;
  final Function callbackPrepTime;
  final String prepTime;
  final Function callbackCookTime;
  final String cookTime;
  final Function callbackPeople;
  final String people;
  const Page1({
    Key key,
    this.callbackRecipeName,
    this.callbackPrepTime,
    this.callbackCookTime,
    this.callbackPeople,
    this.name,
    this.prepTime,
    this.cookTime,
    this.people,
  }) : super(key: key);

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  TextEditingController _nameController;
  TextEditingController _prepTimeController;
  TextEditingController _cookTimeController;
  TextEditingController _peopleController;

  @override
  void initState() {
    _nameController = TextEditingController();
    _nameController.text = widget.name;

    _prepTimeController = TextEditingController();
    _prepTimeController.text = widget.prepTime;

    _cookTimeController = TextEditingController();
    _cookTimeController.text = widget.cookTime;

    _peopleController = TextEditingController();
    _peopleController.text = widget.people;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.sentences,
          onChanged: widget.callbackRecipeName,
          decoration: InputDecoration(labelText: ('Nom de recette')),
        ),
        TextField(
          controller: _prepTimeController,
          onChanged: widget.callbackPrepTime,
          decoration: InputDecoration(labelText: ('Temps de préparation')),
        ),
        TextField(
          controller: _cookTimeController,
          onChanged: widget.callbackCookTime,
          decoration: InputDecoration(labelText: ('Temps de cuisson')),
        ),
        TextField(
          controller: _peopleController,
          onChanged: (value) => {widget.callbackPeople(value)},
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: ('Nombre de personnes')),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _peopleController.dispose();
    super.dispose();
  }
}
