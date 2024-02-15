import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:quiz_app_instructor/create_quiz.dart';
import 'package:quiz_app_instructor/load_quiz.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Quiz App - Instructor Version',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MainMenu();
        break;
      case 1:
        page = CreateQuizPage();
        break;
      case 2:
        page = LoadQuizPage();
        break;
      case 3:
        page = Placeholder();
        break;
      case 4:
        page = Placeholder();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Main Menu'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Create Quiz'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Load Quiz'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Open Quiz Waiting Room'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Export Quiz'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                     selectedIndex = value; 
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                )
              )
            ],
          ),
        );
      }
    );
  }
}

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    
    return SafeArea(
      child: Column(
        children: <Widget>  [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: BeveledRectangleBorder(),
                    ),
                    onPressed: () {
                      print('Create Quiz Clicked');
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: AutoSizeText(
                        style: TextStyle(fontSize: 50.0),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        'Create Quiz'
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: BeveledRectangleBorder(),
                    ),
                    onPressed: () {
                      print('Load Quiz Clicked');
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: AutoSizeText(
                        style: TextStyle(fontSize: 50.0),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        'Load Quiz'
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child:
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: BeveledRectangleBorder(),
                    ),
                    onPressed: () {
                      print('Open Quiz Waiting Room Clicked');
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: AutoSizeText(
                        style: TextStyle(fontSize: 50.0),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        'Open Quiz Waiting Room'
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: BeveledRectangleBorder(),
                    ),
                    onPressed: () {
                      print('Export Answers Clicked');
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: AutoSizeText(
                        style: TextStyle(fontSize: 50.0),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        'Export Answers'
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}