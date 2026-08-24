import 'package:flutter/material.dart';
import 'package:drum_chief/utils.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "DRUM CHIEF",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                Image.asset("assets/drumsticks.png", height: 80),
                SizedBox(height: 20),
                Text(
                  "Drum Chief",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "An open-source application designed to help drummers with their exercises by providing a clean interface to save and practice them.",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                InkWell(child: Image.asset("assets/built_with_flutter.png", height: 60), onTap: (){
                  Utils().openLink(url: "https://flutter.dev");
                }),
                SizedBox(height: 30),
                InkWell(
                  child: Image.asset("assets/github.webp", height: 60),
                  onTap: () {
                    Utils().openLink(url: "https://github.com/krishnanshu-adlakha");
                  },
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          "© 2026 Krishnanshu Adlakha. All rights reserved.",
          style: TextStyle(color: Colors.grey, fontSize: 17),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
