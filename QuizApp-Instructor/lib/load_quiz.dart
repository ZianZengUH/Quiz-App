import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_instructor/quiz_data.dart';

class LoadQuizPage extends StatefulWidget {
  const LoadQuizPage({super.key});

  @override
  State<LoadQuizPage> createState() => _LoadQuizPageState();
}

class _LoadQuizPageState extends State<LoadQuizPage> {
  var _selectedOption = '';

  @override
  Widget build(BuildContext context) {
    String currentDirectory = Directory.current.path;
    Directory quizDirectory = Directory('Saved Quizzes');
    List dirContents = quizDirectory.listSync();
    Iterable<File> iterableFiles = dirContents.whereType<File>();
    List<File> filesAsFile = iterableFiles.toList();
    List<String> filesAsString = [];
    List<String> filePostSplitSlash;
    List<String> filePostSplitApostrophe;
    List<String> files = [];

    for (File file in filesAsFile) {
      filesAsString.add(file.toString());
    }


    for (String file in filesAsString) {
      if (Platform.isMacOS | Platform.isLinux) {
        filePostSplitSlash = file.split('/');
      } 
      else {
        filePostSplitSlash = file.split('\\');
      }
      filePostSplitApostrophe = filePostSplitSlash[1].split('\'');
      files.add(filePostSplitApostrophe[0]);
    }

    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget> [
          Container(
            padding: const EdgeInsets.all(5.0),
            // color: Color.fromARGB(49, 26, 190, 254),
            decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      // Color.fromARGB(255, 71, 148, 56), // Light green
                      // Color(0xFF004D40), // Dark green color
                      Color.fromARGB(255, 71, 148, 56), // Light green
                        Color.fromARGB(255, 71, 148, 56),
                    ],
                    stops: [0.2, 0.9],
                  ),
                ),
            child: Text(
              'Searching for quizzes in:\n$currentDirectory\\Saved Quizzes',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),  
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10, left: 15),
              child: Text(
              "Select the quiz you would like to load:",
              textAlign: TextAlign.start,
                style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),  
            ),
          ),
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
                        foregroundColor: Colors.white, 
                        backgroundColor: Color.fromARGB(255, 25, 148, 0), // Button color (green)
                      ),
                      onPressed: () {
                        List<String> quizName = _selectedOption.split('\\');

                        if (quizName[0] == '') {
                          print("Nothing selected");
                        } else {
                          _read(quizName[0]).then((List quizList) =>
                          Provider.of<QuizData>(context, listen: false).changeQuizData(
                            quizList[0],
                            int.parse(quizList[1]),
                            int.parse(quizList[2]),
                            quizList[3]));
                          }
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

  Future<List> _read(String quizFile) async {
    String quizAsString = '';
    List quizData = [];
    File quiz = File('${Directory.current.path}/Saved Quizzes/$quizFile');

    try {
      quizAsString = await quiz.readAsString();
      quizData = quizAsString.split(',,');
    } catch (e) {
      print("Couldn't read file");
    }
    return quizData;
  }
}