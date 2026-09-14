import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hello_world_app/main.dart';

class CounterFunctionsScreen extends StatefulWidget {
  const CounterFunctionsScreen({super.key});

  @override
  State<CounterFunctionsScreen> createState() => _CounterFunctionsScreenState();
}

class _CounterFunctionsScreenState extends State<CounterFunctionsScreen> {

  int clickCounter = 0;

  Color _getCounterColor(int value) {
    if (value == 0) {
      return counterZeroColor;
    } else if (value > 0) {
      return counterPositiveColor;
    } else {
      return counterNegativeColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Functions'),
        actions: [
        IconButton(
          icon: Icon( Icons.refresh_rounded),
          onPressed: () {
            setState(() {
              clickCounter = 0;
            });
          },
        ),
        ],
      ),
      body: Center(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text(
              '$clickCounter',
              style: GoogleFonts.rockSalt(
                fontSize: 160,
                fontWeight: FontWeight.w100,
                color: _getCounterColor(clickCounter),
              ),
            ),
            Text(
              "Click${ clickCounter > 1 ? 's' : '' }",
              style: const TextStyle(fontSize: 25),
            ),
            ],
          ),
        )
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                clickCounter += 1;
              });
            },
            child: Icon(Icons.plus_one),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                clickCounter -= 1;
              });
            },
            child: Icon(Icons.remove),
          ),
        ],
      )
    );
  }
}