import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

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

class MyCalculatorPage extends StatefulWidget {
  const MyCalculatorPage({super.key});

  @override
  State<MyCalculatorPage> createState() => _MyCalculatorPageState();
}

class _MyCalculatorPageState extends State<MyCalculatorPage> {
  String strCalcul = '0';
  final TextEditingController resultFieldController = TextEditingController(
    text: '0',
  );

  @override
  void dispose() {
    resultFieldController.dispose();
    super.dispose();
  }

  void onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        strCalcul = '0';
        resultFieldController.text = '0';
      } else if (buttonText == 'C') {
        if (strCalcul.isNotEmpty && strCalcul != '0') {
          strCalcul = strCalcul.length > 1
              ? strCalcul.substring(0, strCalcul.length - 1)
              : '0';
        }
      } else if (buttonText == '=') {
        try {
          double result = evaluateExpression(strCalcul);
          resultFieldController.text = result.toString();
        } catch (e) {
          resultFieldController.text = 'Error';
        }
      } else {
        if (strCalcul == '0' && ['+', '-'].contains(buttonText)) {
          strCalcul = buttonText;
        } else if (strCalcul == '0' &&
            !['+', '-', '*', '/', '.'].contains(buttonText)) {
          strCalcul = buttonText;
        } else {
          strCalcul += buttonText;
        }
      }
    });
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
              children: [
                ExpressionField(strCalcul: strCalcul),
                SizedBox(height: 16),
                ResultField(controller: resultFieldController),
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
  final String strCalcul;

  const ExpressionField({super.key, required this.strCalcul});

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(
        text: strCalcul.isEmpty ? '' : strCalcul,
      ),
      textAlign: TextAlign.right,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(filled: true, fillColor: Colors.blue),
    );
  }
}

class ResultField extends StatelessWidget {
  final TextEditingController controller;

  const ResultField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: controller,
      textAlign: TextAlign.right,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(filled: true, fillColor: Colors.blue),
    );
  }
}

double evaluateExpression(String expression) {
  try {
    final parser = ShuntingYardParser();
    final parsedExpression = parser.parse(expression);
    final context = ContextModel();
    final result = parsedExpression.evaluate(EvaluationType.REAL, context);
    return result;
  } catch (e) {
    throw Exception("Invalid expression");
  }
}
