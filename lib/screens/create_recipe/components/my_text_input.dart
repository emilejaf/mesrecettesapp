import 'package:flutter/material.dart';
import 'package:mesrecettes/size_config.dart';

class MyTextInput extends StatefulWidget {
  final String labelText;
  final String text;
  final Function updateText;

  const MyTextInput({Key key, this.labelText, this.updateText, this.text})
      : super(key: key);

  @override
  _MyTextInputState createState() => _MyTextInputState();
}

class _MyTextInputState extends State<MyTextInput> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.fromPosition(
            TextPosition(offset: widget.text.length)));
    double defaultSize = SizeConfig.defaultSize;
    return Padding(
      padding: EdgeInsets.only(
        bottom: defaultSize * 0.8,
      ),
      child: TextField(
          controller: _controller,
          onChanged: widget.updateText,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            labelText: widget.labelText,
          )),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
