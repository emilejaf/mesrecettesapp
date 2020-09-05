import 'package:flutter/material.dart';

class MyTextInput extends StatefulWidget {
  final String labelText;
  final String text;
  final Function onRemove;
  final Function updateText;

  const MyTextInput(
      {Key key, this.labelText, this.updateText, this.text, this.onRemove})
      : super(key: key);

  @override
  _MyTextInputState createState() => _MyTextInputState();
}

class _MyTextInputState extends State<MyTextInput> {
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode;
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    _controller.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.fromPosition(
            TextPosition(offset: widget.text.length)));
    return Card(
      child: ListTile(
        title: TextField(
          enabled: _isEnabled,
          focusNode: _focusNode,
          controller: _controller,
          textCapitalization: TextCapitalization.sentences,
          onChanged: widget.updateText,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            labelText: widget.labelText,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              child: new Icon(
                _isEnabled ? Icons.check : Icons.edit,
                color: Colors.black,
              ),
              onTap: () {
                setState(() {
                  _isEnabled = !_isEnabled;
                });
                if (_isEnabled) {
                  _focusNode.requestFocus();
                } else {
                  _focusNode.unfocus();
                }
              },
            ),
            GestureDetector(
              child: new Icon(
                Icons.delete,
                color: Colors.black,
              ),
              onTap: () => widget.onRemove(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}
