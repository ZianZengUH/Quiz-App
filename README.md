# 🎯 Quiz-App
<img src="QuizApp-Instructor/images/quiz_app_logo_round.png" width="300" height="300"/>

## 📝 Introduction

### ❌ Problem:
When instructors have **large class sizes**, it becomes difficult to **maintain academic integrity** during quizzes. Students may try to **cheat** by:
- Taking quizzes **remotely** instead of in the classroom.
- Using unauthorized **devices or tools**.
- **Colluding** with others to share answers.

### ✅ Our Solution:
**Quiz App** is a **cross-platform** tool designed to provide **secure and reliable** quiz-taking for classrooms at **the University of Hawaii at Manoa (UHM)**.  
It consists of:
- 🖥️ **Instructor Desktop App** – Create, manage, and monitor quizzes.
- 📱 **Student Mobile App** – Authenticate attendance and prevent cheating.

This app **ensures classroom integrity** by leveraging:
- **Singleton WebSocket + GPS verification via LAN** for secure, real-time data transfer.
- **IP Logging, Camera Access, and Location Services** to verify student presence.

**Developed by**: _Zian Zeng, Feiyi Chen, Galen Chang_  
**Project Sponsor**: _Edoardo Biagioni, UH Manoa ICS Department_  

---

## 📌 Key Features
- **Cross-Platform Compatibility** – Runs on **Windows, macOS, and Android**  
- **LAN-based WebSocket Connection** – Ensures **real-time data sync**  
- **GPS & IP Verification** – Prevents remote quiz attempts  
- **Camera-based Attendance Logging** – Students must **take a picture** when logging in  
- **Instructor Tools** – **Create, modify, and export** quizzes with student submissions  
- **Anti-Cheating Mechanisms**:
   - 📵 **No split-screen, app minimization detection**
   - 📶 **Verifies connection via short-range Wi-Fi LAN**
   - 📍 **Blocks unauthorized remote logins**  

---

## 🏗️ System Overview

### 🎯 Requirements:
The **Quiz App** was built to meet the following **key requirements**:
- 📡 **Utilizes short-range Wi-Fi LAN** instead of the internet for connection security.
- 📍 **Verifies student presence** using **GPS and IP logging**.
- 📷 **Requires a photo submission** to verify student identity.
- 📝 **Instructor desktop app receives quiz answers** and **organizes them by section number**.

### 🏗️ Development Process:
- **Scrum-based development** – Agile methodology with **weekly sprints**.
- **Bi-weekly meetings via Zoom** – Alternating between team-only and sponsor-included discussions.
- **Project communication via Discord** – Preserving meeting notes and discussions.
- 🛠️ **Technology stack**:
  - **Flutter/Dart** – Enables cross-platform compatibility.
  - **GitHub** – Version control and team collaboration.
  - **Visual Studio Code** – Primary development environment.

---

## 📄 Check Out the Poster
For additional **screenshots** and **detailed insights**, check out the full poster:

📌 **[View Poster (PDF)](Quiz%20App%20Poster.pdf)**

---

## 🚀 Getting Started

### 📱 Build Android App
```bash
flutter build apk --release
```
## ⚠️ Important Notes:

### 📍 Enable Location Services
✅ **Location services must be enabled** for both **mobile and desktop** applications.

### 🛠 Fixing Windows Network Issues:
1. Press **Win + R**, type `control`, and hit Enter.
2. Navigate to **System and Security > Windows Defender Firewall**.
3. Click **Allow an app or feature through Windows Defender Firewall**.
   <img src="QuizApp-Instructor\images\quiz_app_winddows_defender_firewall_1.png"/>
4. Click **Change settings** and check both **Private** and **Public** boxes for the app.
   <img src="QuizApp-Instructor\images\quiz_app_winddows_defender_firewall_2.png"/>
5. Click **OK** to save changes.

---

## 🔥 Challenges & Learnings

### ⚠️ Challenges We Overcame:
- **Learning Flutter/Dart from scratch** – No prior experience with the framework.
- **Integrating short-range wireless technology** – Required extensive **research and testing**.
- **Limited Flutter BLE (Bluetooth Low Energy) support** – Had to shift to **LAN-based WebSocket communication**.
- **Scheduling conflicts** – Overcame by effective **team communication via Discord, Zoom, and email**.

### 🎓 What We Learned:
- 💡 **Mastered Flutter/Dart development**.
- 💡 **Deep understanding of short-range communication & security protocols**.
- 💡 **Improved proficiency in UI design & full-stack app development**.

---

## 📢 Summary

Quiz App is a **powerful, cross-platform** solution developed using **Flutter/Dart** to enhance **classroom integrity** during quizzes.  
With features like **real-time data transfer**, **GPS-based student verification**, and **anti-cheating mechanisms**, it ensures a **fair and secure assessment environment** for instructors and students.

🔥 **Empowering instructors. Securing quizzes. Preventing cheating.**

