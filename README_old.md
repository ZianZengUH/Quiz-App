# Quiz-App
<img src="QuizApp-Instructor\images\quiz_app_logo_round.png" width="300" height="300"/>

## Introduction
### Problem:
When instructors have large class sizes, it is very difficult for them to maintain the integrity of their classroom during quizzes.  Our Quiz App intends to help alleviate this issue by utilizing the instructor’s and student’s Wi-fi connection to the same network, pictures taken by the student in class, IP logging, and other technologies to prevent students from taking the quiz at home or attempting to cheat.


### Our Solution:
Quiz App is a cross-platform app that consists a desktop version for the instructor and a mobile version for the students. It uses singleton WebSocket + GPS verification via LAN for connection and real-time data transfer which help to track attendance and dissuade cheating while students take quizzes for ICS and other departments at the University of Hawaii at Manoa

**_Design and Developed by Zian Zeng, Feiyi Chen, Galen Chang_**

## Getting Started

### Build Android App
```
flutter build apk --release
```
The released .apk can be found in ...\build\app\outputs\flutter-apk

### Build MacOS App
```
cd QuizApp-Instructor
```
```
flutter build macos
```
The MacOS app can be found in macos/Runner.xcworkspace

### Build Windows App
```
cd QuizApp-Instructor
```
```
flutter build windows
```
The released .exe file can be found in ...\projectName\build\windows\runner\Release\

### Important Notes:
Make sure location service is turn on for both mobile and desktop sides.

#### Windows may run in network issue:
##### Allowing Apps Through the Firewall:
1. Press Win + R to open the Run dialog.
2. Type control and press Enter to open the Control Panel.
3. Go to System and Security.
4. Click on Windows Defender Firewall.
5. On the left side, click on Allow an app or feature through Windows Defender Firewall.
<img src="QuizApp-Instructor\images\quiz_app_winddows_defender_firewall_1.png"/>
6. In the new window, click on Change settings to enable modifying the list.
7. Check the boxes for both Private and Public next to your app's name. If the app is not listed, click Allow another app..., browse for it, and add it manually.
<img src="QuizApp-Instructor\images\quiz_app_winddows_defender_firewall_2.png"/>
8. Click OK to save changes.



