import 'package:crisp_notation/crisp_notation.dart';
import 'package:drum_chief/widgets/metronome.dart';
import 'package:flutter/material.dart';

class PracticeScreen extends StatefulWidget {
  final Map<String, dynamic> routine;
  const PracticeScreen({super.key, required this.routine});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(widget.routine["name"], style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: MultiSystemView(
                staffSpace: 10,
                systemGap: 1,
                theme: CrispNotationTheme(
                  staffColor: Colors.white,
                  noteColor: Colors.white,
                ),
                score: Score.simple(
                  clef: Clef.percussion,
                  annotations: (widget.routine["stickings"] as List).join(" "),
                  notes: widget.routine["notes"],
                  timeSignature: TimeSignature(
                    widget.routine["timeSignature"][0],
                    widget.routine["timeSignature"][1],
                  ),
                ),
              ),
            ),
            Divider(thickness: 1, height: 30),
            MetronomeInterface(editableTimeSignature: false, timeSignature: widget.routine["timeSignature"][0]),
            SizedBox(height: 30,)
          ],
        ),
      ),
    );
  }
}
