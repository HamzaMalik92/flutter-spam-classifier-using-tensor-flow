import 'package:flutter/material.dart';

import '../constants/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Information about the app",
              style: TextStyle(color: Color(0xff747474), fontSize: 15),
            ),
            SizedBox20,
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AboutItem(
                        question: "How does the spam detection work?",
                        answer:
                            "Our spam detection uses a machine learning model to analyze the content of messages. "
                            "The model has been trained on a dataset to distinguish between spam and non-spam (ham) messages.",
                      ),
                      Divider(),
                      AboutItem(
                        question:
                            "How often is the spam detection model updated?",
                        answer:
                            "The spam detection model is trained on a pre-existing dataset. "
                            "It may not be updated in real-time, but updates can be applied periodically to improve accuracy.",
                      ),
                      Divider(),

                      AboutItem(
                        question:
                            "Can I customize the spam detection settings?",
                        answer:
                            "Currently, we do not provide customization options for the spam detection settings. "
                            "The model is trained to work effectively for a wide range of users.",
                      ),
                      Divider(),
                      AboutItem(
                        question:
                            "How can I report false positives or false negatives?",
                        answer:
                            "If you encounter false positives (legitimate messages marked as spam) or false negatives (spam messages not detected), "
                            "please contact our support team with details so that we can improve the system.",
                      ),
                      Divider(),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutItem extends StatelessWidget {
  final String question;
  final String answer;

  AboutItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            answer,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
