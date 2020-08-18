import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mesrecettes/models/category.dart';
import 'package:mesrecettes/models/recipe.dart';
import 'package:mesrecettes/screens/recipe/recipe_screen.dart';
import 'package:mesrecettes/size_config.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:mesrecettes/constants.dart';

import 'pages/page1.dart';
import 'pages/page2.dart';
import 'pages/page3.dart';
import 'pages/page4.dart';
import 'pages/page5.dart';

class Page {
  final String title;
  final Widget body;

  Page({this.title, this.body});
}

class Body extends StatefulWidget {
  final Recipe edit;
  final List<Category> defaultSelectedCategories;

  const Body({Key key, this.edit, this.defaultSelectedCategories})
      : super(key: key);
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final InterstitialAd _interstitialAd = InterstitialAd(
      adUnitId: 'ca-app-pub-8850562463084333/2453919785',
      targetingInfo: getTargetingInfo());
  // ignore: close_sinks
  final StreamController<List<Category>> selectedCategoriesController =
      StreamController();

  StreamSubscription _streamSubscription;

  final PageController _controller = PageController(viewportFraction: 0.8);
  final Duration duration = Duration(milliseconds: 500);
  final Curve curve = Curves.easeOutQuint;

  bool isEditing;

  int currentPage = 0;

  // Recipe values
  // Page 1
  String recipeName, cookTime, prepTime, people;
  //Page 2
  List<Category> selectedCategories;
  // Page 3
  File image;
  // Page 4
  List<String> ingredients;
  List<String> steps;
  // Page 5
  String notes;

  @override
  void initState() {
    super.initState();

    _interstitialAd.load();

    _controller.addListener(() {
      int next = _controller.page.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });

    _streamSubscription = selectedCategoriesController.stream.listen((value) {
      selectedCategories = value;
    });

    isEditing = widget.edit != null ? true : false;

    recipeName = isEditing ? widget.edit.name : '';
    cookTime = isEditing ? widget.edit.cookTime : '';
    prepTime = isEditing ? widget.edit.prepTime : '';
    people = isEditing ? widget.edit.people : '';

    selectedCategories = isEditing ? [...widget.defaultSelectedCategories] : [];

    image = widget.edit != null
        ? widget.edit.hasImage ? File(widget.edit.path) : null
        : null;

    ingredients = isEditing ? widget.edit.ingredients : [''];
    steps = isEditing ? widget.edit.steps : [''];
    notes = isEditing ? widget.edit.notes : '';
  }

  @override
  void dispose() {
    _controller.dispose();
    _streamSubscription.cancel();
    _interstitialAd.dispose();
    super.dispose();
  }

  void leftPress(bool isFirst) {
    if (isFirst) {
      Navigator.pop(this.context);
    } else {
      setState(() {
        currentPage = currentPage - 1;
      });
      _controller.animateToPage(currentPage, duration: duration, curve: curve);
    }
  }

  void rightPress(bool isLast) async {
    if (isLast) {
      //show ad
      if (await _interstitialAd.isLoaded()) {
        _interstitialAd.show();
      }

      final String id = isEditing ? widget.edit.id : Uuid().v4();
      String path;
      // Save photo
      if (image != null) {
        final String appPath = (await getApplicationDocumentsDirectory()).path;
        path = join(appPath, '$id.jpg');
        if (widget.edit != null &&
            widget.edit.hasImage &&
            widget.edit.path != image.path) {
          // delete phto
          await File(path).delete();
        }
        // save photo
        if (image.path != path) {
          imageCache.clear();
          image.copy(path);
        }
      }
      // Add recipe
      Recipe recipe = new Recipe(
          id: id,
          path: path ?? '',
          hasImage: image != null ? true : false,
          name: recipeName,
          prepTime: prepTime,
          cookTime: cookTime,
          people: people,
          ingredients:
              ingredients.where((ingredient) => ingredient != '').toList(),
          steps: steps.where((step) => step != '').toList(),
          notes: notes);

      Recipes recipes = Provider.of<Recipes>(this.context, listen: false);

      if (isEditing) {
        recipes.editRecipe(recipe);
      } else {
        recipes.addRecipe(recipe);
      }
      // Add recipe to selected categories
      Categories categories =
          Provider.of<Categories>(this.context, listen: false);

      if (isEditing) {
        if (widget.defaultSelectedCategories != selectedCategories) {
          await categories.removeRecipeId(id);
          categories.addRecipeId(selectedCategories, id);
        }
      } else {
        categories.addRecipeId(selectedCategories, id);
      }

      Navigator.pop(this.context);
      if (isEditing) {
        Navigator.pushReplacement(
            this.context,
            MaterialPageRoute(
              builder: (context) => RecipeScreen(
                recipe: recipe,
              ),
            ));
      }
    } else {
      setState(() {
        currentPage = currentPage + 1;
      });
      _controller.animateToPage(
        currentPage,
        duration: duration,
        curve: curve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Page> pages = [
      Page(
          title: 'Informations Principales',
          body: Page1(
            //Recipe name
            callbackRecipeName: (value) => {recipeName = value},
            name: recipeName,
            // PrepTime
            callbackPrepTime: (value) => {prepTime = value},
            prepTime: prepTime,
            // CookTime
            callbackCookTime: (value) => {cookTime = value},
            cookTime: cookTime,
            // People
            callbackPeople: (value) => {people = value},
            people: people,
          )),
      if (Provider.of<Categories>(context, listen: false).items.length > 0)
        Page(
            title: 'Catégories',
            body: Page2(
              controller: selectedCategoriesController,
              defaultCategories: selectedCategories,
            )),
      Page(
          title: 'Photo de la recette',
          body: Page3(
            image: image,
            callback: (File newImage) {
              setState(() {
                image = newImage;
              });
            },
          )),
      Page(
        title: 'Ingrédients',
        body: Page4(
          listItem: ingredients,
          buttonText: 'Ajouter un ingrédient',
          labelText: 'Ingrédient',
          callback: (List<String> list) => ingredients = list,
        ),
      ),
      Page(
        title: 'Étapes',
        body: Page4(
          listItem: steps,
          buttonText: 'Ajouter une etape',
          labelText: 'Étape',
          callback: (List<String> list) => steps = list,
        ),
      ),
      Page(
          title: 'Notes',
          body: Page5(
            notes: notes,
            callback: (String value) {
              notes = value;
            },
          ))
    ];
    return PageView.builder(
      controller: _controller,
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final bool active = currentPage == index;
        final Page page = pages[index];
        final bool isFirst = index == 0;
        final bool isLast = index == pages.length - 1;
        final double blur = active ? 20 : 0;
        final double offset = active ? 5 : 0;
        final double top = active ? 25 : 100;
        final String leftText = isFirst ? 'Annuler' : 'Retour';
        final String rightText = isLast ? 'Terminer' : 'Suivant';

        return AnimatedContainer(
          duration: duration,
          curve: curve,
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.only(top: top, bottom: 25, right: 30),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black87,
                    blurRadius: blur,
                    offset: Offset(offset, offset))
              ]),
          child: Column(
            children: [
              Container(
                alignment: Alignment.bottomCenter,
                height: SizeConfig.orientation == Orientation.portrait
                    ? SizeConfig.defaultSize * 6
                    : SizeConfig.defaultSize * 2.5,
                child: Text(
                  page.title,
                  style: TextStyle(fontSize: SizeConfig.defaultSize * 2),
                ),
              ),
              Expanded(child: Center(child: page.body)),
              BottomButtons(
                leftText: leftText,
                leftPress: () => leftPress(isFirst),
                rightText: rightText,
                rightPress: () => rightPress(isLast),
              )
            ],
          ),
        );
      },
    );
  }
}

class BottomButtons extends StatelessWidget {
  final String rightText, leftText;
  final Function rightPress, leftPress;

  const BottomButtons({
    Key key,
    this.rightText,
    this.leftText,
    this.rightPress,
    this.leftPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FlatButton(
          child: Text(leftText),
          onPressed: leftPress,
        ),
        FlatButton(
          child: Text(rightText),
          onPressed: rightPress,
        )
      ],
    );
  }
}
