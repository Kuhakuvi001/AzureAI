import 'package:flutter/material.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  bool _voice = false;
  bool get voice => _voice;
  set voice(bool value) {
    _voice = value;
  }

  String _stt = '';
  String get stt => _stt;
  set stt(String value) {
    _stt = value;
  }

  String _sstSendText = '';
  String get sstSendText => _sstSendText;
  set sstSendText(String value) {
    _sstSendText = value;
  }

  dynamic _response;
  dynamic get response => _response;
  set response(dynamic value) {
    _response = value;
  }

  String _tts = 'tts';
  String get tts => _tts;
  set tts(String value) {
    _tts = value;
  }

  bool _language = false;
  bool get language => _language;
  set language(bool value) {
    _language = value;
  }
}
