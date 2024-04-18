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
    Directory quizDirectory = Directory('Saved Quizzes');
    List dirContents = quizDirectory.listSync();
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
                        List<String> testing = _selectedOption.split('\'');
                        //Future<List> quizData = _read(testing[1]);
                        //List quizList = _convertToList(quizData);

                        if (testing.length <= 1) {
                          print("Nothing selected");
                        } else {
                          _read(testing[1]).then((List quizList) =>
                          Provider.of<QuizData>(context, listen: false).changeQuizData(
                            quizList[0],
                            int.parse(quizList[1]),
                            int.parse(quizList[2]),
                            quizList[3]));
                          // Provider.of<QuizData>(context, listen: false).changeQuizData(quizList[0], quizList[1], quizList[2], quizList[3]);
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
    File quiz = File('${Directory.current.path}/$quizFile');

    try {
      quizAsString = await quiz.readAsString();
      quizData = quizAsString.split(',,');
    } catch (e) {
      print("Couldn't read file");
    }
    // name
    //print(quizData[0]);
    // duration
    //print(quizData[1]);
    // font size
    //print(quizData[2]);
    // question
    //print(quizData[3]);

    return quizData;
  }

  _convertToList(Future<List> data) async {
    List list = await data;
    return list;
  }
}