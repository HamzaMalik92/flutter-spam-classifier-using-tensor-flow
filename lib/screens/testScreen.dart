import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../Model.dart';
import '../constants/constants.dart';

class TestScreen extends StatefulWidget {
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late Interpreter interpreter;
  late Tokenizer tokenizer;
  bool isLoaded=false;
  @override
  void initState() {
    super.initState();
      loadTokenizer().then((value) {
        loadModelAndTokenizer();
    });
  }
  Future<void> loadTokenizer() async {
    // Read the JSON file containing tokens
    String jsonString = await DefaultAssetBundle.of(context).loadString('assets/tokenizer.json');
    Map<String, dynamic> json = jsonDecode(jsonString);
    tokenizer = Tokenizer(json);
  }
  Future<void> loadModelAndTokenizer() async {
    // Load the TFLite model
    interpreter = await Interpreter.fromAsset('assets/model.tflite');
  }
  TextEditingController txtContrl=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test SMS Spam Detection"),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Test your messages below to see if they are classified as Spam or Ham.",
              style: TextStyle(color: Color(0xff747474),fontSize: 15),
            ),
            SizedBox20,
            TextField(
              controller: txtContrl,
              maxLines: 5,
              decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: InputBorder.none),
            ),
            SizedBox20,
            SizedBox20,
            GestureDetector(
              onTap: () {
                if(txtContrl.text.isEmpty){
                  return;
                }
                String message=txtContrl.text;
                List<int> sequence = tokenizer.encode(message);
                List<int> paddedSequence = padSequence(sequence);
                var input = [paddedSequence.map((value) => value.toInt()).toList()];
                var output = List.filled(1 * 1, 0).reshape([1, 1]);
                try{
                  interpreter.run(input, output);
                }catch(e){
                  print(e);
                }
                double prediction = output[0][0];
                var label = (prediction > 0.5) ? "spam" : "ham";
                print("Predicted Label: $label and Predicted %: ${prediction.toStringAsFixed(4)}");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.blue,
                    elevation: 6.0,
                    behavior: SnackBarBehavior.floating,
                    content: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Prediction Result",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Predicted Label: $label',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Confidence Level: ${prediction.toStringAsFixed(2)}%',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(15),
                  ),
                );


              },
              child: Container(
                alignment: Alignment.center,
                height: 50,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10)),
                child: const Text(
                  "Classify",
                  style: TextStyle(color: Colors.white),
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }
}
