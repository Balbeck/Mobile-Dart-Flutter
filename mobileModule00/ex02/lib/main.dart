import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ex02 - Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 113, 40, 240),
        ),
      ),
      home: const MyCalculatorPage(),
    );
  }
}

class MyCalculatorPage extends StatelessWidget {
  const MyCalculatorPage({super.key});

  void onButtonPressed(String buttonText) {
    debugPrint('Button pressed: $buttonText');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Calculator'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: const [
                ExpressionField(),
                SizedBox(height: 16),
                ResultField(),
                SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 5,
              children: [
                _buildButton('7', onButtonPressed, Colors.black),
                _buildButton('8', onButtonPressed, Colors.black),
                _buildButton('9', onButtonPressed, Colors.black),
                _buildButton(
                  'C',
                  onButtonPressed,
                  const Color.fromARGB(255, 255, 88, 88),
                ),
                _buildButton(
                  'AC',
                  onButtonPressed,
                  const Color.fromARGB(255, 255, 88, 88),
                ),
                _buildButton('4', onButtonPressed, Colors.black),
                _buildButton('5', onButtonPressed, Colors.black),
                _buildButton('6', onButtonPressed, Colors.black),
                _buildButton('+', onButtonPressed, Colors.white),
                _buildButton('-', onButtonPressed, Colors.white),
                _buildButton('1', onButtonPressed, Colors.black),
                _buildButton('2', onButtonPressed, Colors.black),
                _buildButton('3', onButtonPressed, Colors.black),
                _buildButton('*', onButtonPressed, Colors.white),
                _buildButton('/', onButtonPressed, Colors.white),
                _buildButton('0', onButtonPressed, Colors.black),
                _buildButton('.', onButtonPressed, Colors.black),
                _buildButton('00', onButtonPressed, Colors.black),
                _buildButton('=', onButtonPressed, Colors.white),
                Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildButton(
  String buttonText,
  Function(String) onPressed,
  Color textColor,
) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      onPressed: () => onPressed(buttonText),
      child: Text(buttonText, style: TextStyle(color: textColor)),
    ),
  );
}

class ExpressionField extends StatelessWidget {
  const ExpressionField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: '0'),
      textAlign: TextAlign.right,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(filled: true, fillColor: Colors.blue),
    );
  }
}

class ResultField extends StatelessWidget {
  const ResultField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: '0'),
      textAlign: TextAlign.right,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(filled: true, fillColor: Colors.blue),
    );
  }
}
