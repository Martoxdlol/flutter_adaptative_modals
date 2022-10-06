import 'package:adaptative_modals/adaptative_modals.dart';
import 'package:adaptative_modals_example/theme_switch.dart';
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
        title: const Text('Adaptative Modals'),
      ),
      body: CentralContainer(
          child: ListView(children: [
        ColorlessButtonCard(
            child: const Text('Open modal'),
            onTap: () {
              openDemoModal(context);
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

void openDemoModal(BuildContext context) {
  openModal(
    context,
    (context) => AdaptativeModal(
      title: Text('My super modal'),
      child: Column(
        children: [
          ColorlessButtonCard(
            child: Text('Open other modal'),
            onTap: () => openDemoModal(context),
          ),
        ],
      ),
    ),
  );
}

void openModal(BuildContext context, Widget Function(BuildContext context) builder) {
  Navigator.of(context).push(AdaptativeModalPageRoute(builder: builder));
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
