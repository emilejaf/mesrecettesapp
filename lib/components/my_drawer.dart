import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mesrecettes/constants.dart';
import 'package:mesrecettes/models/nav_item.dart';
import 'package:mesrecettes/size_config.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  int selectedIndex = 0;
  Map<String, Widget> routes = new HashMap();

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Consumer<NavItems>(
      builder: (context, navItems, child) => new Drawer(
        child: ListTileTheme(
          selectedColor: kPrimaryColor,
          child: ListView(
            children: <Widget>[
                  new DrawerHeader(
                      child: Center(
                    child: Container(
                      margin: EdgeInsets.only(bottom: defaultSize),
                      height: defaultSize * 10,
                      width: defaultSize * 10,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/icons/app.png'))),
                    ),
                  )),
                ] +
                List.generate(navItems.items.length, (index) {
                  NavItem navitem = navItems.items[index];
                  return buildNavigationTile(context,
                      title: navitem.title,
                      isActive: navItems.selectedIndex == index ? true : false,
                      press: () {
                    if (navItems.selectedIndex != index) {
                      if (navitem.replace) {
                        navItems.changeNavItem(index: index);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => navitem.destination));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => navitem.destination));
                      }
                    } else {
                      Navigator.pop(context);
                    }
                  });
                }),
          ),
        ),
      ),
    );
  }

  ListTile buildNavigationTile(BuildContext context,
      {String title, bool isActive = false, Function press}) {
    return new ListTile(
        title: Text(title),
        onTap: press,
        trailing: Icon(Icons.chevron_right),
        selected: isActive);
  }
}
