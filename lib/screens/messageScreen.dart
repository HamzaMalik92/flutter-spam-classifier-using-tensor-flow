import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';

import '../Model.dart';
import '../constants/constants.dart';

class MessageScreen extends StatelessWidget {
  MessageScreen(this.KEY, this.isSpam);

  String KEY;
  bool isSpam;

  @override
  Widget build(BuildContext context) {
    List<SmsMessage> messages = isSpam
        ? allSpamMessageListTemp[KEY] ?? []
        : allHamMessageListTemp[KEY] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text(messages.isNotEmpty && messages.first.address!.isNotEmpty
            ? messages.first.address!
            : ""),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSpam ? "Spam Messages:" : "Ham Messages:",
              style: const TextStyle(color: Color(0xff747474), fontSize: 15),
            ),
            SizedBox20,
            SizedBox(
              height: MediaQuery.of(context).size.height - 156 - 15 - 1,
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  var msg = messages[index];
                  return MessageWidget(msg, KEY, isSpam);
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
    DateTime UnFormattedDate = msg.date!;
    // Format DateTime to "11 Oct 2023 12:11PM"
    String date = DateFormat('dd MMM yyyy hh:mm a').format(UnFormattedDate);
    return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 130,
                  child: Text(
                    msg.body!,
                    style: const TextStyle(
                      color: Color(0xff747474),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 20,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 130,
                  child: Text(
                    date,
                    style: const TextStyle(
                      color: Color(0xFFAFAFAF),
                      fontStyle: FontStyle.italic,
                      fontSize: 13
                    ),
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
