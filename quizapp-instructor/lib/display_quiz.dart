import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_instructor/quiz_data.dart';
import 'package:quiz_app_instructor/server.dart';
import 'package:slide_countdown/slide_countdown.dart';

// Countdown implemented with help from:
//    https://pub.dev/packages/slide_countdown
//    https://github.com/farhanfadila1717/slide_countdown/blob/master/example/example.dart#L111
//    https://github.com/farhanfadila1717/slide_countdown/blob/master/example/example_raw_slide_countdown.dart
// By Farhan Fadila

class ShowQuiz extends StatefulWidget {
  const ShowQuiz({super.key});

  @override
  State<ShowQuiz> createState() => _ShowQuizState();
}

class _ShowQuizState extends State<ShowQuiz> {
  @override
  Widget build(BuildContext context) {    
    int duration = Provider.of<QuizData>(context).duration;
    String question = Provider.of<QuizData>(context).question;
    double fontSize = Provider.of<QuizData>(context).fontSize.toDouble();

    StreamDuration quizDuration = StreamDuration(
      config: StreamDurationConfig(
        autoPlay: false,
        countDownConfig: CountDownConfig(
          // There is a bug with Duration(), where it sets the time to duration minutes - 2 seconds.
          // Ex. If duration is set to 15 minutes, Duration() is set to 14 minutes, 58 seconds.
          duration: Duration(minutes: duration, seconds: 2),
        ),
      ),
    );

    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  SlideCountdown(
                    streamDuration: quizDuration,
                    
                    separatorStyle: const TextStyle(
                      fontSize: 75,
                      color: Colors.white
                    ),
                    style: const TextStyle(
                      fontSize: 75,
                      color: Colors.white
                    ),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 6, 86, 6),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: ElevatedButton(
                            onPressed: () {
                              quizDuration.play();
                            },
                            child: const Text('Start'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: ElevatedButton(
                            onPressed: () {
                              quizDuration.pause();
                            },
                            child: const Text('Pause'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  question,
                  style: TextStyle(fontSize: fontSize),
                ),
              )
            ),
          ],
        )
      )
    );
  }
}