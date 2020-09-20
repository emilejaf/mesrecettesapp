import 'package:flutter/material.dart';
import 'package:mesrecettes/size_config.dart';

class Page4 extends StatefulWidget {
  final String buttonText;
  final String itemName;
  final List<String> listItem;
  final Function callback;

  const Page4(
      {Key key, this.callback, this.buttonText, this.listItem, this.itemName})
      : super(key: key);

  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  ScrollController _scrollController;
  TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _editingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _editingController = TextEditingController();
  }

  void notifyParent() {
    widget.callback(widget.listItem);
  }

  void removeItem(int index) {
    setState(() {
      widget.listItem.removeAt(index);
    });
    notifyParent();
  }

  void addItem(String text) {
    setState(() {
      widget.listItem.add(text);
    });
    notifyParent();
  }

  void editItem(int index, String text) {
    setState(() {
      widget.listItem[index] = text;
    });
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
        Padding(
          padding: EdgeInsets.only(bottom: SizeConfig.defaultSize * 2),
          child: FlatButton(
            color: Theme.of(context).accentColor,
            child: Text(
              widget.buttonText,
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => showItemDialog(),
          ),
        )
      ],
    );
  }

  Widget buildItem(int index, String text) {
    return Card(
      key: Key(index.toString() + widget.itemName),
      child: ListTile(
        title: Text(
          text,
          style: TextStyle(color: Colors.black),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
                child: Icon(Icons.edit),
                onTap: () => showItemDialog(oldText: text, index: index)),
            InkWell(
              child: Icon(Icons.delete),
              onTap: () => removeItem(index),
            )
          ],
        ),
      ),
    );
  }

  showItemDialog({String oldText, int index}) async {
    final _formKey = GlobalKey<FormState>();
    if (oldText == null) {
      _editingController.clear();
    } else {
      _editingController.text = oldText;
    }

    showDialog(
        context: context,
        child: Form(
          key: _formKey,
          child: AlertDialog(
            content: TextFormField(
              controller: _editingController,
              autofocus: true,
              decoration:
                  new InputDecoration(labelText: "Nom de l'" + widget.itemName),
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
                    if (oldText != null) {
                      editItem(index, _editingController.text);
                    } else {
                      addItem(_editingController.text);
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
