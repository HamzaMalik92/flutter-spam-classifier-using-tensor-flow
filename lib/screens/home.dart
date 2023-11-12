import 'dart:convert';

import 'package:app/screens/aboutUs.dart';
import 'package:app/screens/spamHam.dart';
import 'package:app/screens/testScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../Model.dart';
import '../constants/constants.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Interpreter interpreter;
  late Tokenizer tokenizer;
  bool isLoaded=false;
  @override
  void initState() {
    super.initState();
    requestSmsPermission();
  }
  Future<void> loadTokenizer() async {
    // Read the JSON file containing tokens
    String jsonString = await DefaultAssetBundle.of(context).loadString('assets/tokenizer.json');
    Map<String, dynamic> json = jsonDecode(jsonString);
    tokenizer = Tokenizer(json);
  }
  Future<void> loadModelAndTokenizer() async {
    allHamMessageListTemp={};
    allSpamMessageListTemp={};

    // Load the TFLite model
    interpreter = await Interpreter.fromAsset('assets/model.tflite');

    for(String key in messagesSorted.keys){
      if(messagesSorted[key]==null){
        continue;
      }
      for (int i=0;i<messagesSorted[key]!.length;i++) {
        if(i>0&&messagesSorted[key]![i-1].id==1){
          messagesSorted[key]![0].id=1;
          break;
        }
        String message=messagesSorted[key]![i].body??"";
        List<int> sequence = tokenizer.encode(message);
        List<int> paddedSequence = padSequence(sequence);
        var input = [paddedSequence.map((value) => value.toDouble()).toList()];
        var output = List.filled(1 * 1, 0).reshape([1, 1]);
        try{
          interpreter.run(input, output);
        }catch(e){
          print(e);
        }
        var prediction = output[0][0];
        var label = (prediction > 0.5) ? 1 : 0;
        messagesSorted[key]![i].id=label;
        print("Message: $message\nPredicted Label: $label\n");
      }
    }

    for(String key in messagesSorted.keys){
      if(messagesSorted[key]![0].id==1){
        if(messagesSorted[key]!=null) {
          allSpamMessageListTemp[key]=messagesSorted[key]!;
        }
      }else{
        if(messagesSorted[key]!=null) {
          allHamMessageListTemp[key]=messagesSorted[key]!;
        }
      }
    }

  }



  Future<void> readMsg() async {

    SmsQuery query = SmsQuery();
    // Get all SMS of user
    List<SmsMessage> messages = await query.getAllSms;
    messagesSorted=groupAndSortMessages(messages);
  }
  late Map<String, List<SmsMessage>> messagesSorted;
  Map<String, List<SmsMessage>> groupAndSortMessages(List<SmsMessage> messages) {
    // Create a Map to store grouped messages by address
    Map<String, List<SmsMessage>> groupedMessages = {};

    // Group messages by address
    for (SmsMessage message in messages) {
      String address = message.address!;
      if (groupedMessages.containsKey(address)) {
        groupedMessages[address]!.add(message);
      } else {
        groupedMessages[address] = [message];
      }
    }

    // Sort messages within each group by date
    groupedMessages.forEach((address, messagesList) {
      messagesList.sort((a, b) => b.date!.compareTo(a.date!));
    });

    // Sort groups based on the latest message within each group
    var sortedGroups = groupedMessages.keys.toList()
      ..sort((a, b) {
        var latestMessageA = groupedMessages[a]!.isEmpty
            ? DateTime(0)
            : groupedMessages[a]!.first.date!;
        var latestMessageB = groupedMessages[b]!.isEmpty
            ? DateTime(0)
            : groupedMessages[b]!.first.date!;
        return latestMessageB.compareTo(latestMessageA);
      });

    // Create a Map to store sorted groups and messages
    Map<String, List<SmsMessage>> sortedData = {};
    sortedGroups.forEach((address) {
      sortedData[address] = groupedMessages[address]!;
    });

    // Return sorted groups and messages within each group
    return sortedData;
  }

  void requestSmsPermission() async {
    isLoaded=true;

    // Request SMS permission
    PermissionStatus status = await Permission.sms.request();
    if (status.isGranted) {
      // Permission granted, retrieve SMS messages
      readMsg().then((value) {
        // run below code when readMsg function is executed
        loadTokenizer().then((value) {
          // run below code when loadTokenizer function is executed
          loadModelAndTokenizer().then((value) {
            setState(() {
              isLoaded=false;
            });
          });
        });
      });
    } else {
      // Permission denied (show an error message)
      print('SMS permission denied');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMS Spam Detection"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          requestSmsPermission();
        },
        child: const Icon(Icons.refresh),
      ),
      body:
      isLoaded?
      const Center(
        child: CircularProgressIndicator(
        ),
      ):
      Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quick Links",
              style: TextStyle(color: Color(0xff747474),fontSize: 15),
            ),
            SizedBox20,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    DashboardCard("Spam", Icons.block, Colors.red),
                    SizedBox20,
                    DashboardCard("Test", Icons.terminal_sharp, Colors.teal),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    DashboardCard("Ham", Icons.message_outlined, Colors.green),
                    SizedBox20,
                    DashboardCard("About us", Icons.info_outline, Colors.blue),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class DashboardCard extends StatelessWidget {
  DashboardCard(this.txt, this.icon, this.iconClr);
  String txt;
  IconData icon;
  Color iconClr;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (txt == "Spam") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => SpamHamScreen(true),
            ),
          );
        } else if (txt == "Ham") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => SpamHamScreen(false),
            ),
          );
        } else if (txt == "Test") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => TestScreen(),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => const AboutScreen(),
            ),
          );
        }

      },
      child: Container(
        height: 120,
        width: MediaQuery.sizeOf(context).width / 2 - 30,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconClr,
              size: 28,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              txt,
              style: TextStyle(color: iconClr,
                fontSize: 16, // Adjust text size
              ),
            )
          ],
        ),
      ),
    );
  }
}
