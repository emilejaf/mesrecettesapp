import 'package:flutter/material.dart';
import 'package:mesrecettes/screens/create_recipe/components/my_text_input.dart';
import 'package:mesrecettes/size_config.dart';

class Page4 extends StatefulWidget {
  final String buttonText;
  final String labelText;
  final List<String> listItem;
  final Function callback;

  const Page4(
      {Key key, this.callback, this.buttonText, this.labelText, this.listItem})
      : super(key: key);

  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  void notifyParent() {
    widget.callback(widget.listItem);
  }

  void remove(int index) {
    setState(() {
      widget.listItem.removeAt(index);
    });
    notifyParent();
  }

  void addItem() {
    setState(() {
      widget.listItem.add('');
    });
    notifyParent();
  }

  void updateText(int index, String text) {
    widget.listItem[index] = text;
    notifyParent();
  }

  void updateListOrder(int oldIndex, int newIndex) {
    setState(() {
      widget.listItem.insert(newIndex, widget.listItem.removeAt(oldIndex));
    });
    notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ReorderableListView(
              scrollController: _scrollController,
              scrollDirection: Axis.vertical,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                updateListOrder(oldIndex, newIndex);
              },
              children: widget.listItem.asMap().entries.map((entry) {
                int index = entry.key;
                String text = entry.value;
                return buildItem(index, text);
              }).toList()),
        ),
        FlatButton(
          color: Theme.of(context).accentColor,
          child: Text(widget.buttonText),
          onPressed: addItem,
        )
      ],
    );
  }

  Widget buildItem(int index, String text) {
    return Card(
      key: Key(index.toString() + widget.labelText),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.defaultSize),
        child: Row(
          children: [
            Expanded(
              child: MyTextInput(
                  labelText: widget.labelText + ' ' + (index + 1).toString(),
                  updateText: (String text) => updateText(index, text),
                  text: text),
            ),
            InkWell(child: Icon(Icons.delete), onTap: () => remove(index)),
          ],
        ),
      ),
    );
  }
}
