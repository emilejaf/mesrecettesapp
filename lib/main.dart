import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mesrecettes/components/my_scroll_behavior.dart';
import 'package:mesrecettes/helpers/dynamic_link_helper.dart';
import 'package:mesrecettes/models/category.dart';
import 'package:mesrecettes/models/nav_item.dart';
import 'package:mesrecettes/models/user.dart';
import 'package:mesrecettes/screens/home/home_screen.dart';
import 'package:mesrecettes/screens/intro/intro_screen.dart';
import 'package:mesrecettes/size_config.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'constants.dart';
import 'models/recipe.dart';

FirebaseAnalytics analytics;

void main() {
  analytics = FirebaseAnalytics();
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark));

  runApp(MyApp());
  initConsent();
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
          lazy: false,
          create: (context) => User(),
        ),
        ChangeNotifierProxyProvider<User, Recipes>(
            create: null,
            update: (context, user, previous) => Recipes(
                recipeIdsStream: user.recipeIdsStream,
                userStream: user.userStream)),
        ChangeNotifierProxyProvider<User, Categories>(
            create: null,
            update: (context, user, previous) => Categories(
                categoriesStream: user.categoriesStream,
                userStream: user.userStream)),
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
          appBarTheme: AppBarTheme(
              elevation: 0, color: Colors.white, brightness: Brightness.light),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: MyBehavior(),
            child: child,
          );
        },
        home: FutureBuilder(
          future: isSeen(),
          builder: (context, snapshot) {
            SizeConfig().init(context);
            dynamicLinkHelper.handleDynamicLinks(context);
            if (snapshot.hasData) {
              if (snapshot.data == true) {
                return HomeScreen();
              } else {
                return IntroScreen();
              }
            } else {
              return Container(
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
