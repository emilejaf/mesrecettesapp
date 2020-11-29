import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mesrecettes/components/my_drawer.dart';
import 'package:mesrecettes/constants.dart';
import 'package:mesrecettes/helpers/dynamic_link_helper.dart';
import 'package:mesrecettes/models/category.dart';
import 'package:mesrecettes/models/user.dart';
import 'package:mesrecettes/screens/account/login/login_screen.dart';
import 'package:mesrecettes/screens/account/profile/profile_screen.dart';
import 'package:mesrecettes/screens/create_recipe/create_recipe_screen.dart';
import 'package:mesrecettes/screens/home/components/body.dart';
import 'package:mesrecettes/screens/home/components/search.dart';
import 'package:mesrecettes/size_config.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    dynamicLinkHelper.handleDynamicLinks(context);
    return Consumer<Categories>(
      builder: (context, categories, child) => DefaultTabController(
        length: categories.items.length + 1,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Padding(
              padding: EdgeInsets.only(top: 6),
              child: _appBar(context),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: Theme(
                data: ThemeData(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent),
                child: TabBar(
                  isScrollable: true,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black.withOpacity(0.3),
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: [
                    Tab(
                      text: 'Tout',
                    ),
                    ...categories.items
                        .map((category) => Tab(
                              text: category.name,
                            ))
                        .toList()
                  ],
                ),
              ),
            ),
          ),
          body: Body(),
          drawer: MyDrawer(),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateRecipeScreen()));
            },
          ),
        ),
      ),
    );
  }
}

Widget _appBar(BuildContext context) {
  return Builder(
    builder: (context) => Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 0.5,
                blurRadius: 1,
                offset: Offset(0, 1))
          ]),
      child: Row(
        children: [
          IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: Icon(Icons.menu),
            color: kTextColor,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          Expanded(
            child: GestureDetector(
              child: Text(
                'Rechercher des recettes ou des ingredients',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: kTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
              onTap: () {
                showSearch(context: context, delegate: Search());
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            color: kTextColor,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {
              User user = Provider.of<User>(context, listen: false);
              if (user.isAuthenticated()) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()));
              } else {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              }
            },
          )
        ],
      ),
    ),
  );
}
