import 'package:flutter/material.dart';
import 'package:mesrecettes/size_config.dart';

class Item {
  String title;
  String emptyText;
  List<String> list;
  String value;

  Item({this.title, this.list, this.value, this.emptyText});
}

class RecipeExpansionPanel extends StatefulWidget {
  final List<String> ingredients, steps;
  final String notes;

  const RecipeExpansionPanel(
      {Key key, this.ingredients, this.steps, this.notes})
      : super(key: key);

  @override
  _RecipeExpansionPanelState createState() => _RecipeExpansionPanelState();
}

class _RecipeExpansionPanelState extends State<RecipeExpansionPanel> {
  List<Item> _data;

  @override
  void initState() {
    super.initState();
    _data = [
      new Item(
          title: 'Ingrédients',
          emptyText: 'Aucun ingrédient',
          list: widget.ingredients),
      new Item(title: 'Étapes', emptyText: 'Aucune étape', list: widget.steps),
      new Item(title: 'Notes', emptyText: 'Aucune note', value: widget.notes)
    ];
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultSize * 0.4)),
      child: buildExpansionPanelList(),
    );
  }

  ExpansionPanelList buildExpansionPanelList() {
    return ExpansionPanelList.radio(
      animationDuration: Duration(milliseconds: 250),
      children: _data.map<ExpansionPanelRadio>((Item item) {
        return ExpansionPanelRadio(
          value: _data.indexOf(item),
          headerBuilder: (context, isExpanded) {
            return ListTile(title: Text(item.title));
          },
          body: buildItem(item),
        );
      }).toList(),
    );
  }

  ListTile buildItem(Item item) {
    if (item.list != null && item.list.length > 0) {
      return ListTile(
        title: Column(
            children: item.list
                .map(
                  (text) => Row(
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(fontSize: 30),
                      ),
                      Text(text)
                    ],
                  ),
                )
                .toList()),
      );
    } else if (item.value != null && item.value != '') {
      return ListTile(
        title: Text(item.value),
      );
    } else {
      return ListTile(
        title: Center(child: Text(item.emptyText)),
      );
    }
  }
}
