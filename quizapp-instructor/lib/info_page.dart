import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    //var appState = context.watch<MyAppState>();
    
    return const SizedBox(
      child: Column(
        children: <Widget>  [
          Text('HOW TO USE THIS APPLICATION'),
          Text('abcd')
        ]
      )
    );
  }
}