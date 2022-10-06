import 'package:adaptative_modals/adaptative_modals.dart';
import 'package:adaptative_modals_example/theme_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    ThemeSwitcherWidget(
      initialTheme: lightTheme,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeSwitcher.of(context).themeData,
      home: const MyHomePage(title: 'Adaptative Modals'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: CentralContainer(
          child: ListView(children: [
        ColorlessButtonCard(
            child: const Text('Open modal'),
            onTap: () {
              openNormalModal(context);
            }),
        ColorlessButtonCard(
            child: const Text('Open full screen modal (on mobile)'),
            onTap: () {
              openModalFullScreen(context);
            }),
        ColorlessButtonCard(
            child: const Text('Open modal with navigator'),
            onTap: () {
              openDemoModalWithNavigator(context);
            }),
        ColorlessButtonCard(
          child: Text("Light THEME"),
          onTap: () {
            ThemeSwitcher.of(context).switchTheme(ThemeData.light());
          },
        ),
        ColorlessButtonCard(
          child: Text("Dark THEME"),
          onTap: () {
            ThemeSwitcher.of(context).switchTheme(ThemeData.dark());
          },
        )
      ])),
    );
  }
}

void openNormalModal(BuildContext context) {
  openModal(
    context,
    (context) => AdaptativeModal(
      title: Text('My super modal'),
      child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              ColorlessButtonCard(
                child: Text('Open other modal'),
                onTap: () => openNormalModal(context),
              ),
            ],
          )),
    ),
  );
}

void openModalFullScreen(BuildContext context) {
  openModal(
      context,
      (context) => Scaffold(
            appBar: AppBar(),
            body: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    ColorlessButtonCard(
                      child: Text('Open other modal'),
                      onTap: () => openModalFullScreen(context),
                    ),
                  ],
                )),
          ),
      fullScreen: true,
      pageTransition: true);
}

class ModalWithNavigatorContent extends StatelessWidget {
  const ModalWithNavigatorContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              ColorlessButtonCard(
                  child: const Text('Open modal'),
                  onTap: () {
                    openNormalModal(context);
                  }),
              ColorlessButtonCard(
                  child: const Text('Open full screen modal (on mobile)'),
                  onTap: () {
                    openModalFullScreen(context);
                  }),
              ColorlessButtonCard(
                  child: const Text('Open modal with navigator'),
                  onTap: () {
                    openDemoModalWithNavigator(context, false);
                  }),
              ColorlessButtonCard(
                child: Text('Open other route'),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ModalWithNavigatorContent()));
                },
              ),
              ColorlessButtonCard(
                child: Text('Back'),
                onTap: () {
                  bool poped = false;
                  Navigator.popUntil(context, (currentRoute) {
                    if (poped) return true;
                    if (currentRoute.isFirst) {
                      Navigator.of(context).context.findAncestorStateOfType<NavigatorState>()!.pop();
                      return true;
                    } else {
                      poped = true;
                      return false;
                    }
                  });
                },
              ),
            ],
          )),
    );
  }
}

class NavigatorPageModal extends StatelessWidget {
  const NavigatorPageModal({super.key});

  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalKey<NavigatorState>();
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) => CupertinoPageRoute(
        builder: (context) {
          return ModalWithNavigatorContent();
        },
      ),
    );
  }
}

void openDemoModalWithNavigator(BuildContext context, [bool big = true]) {
  Navigator.of(context).push(AdaptativeModalPageRoute(
      width: big ? 1000 : 640, height: big ? 600 : 480, builder: (context) => NavigatorPageModal(), fullScreen: true));
}

void openModal(BuildContext context, Widget Function(BuildContext context) builder,
    {bool fullScreen = false, bool pageTransition = false}) {
  Widget transition(child, animation, secondaryAnimation) => CupertinoPageTransition(
        linearTransition: true,
        primaryRouteAnimation: animation,
        secondaryRouteAnimation: secondaryAnimation,
        child: child,
      );

  Navigator.of(context)
      .push(AdaptativeModalPageRoute(builder: builder, fullScreen: fullScreen, pageTransition: pageTransition ? transition : null));
}

class CentralContainer extends StatelessWidget {
  const CentralContainer({super.key, this.child, this.minHorizontalMargin = 12, this.maxWidth = 600});

  final Widget? child;
  final double minHorizontalMargin;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      final double maring = minHorizontalMargin;
      double totalWidth = constrains.maxWidth;

      if (constrains.maxWidth > maxWidth) {
        totalWidth = maxWidth;
      }

      final double width = totalWidth - maring * 2;

      return Container(
        width: width,
        margin: EdgeInsets.symmetric(horizontal: (constrains.maxWidth - totalWidth) / 2),
        padding: EdgeInsets.symmetric(horizontal: maring),
        child: child,
      );
    });
  }
}

class ColorlessButtonCard extends StatelessWidget {
  const ColorlessButtonCard({super.key, this.child, this.onTap});
  final Widget? child;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: child,
        ),
      ),
    );
  }
}
