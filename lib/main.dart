import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

void main() => runApp(MyApp());
class Tokenizer {
  Map<String, int> wordIndex={};

  Tokenizer(Map<String, dynamic> json) {
    wordIndex = Map<String, int>.from(jsonDecode(json["config"]["word_index"]));
  }

  List<int> encode(String text) {
    var words = text.toLowerCase().split(' ');
    var sequence = words.map((word) => wordIndex[word] ?? 0).toList();
    return sequence;
  }
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Interpreter interpreter;
  late Tokenizer tokenizer;

  @override
  void initState() {
    super.initState();
    // loadTokenizer();
    loadTokenizer().then((value) {
       loadModelAndTokenizer();
    });
  }
  Future<void> loadTokenizer() async {
    // Read the JSON file containing tokens
    String jsonString = await DefaultAssetBundle.of(context).loadString('assets/tokenizer.json');
    Map<String, dynamic> json = jsonDecode(jsonString);

    // Create a Tokenizer instance from the JSON data
    tokenizer = Tokenizer(json);

    // Example message to encode
    String message = "Congratulations! You've won a free gift card.";

    // Encode the message using the tokenizer
    List<int> sequence = tokenizer.encode(message);

    // Print the encoded sequence
    print("Encoded Sequence: $sequence");
  }
  Future<void> loadModelAndTokenizer() async {
    // Load the TFLite model
    interpreter = await Interpreter.fromAsset('assets/model.tflite');

    // Load the tokenizer
    // tokenizer = Tokenizer();

    // Test the model with custom messages
    List<String> customMessages = [
      "Congratulations! You've won a free gift card.",
      "Hello my friend"
    ];

    for (String message in customMessages) {
      List<int> sequence = tokenizer.encode(message);
      List<int> paddedSequence = padSequence(sequence, 100);
      var input = [paddedSequence.map((value) => value.toDouble()).toList()];
      var output = List.filled(1 * 1, 0).reshape([1, 1]);

      interpreter.run(input, output);
      var prediction = output[0][0];
      var label = (prediction > 0.5) ? "spam" : "ham";

      print("Message: $message\nPredicted Label: $label\n");
    }
  }

  List<int> padSequence(List<int> sequence, int maxLength) {
    if (sequence.length >= maxLength) {
      return sequence.sublist(0, maxLength);
    } else {
      var paddedSequence = List<int>.filled(maxLength, 0);
      for (int i = 0; i < sequence.length; i++) {
        paddedSequence[i] = sequence[i];
      }
      return paddedSequence;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter TFLite Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Load model and tokenizer when the button is pressed
            loadModelAndTokenizer();
          },
          child: Text('Load Model and Tokenizer'),
        ),
      ),
    );
  }
}


