import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crisp_notation/crisp_notation.dart';
import 'package:drum_chief/auth/auth_services.dart';
import 'package:drum_chief/firestore.dart';
import 'package:drum_chief/pages/create.dart';
import 'package:drum_chief/pages/practice.dart';
import 'package:drum_chief/widgets/loading_page.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "YOUR ROUTINES",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed("/edit-account");
          },
          icon: Icon(Icons.account_circle, size: 35),
        ),
        actions: [
          FloatingActionButton.small(
            onPressed: () {
              Navigator.pushNamed(context, "/create");
            },
            backgroundColor: Colors.orange,
            child: Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/metronome");
        },
        backgroundColor: Colors.cyan,
        child: Icon(Icons.speed, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getRoutinesStream(
          authService.value.currentUser!.uid,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List routinesList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: routinesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = routinesList[index];
                String docId = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;

                String previewNotes = "";
                List<dynamic> notesList =
                    jsonDecode(data["notesList"]) as List<dynamic>;
                String annotations = "";
                int noteCount = 0;

                for (final note in notesList) {
                  if (note is List) {
                    previewNotes += "3[${note.join(" ")}] ";
                    noteCount += note.length;
                  } else {
                    if (note.contains("|")) {
                      break;
                    } else {
                      previewNotes += "$note ";
                      noteCount += 1;
                    }
                  }
                }

                annotations = (data["stickings"] as List)
                    .sublist(0, noteCount)
                    .join(" ");

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            PracticeScreen(routine: data),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.all(15),
                    color: Color(0xFF152238),
                    elevation: 10,
                    shadowColor: Colors.cyan,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            data["name"],
                            style: TextStyle(color: Colors.white, fontSize: 20),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: 15),
                          MultiSystemView(
                            staffSpace: 8,
                            systemGap: 1,
                            theme: CrispNotationTheme(
                              staffColor: Colors.white,
                              noteColor: Colors.white,
                            ),
                            score: Score.simple(
                              clef: Clef.percussion,
                              annotations: annotations,
                              notes: previewNotes,
                              timeSignature: TimeSignature(
                                data["timeSignature"][0],
                                data["timeSignature"][1],
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Wrap(
                            spacing: 5,
                            children: [
                              FloatingActionButton.small(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) => CreationScreen(
                                        routine: data,
                                        id: docId,
                                      ),
                                    ),
                                  );
                                },
                                backgroundColor: Colors.green,
                                shape: const CircleBorder(),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),

                              FloatingActionButton.small(
                                onPressed: () {
                                  firestoreService.deleteRoutine(
                                    docId,
                                    authService.value.currentUser!.uid,
                                  );
                                  SnackBar snackBar = SnackBar(
                                    content: Text(
                                      "Routine deleted successfully.",
                                    ),
                                  );
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(snackBar);
                                },
                                backgroundColor: Colors.red,
                                shape: const CircleBorder(),
                                child: Icon(
                                  Icons.delete_forever,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return LoadingPage();
          }
        },
      ),
    );
  }
}
