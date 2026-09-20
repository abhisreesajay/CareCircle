import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
class VoiceCheckInScreen extends StatefulWidget {
  const VoiceCheckInScreen({super.key});
  @override
  State<VoiceCheckInScreen> createState() =>
      _VoiceCheckInScreenState();
}
class _VoiceCheckInScreenState extends State<VoiceCheckInScreen> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _text = '';
  String _language = 'en-IN';
  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }
  Future<void> _initializeSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;

          setState(() {
            _isListening = status == 'listening';
          });
        },

        onError: (error) {
          if (!mounted) return;

          setState(() {
            _isListening = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Voice error: ${error.errorMsg}',
              ),
            ),
          );
        },
      );

      if (!mounted) return;

      setState(() {
        _speechAvailable = available;
      });

      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Voice recognition is not available.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to start voice recognition: $e',
          ),
        ),
      );
    }
  }

  // Start listening
  Future<void> _startListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Voice recognition is not available.',
          ),
        ),
      );
      return;
    }

    try {
      await _speech.listen(
        onResult: _onSpeechResult,
        // ignore: deprecated_member_use
        localeId: _language,
      );

      if (!mounted) return;

      setState(() {
        _isListening = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isListening = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not start microphone: $e',
          ),
        ),
      );
    }
  }

  // Stop listening
  Future<void> _stopListening() async {
    await _speech.stop();

    if (!mounted) return;

    setState(() {
      _isListening = false;
    });
  }

  // Receive speech-to-text result
  void _onSpeechResult(
    SpeechRecognitionResult result,
  ) {
    if (!mounted) return;

    setState(() {
      _text = result.recognizedWords;
    });
  }

  // Select English
  void _selectEnglish() {
    setState(() {
      _language = 'en-IN';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'English selected',
        ),
      ),
    );
  }

  // Select Malayalam
  void _selectMalayalam() {
    setState(() {
      _language = 'ml-IN';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Malayalam selected',
        ),
      ),
    );
  }

  // Send check-in
  void _sendCheckIn() {
    if (_text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please speak something first.',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Check-in Sent',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Your response was recorded:\n\n$_text',
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),

      appBar: AppBar(
        title: const Text(
          'Voice Check-in',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF164A63),
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),

          child: Column(
            children: [
              const SizedBox(height: 10),

              // Heading
              const Text(
                'Tell us how you are feeling',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF163B4D),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Choose your language and speak naturally.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF63747B),
                ),
              ),

              const SizedBox(height: 30),

              // Language selection
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectEnglish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _language == 'en-IN'
                            ? const Color(0xFF164A63)
                            : Colors.white,
                        foregroundColor: _language == 'en-IN'
                            ? Colors.white
                            : const Color(0xFF164A63),
                        minimumSize: const Size(0, 60),
                        side: const BorderSide(
                          color: Color(0xFF164A63),
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        'ENGLISH',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectMalayalam,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _language == 'ml-IN'
                            ? const Color(0xFF164A63)
                            : Colors.white,
                        foregroundColor: _language == 'ml-IN'
                            ? Colors.white
                            : const Color(0xFF164A63),
                        minimumSize: const Size(0, 60),
                        side: const BorderSide(
                          color: Color(0xFF164A63),
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        'മലയാളം',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Microphone button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      _isListening
                          ? Icons.mic_rounded
                          : Icons.mic_none_rounded,
                      size: 65,
                      color: _isListening
                          ? Colors.red
                          : const Color(0xFF164A63),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      _isListening
                          ? 'Listening...'
                          : 'Ready to listen',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _isListening
                            ? Colors.red
                            : const Color(0xFF163B4D),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 70,
                      child: ElevatedButton(
                        onPressed: _isListening
                            ? _stopListening
                            : _startListening,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isListening
                              ? Colors.red
                              : const Color(0xFF164A63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _isListening
                              ? 'STOP LISTENING'
                              : 'START SPEAKING',
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Speech result
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Your response',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF163B4D),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 150,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFB0BEC5),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _text.isEmpty
                      ? 'Your speech will appear here...'
                      : _text,
                  style: TextStyle(
                    fontSize: 21,
                    height: 1.4,
                    color: _text.isEmpty
                        ? const Color(0xFF78909C)
                        : const Color(0xFF263238),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Send button
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: _sendCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16845B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'SEND CHECK-IN',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Your voice response will be converted to text.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF63747B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
