import 'package:flutter/material.dart';
import 'package:mesrecettes/screens/categories/categories_screen.dart';
import 'package:mesrecettes/screens/create_recipe/create_recipe_screen.dart';
import 'package:mesrecettes/screens/home/home_screen.dart';
import 'package:mesrecettes/screens/settings/settings_screen.dart';

class NavItem {
  final int id;
  final String title;
  final bool replace;
  final Widget destination;

  NavItem({this.replace = true, this.id, this.destination, this.title});
}

class NavItems extends ChangeNotifier {
  int selectedIndex = 0; // Default index

  void changeNavItem({int index}) {
    selectedIndex = index;
    notifyListeners();
  }

  List<NavItem> items = [
    NavItem(id: 1, title: 'Mes Recettes', destination: HomeScreen()),
    NavItem(id: 2, title: 'Mes Catégories', destination: CategoriesScreen()),
    NavItem(
        id: 3,
        title: 'Créer une recette',
        destination: CreateRecipeScreen(),
        replace: false),
    NavItem(id: 4, title: 'Paramètres', destination: SettingsScreen())
  ];
}
