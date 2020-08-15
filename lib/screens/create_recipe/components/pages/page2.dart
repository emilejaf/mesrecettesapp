import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mesrecettes/models/category.dart';
import 'package:provider/provider.dart';

class Page2 extends StatefulWidget {
  final StreamController controller;
  final List<Category> defaultCategories;

  const Page2({Key key, this.controller, this.defaultCategories})
      : super(key: key);

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  List<Category> selectedCategories;

  @override
  void initState() {
    super.initState();
    selectedCategories = widget.defaultCategories;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Categories>(
      builder: (context, categories, child) => ListView.builder(
          shrinkWrap: true,
          itemCount: categories.items.length,
          itemBuilder: (context, index) {
            Category category = categories.items[index];
            return Center(
              child: CheckboxListTile(
                value: selectedCategories.contains(category),
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      selectedCategories.add(category);
                    } else {
                      selectedCategories.remove(category);
                    }
                    widget.controller.add(selectedCategories);
                  });
                },
                title: Text(category.name),
              ),
            );
          }),
    );
  }
}
