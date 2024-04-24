// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_tts/flutter_tts.dart';

FlutterTts flutterTts = FlutterTts();
Future talkToMe(bool? flag) async {
  if (flag == true) {
    flutterTts.stop();
  }
  // Set speech rate (words per minute) to emulate natural speech pace
  await flutterTts.setSpeechRate(0.6); // Slightly slower than normal pace
  // Set pitch variation for a more lifelike voice
  await flutterTts.setPitch(1.2); // Adds a subtle variation in pitch
  // Adjust volume to a natural level
  await flutterTts
      .setVolume(0.8); // Slightly reduced volume for a more natural effect

  // Set language and voice
  await flutterTts.setLanguage("en-US");
  // Set the voice to a female version if available
  await flutterTts
      .setVoice({"name": "female"}); // Example: Setting voice to female

  String text = FFAppState().tts;
  await flutterTts.speak(text);
  return flutterTts;
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
