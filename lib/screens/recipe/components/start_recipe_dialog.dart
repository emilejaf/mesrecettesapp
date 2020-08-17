import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mesrecettes/size_config.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class StartRecipeDialog extends StatefulWidget {
  final List<String> steps;

  const StartRecipeDialog({Key key, this.steps}) : super(key: key);
  @override
  _StartRecipeDialogState createState() => _StartRecipeDialogState();
}

class _StartRecipeDialogState extends State<StartRecipeDialog> {
  final PageController _controller = PageController(viewportFraction: 0.8);
  final Duration duration = Duration(milliseconds: 500);
  final Curve curve = Curves.easeOutQuint;

  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller.addListener(() {
      int next = _controller.page.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      content: Container(
        height: defaultSize * 20,
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: PageView.builder(
                  controller: _controller,
                  itemCount: widget.steps.length,
                  itemBuilder: (context, index) {
                    final bool active = currentPage == index;
                    final double top = active ? 0 : 20;
                    final double blur = active ? 15 : 0;
                    final double offset = active ? 2.5 : 0;
                    return Padding(
                      padding: EdgeInsets.fromLTRB(defaultSize, defaultSize * 3,
                          defaultSize, defaultSize * 2),
                      child: AnimatedContainer(
                        duration: duration,
                        margin: EdgeInsets.only(top: top),
                        curve: curve,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black87,
                                  blurRadius: blur,
                                  offset: Offset(offset, offset))
                            ]),
                        child: Stack(children: [
                          Positioned.fill(
                              child: Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(
                                top: defaultSize * 1, left: defaultSize * 1),
                            child: Text(
                              'Étape ' + (index + 1).toString(),
                              style: TextStyle(fontSize: defaultSize * 1.6),
                            ),
                          )),
                          Center(
                              child: Text(
                            widget.steps[index],
                            style: TextStyle(fontSize: defaultSize * 2.4),
                          )),
                        ]),
                      ),
                    );
                  }),
            ),
            SizedBox(
              height: 10,
            ),
            SmoothPageIndicator(
              controller: _controller,
              count: widget.steps.length,
              effect: WormEffect(activeDotColor: Theme.of(context).accentColor),
              onDotClicked: (index) {
                _controller.animateToPage(index,
                    duration: duration, curve: curve);
              },
            )
          ],
        ),
      ),
      actions: [
        FlatButton(
          child: Text(
            'Fermer',
            style: Theme.of(context).accentTextTheme.button,
          ),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
