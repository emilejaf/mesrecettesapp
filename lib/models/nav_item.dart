import 'package:flutter/material.dart';
import 'package:mesrecettes/screens/categories/categories_screen.dart';
import 'package:mesrecettes/screens/create_recipe/create_recipe_screen.dart';
import 'package:mesrecettes/screens/settings/settings_screen.dart';

class NavItem {
  final int id;
  final String title;
  final Widget destination;

  NavItem({this.id, this.destination, this.title});
}

class NavItems extends ChangeNotifier {
  List<NavItem> items = [
    NavItem(id: 1, title: 'Mes Catégories', destination: CategoriesScreen()),
    NavItem(
      id: 2,
      title: 'Créer une recette',
      destination: CreateRecipeScreen(),
    ),
    NavItem(
      id: 3,
      title: 'Paramètres',
      destination: SettingsScreen(),
    )
  ];
}
