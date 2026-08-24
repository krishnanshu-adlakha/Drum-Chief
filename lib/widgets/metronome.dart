import 'dart:async';
import 'package:awesome_number_picker/awesome_number_picker.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:metronome/metronome.dart';

class MetronomeInterface extends StatefulWidget {
  final int timeSignature;
  final bool editableTimeSignature;

  const MetronomeInterface({
    this.timeSignature = 4,
    this.editableTimeSignature = true,
    super.key,
  });

  @override
  State<MetronomeInterface> createState() => _MetronomeInterfaceState();
}

class _MetronomeInterfaceState extends State<MetronomeInterface> {
  Metronome metronome = Metronome();
  int tempo = 120;
  int timeSignature = 4;
  int selectedTimeSignature = 4;
  IconData currentButtonIcon = Icons.play_arrow;
  bool accentFirstBeat = true;
  String currentSoundPath = "assets/audio/quartz";
  String currentMode = "click";
  int currentGapBeat = 0;
  int gapBars = 2;
  int playingBars = 2;
  int selectedGapBars = 2;
  int selectedPlayingBars = 2;
  int increaseIntervalMins = 1;
  int increaseBpm = 20;
  int targetTempo = 0;
  int selectedIncrease = 20;
  int selectedInterval = 1;
  bool metronomeStopped = true;
  Timer? gapClickTimer;
  Timer? accelerationTimer;

  void startClickTimer() {
    gapClickTimer = Timer.periodic(
      Duration(microseconds: (60000000 / tempo).round()),
      (timer) async {
        if (!metronomeStopped) {
          if (currentMode == "gap") {
            final isPlaying = await metronome.isPlaying();
            currentGapBeat += 1;
            if (isPlaying ?? false) {
              if (currentGapBeat == timeSignature * playingBars) {
                currentGapBeat = 0;
                metronome.stop();
              }
            } else {
              if (kIsWeb) {
                if (currentGapBeat == (timeSignature * gapBars + 1)) {
                  currentGapBeat = 0;
                  metronome.play();
                }
              } else {
                if (currentGapBeat == timeSignature * gapBars) {
                  currentGapBeat = 0;
                  metronome.play();
                }
              }
            }
          }
        }
      },
    );
  }

  void startAccelerationTimer() {
    accelerationTimer = Timer.periodic(
      Duration(
        microseconds: (increaseIntervalMins * 60000000 / increaseBpm).round(),
      ),
      (timer) {
        if (currentMode == "speeding_up" && !metronomeStopped) {
          if (!(tempo == targetTempo) && (tempo + 1) < 300) {
            setState(() {
              tempo += 1;
            });
          }
        }
      },
    );
  }

  @override
  void initState() {
    timeSignature = widget.timeSignature;
    selectedTimeSignature = widget.timeSignature;
    targetTempo = tempo + increaseBpm;
    metronome.init(
      "assets/audio/quartz_low.wav",
      accentedPath: "assets/audio/quartz_high.wav",
      bpm: tempo,
      volume: 100,
      timeSignature: timeSignature,
      enableTickCallback: true,
    );

    metronome.tickStream.listen((tick) async {
      if (currentMode == "speeding_up" && await metronome.getBPM() != tempo) {
        if (tick == 0) {
          metronome.setBPM(tempo);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    metronome.destroy();
    gapClickTimer?.cancel();
    accelerationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.editableTimeSignature)
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
                    height: 150,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 150,
                          child: IntegerNumberPicker(
                            initialValue: selectedTimeSignature,
                            minValue: 2,
                            maxValue: 33,
                            onChanged: (newValue) {
                              setState(() {
                                selectedTimeSignature = newValue;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        selectedTimeSignature = timeSignature;
                        Navigator.of(context).pop();
                      },
                      child: Text("Exit"),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          timeSignature = selectedTimeSignature;
                          metronome.setTimeSignature(timeSignature);
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text("Save"),
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
                  borderRadius: BorderRadiusGeometry.all(Radius.circular(7)),
                ),
              ),
            ),
            child: Text(
              timeSignature.toString(),
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        Wrap(
          spacing: 7,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              tempo.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "BPM",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 10.0,
              thumbColor: Colors.orangeAccent,
              activeTrackColor: Colors.orange,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15.0),
            ),
            child: Slider(
              min: 10,
              max: 300,
              value: tempo.toDouble(),
              divisions: 500,
              onChanged: (newValue) {
                setState(() {
                  tempo = newValue.round();
                  targetTempo = tempo + increaseBpm;
                  HapticFeedback.mediumImpact();
                });
                if (!metronomeStopped) {
                  if (currentMode == "gap") {
                    gapClickTimer?.cancel();
                    startClickTimer();
                  } else if (currentMode == "speeding_up") {
                    accelerationTimer?.cancel();
                    startAccelerationTimer();
                  }
                }

                metronome.setBPM(tempo);
              },
            ),
          ),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Transform.scale(
              scale: 1.3,
              child: Checkbox(
                value: accentFirstBeat,
                onChanged: (checked) {
                  setState(() {
                    accentFirstBeat = checked!;
                  });

                  if (accentFirstBeat) {
                    metronome.setAudioFile(
                      accentedPath: "${currentSoundPath}_high.wav",
                    );
                  } else {
                    metronome.setAudioFile(
                      accentedPath: "${currentSoundPath}_low.wav",
                    );
                  }
                },
              ),
            ),
            Text(
              "Accent first beat",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        Wrap(
          spacing: 5,
          children: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(
                      "Practice settings",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: StatefulBuilder(
                      builder: (context, setDialogState) {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                "Gap Click",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Click Bars",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                ),
                              ),
                              Text(
                                selectedPlayingBars.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 7.0,
                                  thumbColor: Colors.orangeAccent,
                                  activeTrackColor: Colors.orange,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 9.0,
                                  ),
                                ),
                                child: Slider(
                                  min: 1,
                                  max: 30,
                                  value: selectedPlayingBars.toDouble(),
                                  divisions: 30,
                                  onChanged: (newValue) {
                                    setDialogState(() {
                                      selectedPlayingBars = newValue.round();
                                      HapticFeedback.mediumImpact();
                                    });
                                  },
                                ),
                              ),
                              Text(
                                "Gap Bars",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                ),
                              ),
                              Text(
                                selectedGapBars.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 7.0,
                                  thumbColor: Colors.orangeAccent,
                                  activeTrackColor: Colors.orange,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 9.0,
                                  ),
                                ),
                                child: Slider(
                                  min: 1,
                                  max: 30,
                                  value: selectedGapBars.toDouble(),
                                  divisions: 30,
                                  onChanged: (newValue) {
                                    setDialogState(() {
                                      selectedGapBars = newValue.round();
                                      HapticFeedback.mediumImpact();
                                    });
                                  },
                                ),
                              ),

                              Text(
                                "Accelerating Click",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Increase (BPM)",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                ),
                              ),
                              Text(
                                selectedIncrease.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 7.0,
                                  thumbColor: Colors.orangeAccent,
                                  activeTrackColor: Colors.orange,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 9.0,
                                  ),
                                ),
                                child: Slider(
                                  min: 1,
                                  max: 100,
                                  value: selectedIncrease.toDouble(),
                                  divisions: 100,
                                  onChanged: (newValue) {
                                    setDialogState(() {
                                      selectedIncrease = newValue.round();
                                      HapticFeedback.mediumImpact();
                                    });
                                  },
                                ),
                              ),
                              Text(
                                "In",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                ),
                              ),
                              Text(
                                "$selectedInterval minutes",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 7.0,
                                  thumbColor: Colors.orangeAccent,
                                  activeTrackColor: Colors.orange,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 9.0,
                                  ),
                                ),
                                child: Slider(
                                  min: 1,
                                  max: 30,
                                  value: selectedInterval.toDouble(),
                                  divisions: 30,
                                  onChanged: (newValue) {
                                    setDialogState(() {
                                      selectedInterval = newValue.round();
                                      HapticFeedback.mediumImpact();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          selectedGapBars = gapBars;
                          selectedPlayingBars = playingBars;
                          selectedIncrease = increaseBpm;
                          selectedInterval = increaseIntervalMins;
                          Navigator.of(context).pop();
                        },
                        child: Text("Exit"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            gapBars = selectedGapBars;
                            playingBars = selectedPlayingBars;
                            increaseBpm = selectedIncrease;
                            increaseIntervalMins = selectedInterval;
                            targetTempo = tempo + increaseBpm;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text("Save"),
                      ),
                    ],
                  ),
                  barrierDismissible: false,
                );
              },
              icon: Icon(Icons.settings, size: 30),
            ),
            SizedBox(
              width: 210,
              child: DropdownMenu(
                initialSelection: "click",
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: "click", label: "Click Only"),
                  DropdownMenuEntry(value: "gap", label: "Gap Click"),
                  DropdownMenuEntry(
                    value: "speeding_up",
                    label: "Accelerating Click",
                  ),
                ],
                enableSearch: false,
                enabled: metronomeStopped,
                textStyle: TextStyle(color: Colors.white, fontSize: 20),
                onSelected: (newValue) {
                  setState(() {
                    if (currentMode == "gap") {
                      gapClickTimer?.cancel();
                      currentGapBeat = 0;
                    } else if (currentMode == "speeding_up") {
                      accelerationTimer?.cancel();
                    }
                    currentMode = newValue!;
                  });
                },
                inputDecorationTheme: InputDecorationTheme(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  constraints: BoxConstraints.tight(const Size.fromHeight(50)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        DropdownMenu(
          width: 253,
          initialSelection: "assets/audio/quartz",
          dropdownMenuEntries: [
            DropdownMenuEntry(value: "assets/audio/quartz", label: "Quartz"),
            DropdownMenuEntry(value: "assets/audio/synth_tick", label: "Tick"),
            DropdownMenuEntry(value: "assets/audio/bell", label: "Cowbell"),
          ],
          enableSearch: false,
          textStyle: TextStyle(color: Colors.white, fontSize: 20),
          onSelected: (newValue) {
            setState(() {
              currentSoundPath = newValue!;
            });
            metronome.setAudioFile(
              mainPath: "${newValue}_low.wav",
              accentedPath: accentFirstBeat
                  ? "${newValue}_high.wav"
                  : "${newValue}_low.wav",
            );
          },
          inputDecorationTheme: InputDecorationTheme(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            constraints: BoxConstraints.tight(const Size.fromHeight(50)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
        ElevatedButton(
          onPressed: () {
            if (!metronomeStopped) {
              metronome.stop();
              if (currentMode == "gap") {
                gapClickTimer?.cancel();
              } else if (currentMode == "speeding_up") {
                accelerationTimer?.cancel();
              }
              setState(() {
                currentButtonIcon = Icons.play_arrow;
                metronomeStopped = true;
                currentGapBeat = 0;
              });
            } else {
              if (currentMode == "gap") {
                startClickTimer();
              } else if (currentMode == "speeding_up") {
                startAccelerationTimer();
              }
              metronome.play();
              setState(() {
                currentButtonIcon = Icons.stop;
                metronomeStopped = false;
              });
            }
          },
          style: ButtonStyle(
            shadowColor: WidgetStatePropertyAll(Colors.black),
            backgroundColor: WidgetStatePropertyAll(Colors.lightGreen),
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.all(Radius.circular(15)),
              ),
            ),
          ),
          child: Icon(currentButtonIcon, color: Colors.white, size: 35),
        ),
      ],
    );
  }
}
