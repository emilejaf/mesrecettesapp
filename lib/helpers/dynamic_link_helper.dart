import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mesrecettes/screens/recipe/shared_recipe_screen.dart';

class DynamicLinkHelper {
  FirebaseDynamicLinks _dynamicLinks;

  DynamicLinkHelper() {
    _dynamicLinks = FirebaseDynamicLinks.instance;
  }

  handleDynamicLinks(BuildContext context) async {
    final PendingDynamicLinkData data = await _dynamicLinks.getInitialLink();

    _handleDeepLink(context, data);

    _dynamicLinks.onLink(onSuccess: (PendingDynamicLinkData data) async {
      _handleDeepLink(context, data);
    }, onError: (OnLinkErrorException e) async {
      print('Link Failed: ${e.message}');
    });
  }

  void _handleDeepLink(BuildContext context, PendingDynamicLinkData data) {
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      final bool isRecipe = deepLink.pathSegments.contains('recipe');

      if (isRecipe) {
        final String recipeId = deepLink.queryParameters['id'];

        if (recipeId != null) {
          // navigate to recipe
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SharedRecipeScreen(
                  recipeId: recipeId,
                ),
              ));
        }
      }
    }
  }

  Future<String> createRecipeLink(String recipeId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://mesrecettes.page.link/',
        link: Uri.parse('https://mesrecettes.app/app/recipe/$recipeId'),
        androidParameters: AndroidParameters(packageName: 'com.mesrecettes'));

    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();

    final Uri shortUrl = shortDynamicLink.shortUrl;

    return shortUrl.toString();
  }
}

final DynamicLinkHelper dynamicLinkHelper = DynamicLinkHelper();
