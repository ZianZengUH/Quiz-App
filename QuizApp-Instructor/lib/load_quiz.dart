import 'dart:io';
import 'package:flutter/material.dart';

class LoadQuizPage extends StatefulWidget {
  const LoadQuizPage({super.key});

  @override
  State<LoadQuizPage> createState() => _LoadQuizPageState();
}

class _LoadQuizPageState extends State<LoadQuizPage> {
  var _selectedOption = '';

  @override
  Widget build(BuildContext context) {
    var dir = Directory.current;
    List dirContents = dir.listSync();
    Iterable<File> iterableFiles = dirContents.whereType<File>();
    List files = iterableFiles.toList();

    return SizedBox(
      child: Column(
        children: <Widget> [
          Expanded(
              child: ListView.separated(
              itemCount: files.length,
              itemBuilder: (context, index) {
                return RadioListTile(
                  title: Text(files[index].toString()),
                  value: files[index].toString(),
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  }
                );
              },
              separatorBuilder: (BuildContext context,int index) {
                return const Divider();
              },
            ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const BeveledRectangleBorder(),
                      ),
                      onPressed: () {
                       print('testing');
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text('Load Quiz'),
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