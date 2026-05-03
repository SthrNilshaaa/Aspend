import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  bool get isEnabled => _speechEnabled;
  bool get isListening => _speechToText.isListening;
  String get lastWords => _lastWords;

  Future<bool> initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) => debugPrint('Speech Status: $status'),
      onError: (errorNotification) => debugPrint('Speech Error: $errorNotification'),
    );
    return _speechEnabled;
  }

  Future<void> startListening(Function(String) onResult) async {
    _lastWords = '';
    await _speechToText.listen(
      onResult: (SpeechRecognitionResult result) {
        _lastWords = result.recognizedWords;
        onResult(_lastWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  void cancelListening() {
    _speechToText.cancel();
  }
}
