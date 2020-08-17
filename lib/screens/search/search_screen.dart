import 'package:flutter/material.dart';
import 'package:mesrecettes/screens/search/components/body.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller;
  String searchedText = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: (value) {
            setState(() {
              searchedText = value;
            });
          },
          decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => _controller.clear(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(style: BorderStyle.none, width: 0),
              ),
              hintText: 'Rechercher une recette ou un ingrédient',
              hintStyle: TextStyle(fontSize: 14),
              filled: true),
        ),
      ),
      body: Body(
        searchedText: searchedText,
      ),
    );
  }
}
