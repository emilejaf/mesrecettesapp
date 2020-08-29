import 'package:flutter/material.dart';
import 'package:mesrecettes/models/category.dart';
import 'package:mesrecettes/size_config.dart';
import 'package:provider/provider.dart';

class Body extends StatelessWidget {
  final Function editCategory;

  const Body({Key key, this.editCategory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Consumer<Categories>(builder: (context, categories, child) {
      if (categories.items.length > 0) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: defaultSize * 0.6),
          child: OrientationBuilder(
            builder: (context, orientation) => GridView.builder(
              itemCount: categories.items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: orientation == Orientation.landscape ? 2 : 1,
                  mainAxisSpacing: SizeConfig.defaultSize * 0.3,
                  childAspectRatio: 5,
                  crossAxisSpacing: orientation == Orientation.landscape
                      ? SizeConfig.defaultSize * 2
                      : 0),
              itemBuilder: (context, index) {
                Category category = categories.items[index];
                return buildCategoryCard(
                    title: category.name,
                    deleteCategory: () =>
                        {categories.deleteCategory(category.id, category.sync)},
                    editCategory: () => editCategory(category));
              },
            ),
          ),
        );
      } else {
        return Container();
      }
    });
  }

  Widget buildCategoryCard(
      {String title, Function deleteCategory, Function editCategory}) {
    double defaultSize = SizeConfig.defaultSize;
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultSize * 0.4)),
        child: ListTile(
          title: Text(title),
          trailing: Wrap(
            children: [
              InkWell(
                child: Padding(
                  padding: EdgeInsets.all(defaultSize * 0.5),
                  child: Icon(Icons.edit),
                ),
                onTap: editCategory,
              ),
              InkWell(
                  child: Padding(
                    padding: EdgeInsets.all(defaultSize * 0.5),
                    child: Icon(Icons.delete),
                  ),
                  onTap: deleteCategory)
            ],
          ),
        ),
      ),
    );
  }
}
