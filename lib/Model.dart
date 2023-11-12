import 'dart:convert';

import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class Tokenizer {
  Map<String, int> wordIndex={};

  Tokenizer(Map<String, dynamic> json) {
    wordIndex = Map<String, int>.from(jsonDecode(json["config"]["word_index"]));
  }

  List<int> encode(String text) {
    var filteredText = cleanText(text);
    var words = filteredText.toLowerCase().split(' ').where((word) => word.isNotEmpty).toList();
    var sequence = words.map((word) => wordIndex[word] ?? 0).toList();

    return sequence;
  }
}


Map<String, List<SmsMessage>> allSpamMessageListTemp = {};
Map<String, List<SmsMessage>> allHamMessageListTemp = {};

List<int> padSequence(List<int> sequence) {
  const maxLength=171;
  if (sequence.length >= maxLength) {
    return sequence.sublist(0, maxLength);
  } else {
    var paddedSequence = List<int>.filled(maxLength, 0);
    int j=0;
    for (int i = maxLength-sequence.length; i < maxLength; i++) {
      paddedSequence[i] = sequence[j];
      j++;
    }
    return paddedSequence;
  }
}

String cleanText(String text) {
  RegExp whitespace = RegExp(r"\s+");
  RegExp webAddress = RegExp(r"http(s)?:\/\/[a-z0-9.~_\\/-]+", caseSensitive: false);
  RegExp user = RegExp(r"@([a-z0-9_]+)", caseSensitive: false);

  text = text.replaceAll('.', '');
  text = text.replaceAll(whitespace, ' ');
  text = text.replaceAll(webAddress, '');
  text = text.replaceAll(user, '');
  text = text.replaceAll(RegExp(r"\[[^()]*\]"), "");
  text = text.replaceAll(RegExp(r"\d+"), "");
  text = text.replaceAll(RegExp(r'[^\w\s]'), '');
  text = text.replaceAll(RegExp(r"(?:@\S*|#\S*|http(?=.*://)\S*)"), "");

  return text.toLowerCase();
}


