import 'package:flutter/material.dart';
import 'package:mesrecettes/components/my_drawer.dart';
import 'package:mesrecettes/helpers/dynamic_link_helper.dart';
import 'package:mesrecettes/models/category.dart';
import 'package:mesrecettes/models/user.dart';
import 'package:mesrecettes/screens/account/login/login_screen.dart';
import 'package:mesrecettes/screens/account/profile/profile_screen.dart';
import 'package:mesrecettes/screens/create_recipe/create_recipe_screen.dart';
import 'package:mesrecettes/screens/home/components/body.dart';
import 'package:mesrecettes/screens/search/search_screen.dart';
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
            centerTitle: true,
            title: Text('Mes Recettes'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SearchScreen()));
                },
              ),
              IconButton(
                icon: Icon(Icons.account_circle),
                onPressed: () {
                  User user = Provider.of<User>(context, listen: false);
                  if (user.isAuthenticated()) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  }
                },
              )
            ],
            bottom: TabBar(
              isScrollable: true,
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
