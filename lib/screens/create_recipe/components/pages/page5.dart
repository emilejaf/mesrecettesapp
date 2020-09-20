import 'package:flutter/material.dart';
import 'package:mesrecettes/size_config.dart';

class Page5 extends StatefulWidget {
  final Function callback;
  final String notes;

  const Page5({Key key, this.callback, this.notes}) : super(key: key);

  @override
  _Page5State createState() => _Page5State();
}

class _Page5State extends State<Page5> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = widget.notes;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.defaultSize),
          child: TextField(
            controller: _controller,
            onChanged: widget.callback,
            decoration: InputDecoration(
                hintText: 'Entrer vos notes ici', border: InputBorder.none),
            maxLines: 8,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
