// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:audioplayers/audioplayers.dart';

Future azuretts() async {
  // Add your function code here!
  try {
    //Load configs
    AzureTts.init(
        subscriptionKey: "b53547a6971a4fe88237ac89a56b44bc",
        region: "eastus",
        withLogs: true);

    // Get available voices
    final voicesResponse = await AzureTts.getAvailableVoices();
    final voices = voicesResponse.voices;

    //Print all available voices
    print("$voices");

    //Pick an English Neural Voice
    final voice = voicesResponse.voices
        .where((element) => element.locale.startsWith("en-"))
        .toList(growable: false)
        .first;

    //Generate Audio for a text
    final text = FFAppState().tts;

    TtsParams params = TtsParams(
        voice: voice,
        audioFormat: AudioOutputFormat.audio16khz32kBitrateMonoMp3,
        rate: 1.2, // optional prosody rate (default is 1.0)
        text: text);

    final ttsResponse = await AzureTts.getTts(params);

    //Get the audio bytes.
    final audioBytes = ttsResponse.audio.buffer
        .asUint8List(); // you can save to a file for playback
    print(
        "Audio size: ${(audioBytes.lengthInBytes / (1024 * 1024)).toStringAsPrecision(2)} Mb");

    // Get the directory for storing files
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/azure_tts_audio.mp3';

    // Save audio bytes to a file on device
    final audioFile = File(filePath);
    await audioFile.writeAsBytes(audioBytes);

    // Play the audio file
    final player = AudioPlayer();
    await player.play(DeviceFileSource(filePath));
  } catch (e) {
    print("Something went wrong: $e");
  }
}
