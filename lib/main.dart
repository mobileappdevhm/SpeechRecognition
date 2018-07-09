import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'dart:math';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SpeechRecognition _speech;

  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  String transcription = '';

  String _currentLocale = 'en_US';
  //String _currentLocale = 'fr_FR';


  @override
  initState() {
    super.initState();
    activateSpeechRecognizer();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void activateSpeechRecognizer() {
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setCurrentLocaleHandler(onCurrentLocale);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech
        .activate()
        .then((res) => setState(() => _speechRecognitionAvailable = res));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Question Master',
              style: TextStyle(letterSpacing: 2.0)),
          backgroundColor: Color.fromRGBO(255, 179, 186, 100.0),
        ),
        body: Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildTextCard()),
                  _buildButton(
                    onPressed: _speechRecognitionAvailable && !_isListening
                        ? () => start()
                        : null,
                    label: _isListening
                        ? 'Listening...'
                        : 'Listen ($_currentLocale)',
                  ),
                  _buildAnswerTile(
                    label: _isListening ? '...' : printAnswer(),
                  ),
                  _buildButton(
                    onPressed: _isListening ? () => stop() : null,
                    label: 'Stop',
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildTextCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const ListTile(
            leading: const Icon(Icons.album),
            title: const Text('Ask me a Yes or No question.'),
            subtitle: const Text('Mobile Dev Demo'),
          ),
          Text(transcription,
              style: TextStyle(fontSize: 24.0), textAlign: TextAlign.center)
        ],
      ),
    );
  }

Widget _buildAnswerTile({String label}) => Padding(
  padding: const EdgeInsets.all(12.0),
  child: ListTile(
      title: const Text('The answer is: '),
      subtitle: Text(label, style: const TextStyle(color: Colors.black, letterSpacing: 2.0)))
); 

  Widget _buildButton({String label, VoidCallback onPressed}) => Padding(
      padding: EdgeInsets.all(12.0),
      child: RaisedButton(
        color: Color.fromRGBO(0, 91, 150, 100.0),
        shape: new RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0)),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, letterSpacing: 2.0),
        ),
      ));

  String printAnswer() {
    String answer = "NO";
    var rng = Random();
    if ((rng.nextInt(100) % 2) == 0) {
      answer = "YES";
    }
    return answer;
  }

  void start() => _speech
      .listen(locale: 'en_US') //fr_FR
      .then((result) => print('_MyAppState.start => result ' + result));

  void cancel() =>
      _speech.cancel().then((result) => setState(() => _isListening = result));

  void stop() =>
      _speech.stop().then((result) => setState(() => _isListening = result));

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onCurrentLocale(String locale) =>
      setState(() => _currentLocale = 'en_US'); // fr_FR

  void onRecognitionStarted() => setState(() => _isListening = true);

  void onRecognitionResult(String text) => setState(() => transcription = text);

  void onRecognitionComplete() => setState(() => _isListening = false);
}
