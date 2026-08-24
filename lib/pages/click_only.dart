import 'package:drum_chief/widgets/metronome.dart';
import 'package:flutter/material.dart';

class MetronomeScreen extends StatefulWidget {
  const MetronomeScreen({super.key});

  @override
  State<MetronomeScreen> createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends State<MetronomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            "METRONOME",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      body: SingleChildScrollView(
        child: Center(
          child: MetronomeInterface()
        ),
      ),
    );
  }
}