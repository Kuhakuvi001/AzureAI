// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:io';
import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class NewCustomWidget extends StatefulWidget {
  const NewCustomWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<NewCustomWidget> createState() => _NewCustomWidgetState();
}

class _NewCustomWidgetState extends State<NewCustomWidget> {
  SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isProcessing = false; // Flag to track processing state
  String _text = '';
  late AudioPlayer _audioPlayer = AudioPlayer();
  List<LocaleName> _localeNames = [];

  @override
  void initState() {
    super.initState();
    initSpeechState();
    AzureTts.init(
      subscriptionKey: "766dc495f7b44895b658dc4fa7299a4b",
      region: "eastus",
      withLogs: true,
    );
    startListening(); // Start listening automatically when component initializes
  }

  void initSpeechState() async {
    bool hasSpeech = await _speech.initialize();
    if (!hasSpeech) {
      print('Speech recognition not available');
    }
  }

  Future<bool> _isIndonesianInstalled() async {
    for (var locale in _localeNames) {
      if (locale.localeId == 'in_ID') {
        return true;
      }
    }
    return false;
  }

  void startListening() {
    setState(() {
      _isListening = true;
      _isSpeaking = false;
      _isProcessing = false;
    });

    String output = '';
    bool _onDevice = false;
    final TextEditingController _pauseForController =
        TextEditingController(text: '3');
    final TextEditingController _listenForController =
        TextEditingController(text: '30');
    double minSoundLevel = 50000;
    double maxSoundLevel = -50000;
    String _currentLocaleId = '';
    final SpeechToText speech = SpeechToText();

    _listenForController.addListener(() {
      // Handle changes in listenForController
    });

    _pauseForController.addListener(() {
      // Handle changes in pauseForController
    });

    Future<void> listen() async {
      bool isInitialized = await speech.initialize();

      if (isInitialized) {
        _localeNames = await speech.locales();
        print("Locale");

        for (var loc in _localeNames) {
          print(loc.name + "..." + loc.localeId);
        }
        ;
        var systemLocale = await speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? '';

        if (FFAppState().language) {
          if (await _isIndonesianInstalled()) {
            _currentLocaleId = 'in_ID';
          }
        }

        final pauseFor = int.tryParse(_pauseForController.text);
        final listenFor = int.tryParse(_listenForController.text);
        speech.listen(
          onResult: (result) {
            if (!result.finalResult) {
              setState(() {
                _text = result.recognizedWords;
              });
            } else {
              setState(() {
                _text = result.recognizedWords;
                _makeApiCall(_text); // Call API with the recognized text
              });
            }
          },
          listenFor: Duration(seconds: listenFor ?? 30),
          pauseFor: Duration(seconds: pauseFor ?? 3),
          partialResults: true,
          localeId: _currentLocaleId,
          onSoundLevelChange: (level) {
            minSoundLevel = min(minSoundLevel, level);
            maxSoundLevel = max(maxSoundLevel, level);
            level = level;
          },
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
          onDevice: _onDevice,
        );
      }
    }

    listen();
  }

  void stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _makeApiCall(String text) async {
    try {
      setState(() {
        _isSpeaking = false;
        _isListening = false;
        _isProcessing = true; // Set to true when converting text to speech
      });

      //Api call to azure boat
      String apiUrl =
          'https://shs-bot-ai.openai.azure.com/openai/deployments/shsdemo-gpt-35-turbo/chat/completions?api-version=2024-02-15-preview';
      Map<String, String> headers = {
        'api-key':
            '648d5b6ef5ee4a178ca448edcfc4491e', //change your api key here
        'Content-Type': 'application/json',
      };

      // Request body
      Map<String, dynamic> requestBody = {
        "messages": [
          {
            "role": "system",
            "content":
                "You are an AI assistant that helps people find information."
          },
          {"role": "user", "content": text},
        ],
        "max_tokens": 1000,
        "temperature": 0.7,
        "frequency_penalty": 0,
        "presence_penalty": 0,
        "top_p": 0.95,
        "stop": null
      };

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print('api response $response');

      if (response.statusCode == 200) {
        // Successful API call
        var responseBody = jsonDecode(response.body);
        final apiResponse = responseBody['choices'][0]['message']['content'];
        print('print result $apiResponse');
        if (apiResponse != null) {
          _convertTextToSpeech(apiResponse.toString());
        } else {
          _convertTextToSpeech('No response from the API');
        }
      } else {
        // API call failed
        print("API call failed");
        _convertTextToSpeech('API Call failed');
      }
    } catch (e) {
      _convertTextToSpeech('API Call Error: $e');
    }
  }

  Future<void> _convertTextToSpeech(String text) async {
    try {
      final voicesResponse = await AzureTts.getAvailableVoices();
      final voices = voicesResponse.voices;

      final voice = voicesResponse.voices
          .where((element) => FFAppState().language
              ? element.locale.startsWith("id-")
              : element.locale.startsWith("en-"))
          .toList(growable: false)
          .first;

      TtsParams params = TtsParams(
        voice: voice,
        audioFormat: AudioOutputFormat.audio16khz32kBitrateMonoMp3,
        rate: 1.1,
        text: text,
      );

      final ttsResponse = await AzureTts.getTts(params);

      final audioBytes = ttsResponse.audio.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/azure_tts_audio.mp3';

      final audioFile = File(filePath);
      await audioFile.writeAsBytes(audioBytes);

      _audioPlayer = AudioPlayer();
      setState(() {
        _isProcessing = false;
        _text = text;
        _isSpeaking = true; // Widget is speaking
      });

      await _audioPlayer.play(DeviceFileSource(filePath));

      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          _isProcessing = false; // Update UI to reflect speech stopped
          _isSpeaking = false;
          _isListening = true;
          _text = '';
          startListening();
        });
      });
    } catch (e) {
      print("Text to Speech Error: $e");
      setState(() {
        _isProcessing = false; // Reset flag after processing
        _isSpeaking = false;
      });
    }
  }

  void stopSpeech() {
    if (_audioPlayer != null) {
      _audioPlayer.stop();
      setState(() {
        _isProcessing = false; // Update UI to reflect speech stopped
        _isSpeaking = false;
        _isListening = true;
        _text = '';
        startListening();
      });
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _audioPlayer.dispose(); // Dispose the audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        iconTheme: IconThemeData(
          color: FlutterFlowTheme.of(context)
              .info, // Change the color of the back button icon
        ),
      ),
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _isListening
                  ? 'Listening...'
                  : _isProcessing
                      ? 'Processing...'
                      : _isSpeaking
                          ? 'Speaking...'
                          : 'Click to Start Listening',
              style: TextStyle(
                  fontSize: 18.0,
                  color: FlutterFlowTheme.of(context).primaryText),
            ),
            SizedBox(height: 20.0),
            SizedBox(
              height: 150.0, // Limit the height for the text display
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    _text,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            if (_isSpeaking)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: IconButton(
                  onPressed: stopSpeech,
                  icon: Icon(Icons.cancel,
                      color: FlutterFlowTheme.of(context)
                          .primaryText), // Icon color is white
                  iconSize: 48.0,
                  padding: EdgeInsets.all(20.0),
                ),
              )
            else if (_isListening)
              IconButton(
                onPressed: null,
                icon: Icon(Icons.mic,
                    color: FlutterFlowTheme.of(context).primaryText),
                color: Colors.blue,
                iconSize: 48.0,
                padding: EdgeInsets.all(20.0),
                splashRadius: 50.0,
              )
            else if (_isProcessing)
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary),
              )
            else
              IconButton(
                onPressed: startListening,
                icon: Icon(Icons.mic,
                    color: FlutterFlowTheme.of(context).primaryText),
                color: Colors.blue,
                iconSize: 48.0,
                padding: EdgeInsets.all(20.0),
                splashRadius: 50.0,
              )
          ],
        ),
      ),
    );
  }
}
