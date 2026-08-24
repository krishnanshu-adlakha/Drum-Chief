import 'dart:convert';
import 'package:awesome_number_picker/awesome_number_picker.dart';
import 'package:drum_chief/auth/auth_services.dart';
import 'package:drum_chief/firestore.dart';
import 'package:drum_chief/widgets/fixed_list_picker.dart';
import 'package:flutter/material.dart';
import 'package:crisp_notation/crisp_notation.dart';

class CreationScreen extends StatefulWidget {
  const CreationScreen({super.key, required this.routine, required this.id});
  final Map<String, dynamic> routine;
  final String id;

  @override
  State<CreationScreen> createState() => _CreationScreenState();
}

//Snare = c5
//Triplet = 3[]
//Rest = r

//FIX BACKSPACE WHEN EDITING

List<dynamic> buildNotes(
  String newNote,
  List<dynamic> currentList,
  bool addNew,
) {
  //Add the note
  if (addNew &&
      currentList.isNotEmpty &&
      currentList.last is List &&
      currentList.last.length < 3) {
    currentList[currentList.length - 1].add(newNote);
  } else if (addNew) {
    currentList.add(newNote);
  }

  String newNotesString = "";

  for (final note in currentList) {
    if (note is List) {
      newNotesString += "3[${note.join(" ")}] ";
    } else {
      newNotesString += "$note ";
    }
  }

  //Build string from the list
  return [currentList, newNotesString];
}

class _CreationScreenState extends State<CreationScreen> {
  String _selectedNoteValue = "q";
  bool isTriplet = false;
  String currentDrum = "Snare";

  String notesString = "";
  String stickings = "";
  List<dynamic> allStickings = [];
  List<dynamic> notesList = [];

  //quarter note = 960 ticks
  //eigth note = 480 ticks
  //sixteenth = 240 ticks
  //32nd = 120
  //ONE BAR = 3840
  List<dynamic> barValues = [0];
  Map noteValues = {"q": 960, "e": 480, "s": 240, "t": 120};
  Map ticksByBottomValue = {2: 1920, 4: 960, 8: 480, 16: 240};
  List<dynamic> currentTimeSignature = [4, 4];
  num fullBarValue = 3840;
  num previousNoteValue = 0;
  List<dynamic> addedNoteValues = [];

  int selectedTopValue = 4;
  int selectedBottomValue = 4;

  bool editingExisting = false;
  String id = "";

  final FirestoreService firestoreService = FirestoreService();
  final nameController = TextEditingController();

  @override
  void initState() {
    if (widget.routine.isNotEmpty) {
      editingExisting = true;
      currentTimeSignature = widget.routine["timeSignature"];
      barValues = widget.routine["barValues"];
      nameController.text = widget.routine["name"];
      allStickings = widget.routine["stickings"];
      stickings = widget.routine["stickings"].join(" ");
      notesString = widget.routine["notes"];
      notesList = jsonDecode(widget.routine["notesList"]) as List<dynamic>;
      id = widget.id;
      fullBarValue =
          currentTimeSignature[0] * ticksByBottomValue[currentTimeSignature[1]];
      selectedBottomValue = currentTimeSignature[1];
      selectedTopValue = currentTimeSignature[0];
      addedNoteValues = widget.routine["addedNoteValues"];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10.0,
            children: [
              Text(
                "CREATE A ROUTINE",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(
                        "Edit time signature",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: SizedBox(
                        height: 350,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 150,
                              child: IntegerNumberPicker(
                                initialValue: selectedTopValue,
                                minValue: 2,
                                maxValue: 33,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedTopValue = newValue;
                                  });
                                },
                              ),
                            ),
                            Divider(thickness: 3),
                            SizedBox(
                              height: 150,
                              child: FixedNumberPicker(
                                initialValue: selectedBottomValue,
                                minValue: 2,
                                maxValue: 32,
                                items: [2, 4, 8, 16],
                                selectedItem: selectedBottomValue,
                                onChanged: (newValue) {
                                  selectedBottomValue = newValue;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            selectedBottomValue = currentTimeSignature[1];
                            selectedTopValue = currentTimeSignature[0];
                            Navigator.of(context).pop();
                          },
                          child: Text("Exit"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              currentTimeSignature[0] = selectedTopValue;
                              currentTimeSignature[1] = selectedBottomValue;
                              fullBarValue =
                                  currentTimeSignature[0] *
                                  ticksByBottomValue[currentTimeSignature[1]];
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text("Continue"),
                        ),
                      ],
                    ),
                    barrierDismissible: false,
                  );
                },
                style: ButtonStyle(
                  shadowColor: WidgetStatePropertyAll(Colors.black),
                  backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                  side: WidgetStatePropertyAll(
                    BorderSide(width: 1, color: Colors.grey),
                  ),
                  padding: WidgetStatePropertyAll(EdgeInsets.all(0)),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.all(
                        Radius.circular(7),
                      ),
                    ),
                  ),
                ),
                child: Text(
                  "${currentTimeSignature[0]}/${currentTimeSignature[1]}",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MultiSystemView(
                          onElementTap: (elementId) {
                            int noteIndex = int.parse(elementId.substring(1));

                            List<String> notes = [];

                            for (final element in notesList) {
                              if (element is List) {
                                for (final subElement in element) {
                                  notes.add(subElement);
                                }
                              } else {
                                if (element != " | ") {
                                  notes.add(element);
                                }
                              }
                            }

                            if (!notes[noteIndex].contains("r")) {
                              String existingSticking = allStickings[noteIndex];
                              String newSticking = "*";

                              if (existingSticking == "*") {
                                newSticking = "R";
                              } else if (existingSticking == "R") {
                                newSticking = "L";
                              }

                              setState(() {
                                allStickings[noteIndex] = newSticking;
                                stickings = allStickings.join(" ");
                              });
                            }
                          },
                          theme: CrispNotationTheme(
                            staffColor: Colors.white,
                            noteColor: Colors.white,
                          ),
                          systemGap: 1,
                          staffSpace: 8,
                          score: Score.simple(
                            annotations: stickings,
                            clef: Clef.percussion,
                            notes: notesString,
                            timeSignature: TimeSignature(
                              currentTimeSignature[0],
                              currentTimeSignature[1],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Wrap(
                        spacing: 5.0,
                        children: [
                          ChoiceChip(
                            label: Text(
                              "¼",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                              ),
                            ),
                            selected:
                                (barValues.last + noteValues["q"] <=
                                    fullBarValue)
                                ? _selectedNoteValue == "q"
                                : false,
                            onSelected:
                                (barValues.last + noteValues["q"] <=
                                    fullBarValue)
                                ? (bool selected) {
                                    setState(() {
                                      _selectedNoteValue = selected ? "q" : "";
                                    });
                                  }
                                : null,
                          ),
                          ChoiceChip(
                            label: Text(
                              "⅛",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                              ),
                            ),
                            selected:
                                (barValues.last + noteValues["e"] <=
                                    fullBarValue)
                                ? _selectedNoteValue == "e"
                                : false,
                            onSelected:
                                (barValues.last + noteValues["e"] <=
                                    fullBarValue)
                                ? (bool selected) {
                                    setState(() {
                                      _selectedNoteValue = selected ? "e" : "";
                                    });
                                  }
                                : null,
                          ),
                          ChoiceChip(
                            label: Text(
                              "¹⁄₁₆",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                              ),
                            ),
                            selected:
                                (barValues.last + noteValues["s"] <=
                                    fullBarValue)
                                ? _selectedNoteValue == "s"
                                : false,
                            onSelected:
                                (barValues.last + noteValues["s"] <=
                                    fullBarValue)
                                ? (bool selected) {
                                    setState(() {
                                      _selectedNoteValue = selected ? "s" : "";
                                    });
                                  }
                                : null,
                          ),
                          ChoiceChip(
                            label: Text(
                              "¹⁄₃₂",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                              ),
                            ),
                            selected:
                                (barValues.last + noteValues["t"] <=
                                    fullBarValue)
                                ? _selectedNoteValue == "t"
                                : false,
                            onSelected:
                                (barValues.last + noteValues["t"] <=
                                    fullBarValue)
                                ? (bool selected) {
                                    setState(() {
                                      _selectedNoteValue = selected ? "t" : "";
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Wrap(
                        spacing: 5.0,
                        children: [
                          ChoiceChip(
                            label: Text(
                              "Triplet",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            selected: isTriplet,
                            selectedColor: Colors.green,
                            onSelected:
                                (_selectedNoteValue != "" &&
                                    barValues.last +
                                            noteValues[_selectedNoteValue] *
                                                (2 / 3) <=
                                        fullBarValue)
                                ? (bool selected) {
                                    setState(() {
                                      isTriplet = selected ? true : false;
                                    });
                                  }
                                : null,
                          ),
                          DropdownMenu(
                            enabled: _selectedNoteValue != "",
                            initialSelection: currentDrum,
                            dropdownMenuEntries: [
                              DropdownMenuEntry(value: "Snare", label: "Snare"),
                              DropdownMenuEntry(value: "Kick", label: "Kick"),
                              DropdownMenuEntry(value: "Rest", label: "Rest"),
                            ],
                            enableSearch: false,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            onSelected: (newValue) {
                              setState(() {
                                currentDrum = newValue!;
                              });
                            },
                            inputDecorationTheme: InputDecorationTheme(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              constraints: BoxConstraints.tight(
                                const Size.fromHeight(50),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Wrap(
                        spacing: 5.0,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (_selectedNoteValue != "") {
                                setState(() {
                                  String newNote = "";
                                  if (currentDrum == "Rest") {
                                    newNote = "r:$_selectedNoteValue";
                                  } else if (currentDrum == "Kick") {
                                    newNote = "f4:$_selectedNoteValue";
                                  } else if (currentDrum == "Snare") {
                                    newNote = "c5:$_selectedNoteValue";
                                  }

                                  if (isTriplet &&
                                      (notesList.isEmpty ||
                                          notesList.last is! List ||
                                          (notesList.last.length == 3))) {
                                    notesList.add([]);
                                    previousNoteValue =
                                        noteValues[_selectedNoteValue] *
                                        (2 / 3);
                                  } else {
                                    if (notesList.isNotEmpty &&
                                        notesList.last is List) {
                                      previousNoteValue =
                                          noteValues[_selectedNoteValue] *
                                          (2 / 3);
                                    } else {
                                      previousNoteValue =
                                          noteValues[_selectedNoteValue];
                                    }
                                  }

                                  if (barValues.last + previousNoteValue <=
                                      fullBarValue) {
                                    barValues.last += previousNoteValue;
                                    addedNoteValues.add(previousNoteValue);

                                    final builtNotes = buildNotes(
                                      newNote,
                                      notesList,
                                      true,
                                    );
                                    notesString = builtNotes[1];
                                    notesList = builtNotes[0];

                                    if (currentDrum != "Rest") {
                                      allStickings.add("*");
                                      stickings = allStickings.join(" ");
                                    } else {
                                      allStickings.add("");
                                    }
                                  } else {
                                    _selectedNoteValue = "";
                                  }
                                });
                              } else {
                                const snackBar = SnackBar(
                                  content: Text('No note value selected'),
                                );
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(snackBar);
                              }
                            },
                            style: ButtonStyle(
                              shadowColor: WidgetStatePropertyAll(Colors.black),
                              backgroundColor: WidgetStatePropertyAll(
                                Theme.of(context).primaryColor,
                              ),
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.all(
                                    Radius.circular(7),
                                  ),
                                ),
                              ),
                            ),
                            child: Text(
                              "ADD NOTE",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                notesList.add(" | ");
                                barValues.add(0);
                                final builtNotes = buildNotes(
                                  "",
                                  notesList,
                                  false,
                                );
                                notesList = builtNotes[0];
                                notesString = builtNotes[1];
                              });
                            },
                            style: ButtonStyle(
                              shadowColor: WidgetStatePropertyAll(Colors.black),
                              backgroundColor: WidgetStatePropertyAll(
                                Theme.of(context).primaryColor,
                              ),
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.all(
                                    Radius.circular(7),
                                  ),
                                ),
                              ),
                            ),
                            child: Text(
                              "ADD BAR",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      Wrap(
                        spacing: 5.0,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(
                                    "Are you sure?",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    "This routine will be deleted forever.",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          allStickings = [];
                                          stickings = "";
                                          notesString = "";
                                          notesList = [];
                                          barValues = [0];
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Yes"),
                                    ),
                                  ],
                                ),
                                barrierDismissible: true,
                              );
                            },
                            style: ButtonStyle(
                              shadowColor: WidgetStatePropertyAll(Colors.black),
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.red,
                              ),
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.all(
                                    Radius.circular(7),
                                  ),
                                ),
                              ),
                            ),
                            child: Text(
                              "RESET",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (notesList.isNotEmpty) {
                                  String removedNote = "";
                                  if (notesList.last is List) {
                                    removedNote = notesList.last.removeLast();
                                    if (notesList.last.isEmpty) {
                                      notesList.removeLast();
                                    }
                                  } else {
                                    removedNote = notesList.removeLast();
                                  }

                                  if (removedNote != " | ") {
                                    barValues.last -= addedNoteValues.last;
                                    addedNoteValues.removeLast();
                                    allStickings.removeLast();
                                    stickings = allStickings.join(" ");
                                  } else {
                                    barValues.removeLast();
                                  }

                                  final builtNotes = buildNotes(
                                    "",
                                    notesList,
                                    false,
                                  );
                                  notesString = builtNotes[1];
                                  notesList = builtNotes[0];
                                }
                              });
                            },
                            style: ButtonStyle(
                              shadowColor: WidgetStatePropertyAll(Colors.black),
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.red,
                              ),
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.all(
                                    Radius.circular(7),
                                  ),
                                ),
                              ),
                            ),
                            child: Text(
                              "⌫",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: nameController,
                  style: TextStyle(color: Colors.white),
                  maxLength: 30,
                  decoration: InputDecoration(
                    icon: Icon(Icons.edit, color: Colors.grey),
                    suffixIcon: SizedBox(
                      child: IconButton(
                        icon: Icon(Icons.save, color: Colors.white),
                        onPressed: () async {
                          SnackBar snackBar;
                          if (nameController.text.isEmpty) {
                            snackBar = SnackBar(
                              content: Text("No name provided."),
                            );
                          } else if (!editingExisting) {
                            id = await firestoreService.addRoutine(
                              authService.value.currentUser!.uid,
                              {
                                "name": nameController.text,
                                "stickings": allStickings,
                                "notes": notesString,
                                "timeSignature": currentTimeSignature,
                                "barValues": barValues,
                                "notesList": jsonEncode(notesList),
                                "addedNoteValues": addedNoteValues
                              },
                            );
                            editingExisting = true;
                            snackBar = SnackBar(
                              content: Text("Routine created successfully."),
                            );
                          } else {
                            firestoreService.updateRoutine(
                              authService.value.currentUser!.uid,
                              id,
                              {
                                "name": nameController.text,
                                "stickings": allStickings,
                                "notes": notesString,
                                "timeSignature": currentTimeSignature,
                                "barValues": barValues,
                                "notesList": jsonEncode(notesList),
                                "addedNoteValues": addedNoteValues
                              },
                            );

                            snackBar = SnackBar(
                              content: Text("Routine saved successfully."),
                            );
                          }

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// [
//  {
//   "name": "Ascending note values",
//    "id": "q45u98awefasdf234"
//   "stickings": [],
//   "notes": [],
//   "timeSignature": [4,4],
//   "barValues": []
// }
// ]
