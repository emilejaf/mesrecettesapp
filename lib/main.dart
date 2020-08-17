import 'package:flutter/material.dart';
import 'package:mesrecettes/models/category.dart';
import 'package:mesrecettes/models/nav_item.dart';
import 'package:mesrecettes/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

import 'models/recipe.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NavItems(),
        ),
        ChangeNotifierProvider(
          create: (context) => Recipes(),
        ),
        ChangeNotifierProvider(
          create: (context) => Categories(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MesRecettes',
        theme: ThemeData(
          buttonColor: Colors.lightGreen,
          primaryIconTheme: IconThemeData(color: Colors.black),
          primaryTextTheme: Typography.blackCupertino,
          accentTextTheme:
              TextTheme(button: TextStyle(color: Colors.lightGreen)),
          brightness: Brightness.light,
          primaryColor: Colors.black,
          accentColor: Colors.lightGreen,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(elevation: 0, color: Colors.white),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
