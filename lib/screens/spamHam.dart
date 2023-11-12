import 'package:app/screens/messageScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

import '../Model.dart';
import '../constants/constants.dart';

class SpamHamScreen extends StatelessWidget {
  SpamHamScreen(this.isSpam);

  bool isSpam;

  @override
  Widget build(BuildContext context) {
    var messages = isSpam ? allSpamMessageListTemp : allHamMessageListTemp;
    return Scaffold(
      appBar: AppBar(
        title: isSpam?const Text("Spam Messages"):const Text("Ham Messages"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,

        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSpam ? "Spam Messages:" : "Ham Messages:",
              style: const TextStyle(color: Color(0xff747474),fontSize: 15),
            ),
            SizedBox20,
            SizedBox(
              height: MediaQuery.of(context).size.height - 156-15-1,
              child: ListView.builder(
                itemCount: messages.keys.length,
                itemBuilder: (BuildContext context, int index) {
                  String KEY = messages.keys.toList()[index];
                  var msg = messages[KEY]?.first;
                  return MessageWidget(msg!, KEY, isSpam);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  MessageWidget(this.msg, this.KEY, this.isSpam);

  SmsMessage msg;
  String KEY;
  bool isSpam;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => MessageScreen(KEY,isSpam),
          ),
        );
      },
      child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle,
                color: Color(0xff747474),
                size: 50,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(msg.address!),
                  const SizedBox(
                    width: 10,
                    height: 5,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 130,
                    child: Text(
                      msg.body!,
                      style: const TextStyle(
                        color: Color(0xff747474),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
