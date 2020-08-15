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
    setState(() {
      widget.listItem[index] = text;
    });
    notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
              itemCount: widget.listItem.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.defaultSize),
                    child: Row(
                      children: [
                        Expanded(
                          child: MyTextInput(
                              labelText: widget.labelText +
                                  ' ' +
                                  (index + 1).toString(),
                              updateText: (String text) =>
                                  updateText(index, text),
                              text: widget.listItem[index]),
                        ),
                        InkWell(
                            child: Icon(Icons.delete),
                            onTap: () => remove(index)),
                      ],
                    ),
                  ),
                );
              }),
        ),
        FlatButton(
          color: Theme.of(context).accentColor,
          child: Text(widget.buttonText),
          onPressed: addItem,
        )
      ],
    );
  }
}
