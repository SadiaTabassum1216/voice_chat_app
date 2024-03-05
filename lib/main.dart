import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String text = '';
  String _translatedText = '';
  SpeechToText speechToText = SpeechToText();


  Future<void> _startRecording() async {
    // if (await _audioRecorder.hasPermission()) {
    //   setState(() {
    //     _isRecording = true;
    //     _backendResponse = '';
    //   });
    // await _audioRecorder.start(path: _controller.text, audioOutputFormat: AudioOutputFormat.AAC);

    //   await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.opus), path: 'D:/file.m4a');
    // }

    var available = await speechToText.initialize();
    if (available) {
      _isRecording = true;
      speechToText.listen(onResult: (result) {
        setState(() {
          text = result.recognizedWords;
        });
      });
    }
  }

  _stopRecording() async {
    // final response = await http.get(Uri.parse('http://127.0.0.1:8000/voice/data/'));

    // if (response.statusCode == 200) {
    //   setState(() {
    //     _isRecording = false;
    //   });
    //   _backendResponse=response.body;
    //   return _backendResponse;
    //
    // }
    // else {
    //   throw Exception('Failed to load data');
    // }

    setState(() {
      _isRecording = false;
    });
    speechToText.stop();
    _translateText(text);
  }


  void _translateText(String text) async {
    String textToTranslate = text;
    if (textToTranslate.isNotEmpty) {
      String translation = await translate(textToTranslate);
      setState(() {
        _translatedText = translation;
      });
    }
  }

  Future<String> translate(String text) async {
    final translator = GoogleTranslator();
    final translation = await translator.translate(text, from: 'en', to: 'bn');
    return translation.text;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech-to-Text'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _isRecording ? Icons.fiber_manual_record : Icons.mic_none,
                color: Colors.red,
                size: 30.0,
              ),
              onPressed: () async {
                if (_isRecording) {
                  await _stopRecording();
                } else {
                  await _startRecording();

                }
              },
              // child: Text(_isRecording ? 'Recording...' : 'Tap to Speak'),
            ),
            const SizedBox(height: 20),
            Text('Converted Text: $text'),
            Text('Translated Text: $_translatedText')
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }
}
