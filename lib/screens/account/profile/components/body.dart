import 'package:flutter/material.dart';
import 'package:mesrecettes/models/category.dart';
import 'package:mesrecettes/models/recipe.dart';
import 'package:mesrecettes/models/user.dart';
import 'package:provider/provider.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(builder: (context, user, child) {
      if (user.user != null) {
        return Center(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (user.user.photoUrl != null)
                        CircleAvatar(
                            backgroundImage: NetworkImage(user.user.photoUrl))
                      else
                        Icon(
                          Icons.account_circle,
                          color: Colors.black,
                          size: 50,
                        ),
                      if (user.user.displayName != null)
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            user.user.displayName,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      if (user.user.email != null)
                        Text(
                          user.user.email,
                          style: TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                  child: Column(
                    children: [
                      Card(
                        child: ListTile(
                            title: Text('Se déconnecter'),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                              Navigator.pop(context);
                              user.signOut();
                              Provider.of<Recipes>(context, listen: false)
                                  .unsyncAllRecipes();
                              Provider.of<Categories>(context, listen: false)
                                  .unsyncAllCategories();
                            }),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      } else {
        return Container();
      }
    });
  }
}
