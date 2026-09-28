import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../services/check_in_service.dart';

class VoiceCheckInScreen extends StatefulWidget {
  const VoiceCheckInScreen({
    super.key,
  });

  @override
  State<VoiceCheckInScreen> createState() =>
      _VoiceCheckInScreenState();
}

class _VoiceCheckInScreenState
    extends State<VoiceCheckInScreen> {
  final SpeechToText _speech =
      SpeechToText();

  final CheckInService _checkInService =
      CheckInService();

  bool _isListening = false;
  bool _speechAvailable = false;
  bool _isSending = false;

  String _text = '';
  String _language = 'en-IN';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  // ============================================================
  // INITIALIZE SPEECH RECOGNITION
  // ============================================================

  Future<void> _initializeSpeech() async {
    try {
      final bool available =
          await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;

          setState(() {
            _isListening =
                status == 'listening';
          });
        },
        onError: (error) {
          if (!mounted) return;

          setState(() {
            _isListening = false;
          });

          ScaffoldMessenger.of(context)
              .showSnackBar(
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
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Voice recognition is not available on this device.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _speechAvailable = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to start voice recognition: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // START LISTENING
  // ============================================================

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Voice recognition is not available.',
          ),
        ),
      );
      return;
    }

    if (_isSending) {
      return;
    }

    try {
      await _speech.listen(
        onResult: _onSpeechResult,

        // speech_to_text still supports localeId.
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not start microphone: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // STOP LISTENING
  // ============================================================

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _isListening = false;
    });
  }

  // ============================================================
  // SPEECH RESULT
  // ============================================================

  void _onSpeechResult(
    SpeechRecognitionResult result,
  ) {
    if (!mounted) return;

    setState(() {
      _text = result.recognizedWords;
    });
  }

  // ============================================================
  // SELECT ENGLISH
  // ============================================================

  void _selectEnglish() {
    setState(() {
      _language = 'en-IN';
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'English selected',
        ),
      ),
    );
  }

  // ============================================================
  // SELECT MALAYALAM
  // ============================================================

  void _selectMalayalam() {
    setState(() {
      _language = 'ml-IN';
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Malayalam selected',
        ),
      ),
    );
  }

  // ============================================================
  // SEND CHECK-IN TO FIRESTORE
  // ============================================================

  Future<void> _sendCheckIn() async {
    final String response =
        _text.trim();

    if (response.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please speak something first.',
          ),
        ),
      );
      return;
    }

    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please log in again.',
          ),
        ),
      );
      return;
    }

    if (_isListening) {
      await _stopListening();
    }

    if (!mounted) return;

    setState(() {
      _isSending = true;
    });

    try {
      await _checkInService.recordCheckIn(
        elderId: user.uid,
        method: 'voice',
        response: response,
        status: 'COMPLETED',
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Check-in Sent',
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            content: Text(
              'Your response was recorded:\n\n$response',
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
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not save check-in: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F8FA),

      appBar: AppBar(
        title: const Text(
          'Voice Check-in',
          style: TextStyle(
            fontSize: 24,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        backgroundColor:
            const Color(0xFF164A63),
        foregroundColor:
            Colors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(22),

          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // HEADING
              // ==================================================

              const Text(
                'Tell us how you are feeling',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF163B4D),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              const Text(
                'Choose your language and speak naturally.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color:
                      Color(0xFF63747B),
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // ==================================================
              // LANGUAGE SELECTION
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child:
                        ElevatedButton(
                      onPressed:
                          _isSending
                              ? null
                              : _selectEnglish,
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            _language ==
                                    'en-IN'
                                ? const Color(
                                    0xFF164A63,
                                  )
                                : Colors.white,
                        foregroundColor:
                            _language ==
                                    'en-IN'
                                ? Colors.white
                                : const Color(
                                    0xFF164A63,
                                  ),
                        minimumSize:
                            const Size(
                          0,
                          60,
                        ),
                        side:
                            const BorderSide(
                          color: Color(
                            0xFF164A63,
                          ),
                          width: 2,
                        ),
                      ),
                      child:
                          const Text(
                        'ENGLISH',
                        style:
                            TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 15,
                  ),

                  Expanded(
                    child:
                        ElevatedButton(
                      onPressed:
                          _isSending
                              ? null
                              : _selectMalayalam,
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            _language ==
                                    'ml-IN'
                                ? const Color(
                                    0xFF164A63,
                                  )
                                : Colors.white,
                        foregroundColor:
                            _language ==
                                    'ml-IN'
                                ? Colors.white
                                : const Color(
                                    0xFF164A63,
                                  ),
                        minimumSize:
                            const Size(
                          0,
                          60,
                        ),
                        side:
                            const BorderSide(
                          color: Color(
                            0xFF164A63,
                          ),
                          width: 2,
                        ),
                      ),
                      child:
                          const Text(
                        'മലയാളം',
                        style:
                            TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 30,
              ),

              // ==================================================
              // MICROPHONE
              // ==================================================

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black
                              .withValues(
                        alpha: 0.06,
                      ),
                      blurRadius: 10,
                      offset:
                          const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      _isListening
                          ? Icons
                              .mic_rounded
                          : Icons
                              .mic_none_rounded,
                      size: 65,
                      color: _isListening
                          ? Colors.red
                          : const Color(
                              0xFF164A63,
                            ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Text(
                      _isListening
                          ? 'Listening...'
                          : 'Ready to listen',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight
                                .bold,
                        color: _isListening
                            ? Colors.red
                            : const Color(
                                0xFF163B4D,
                              ),
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 70,
                      child:
                          ElevatedButton(
                        onPressed:
                            _isSending
                                ? null
                                : (_isListening
                                    ? _stopListening
                                    : _startListening),
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              _isListening
                                  ? Colors.red
                                  : const Color(
                                      0xFF164A63,
                                    ),
                          foregroundColor:
                              Colors.white,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                        ),
                        child:
                            Text(
                          _isListening
                              ? 'STOP LISTENING'
                              : 'START SPEAKING',
                          style:
                              const TextStyle(
                            fontSize: 23,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // ==================================================
              // SPEECH RESULT
              // ==================================================

              const Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  'Your response',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF163B4D),
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Container(
                width:
                    double.infinity,
                constraints:
                    const BoxConstraints(
                  minHeight: 150,
                ),
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  border:
                      Border.all(
                    color: const Color(
                      0xFFB0BEC5,
                    ),
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
                        ? const Color(
                            0xFF78909C,
                          )
                        : const Color(
                            0xFF263238,
                          ),
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // ==================================================
              // SEND
              // ==================================================

              SizedBox(
                width:
                    double.infinity,
                height: 70,
                child:
                    ElevatedButton(
                  onPressed:
                      _isSending
                          ? null
                          : _sendCheckIn,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF16845B,
                    ),
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child:
                              CircularProgressIndicator(
                            color:
                                Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'SEND CHECK-IN',
                          style:
                              TextStyle(
                            fontSize: 23,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                'Your voice response will be converted to text and saved to your check-in history.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color:
                      Color(0xFF63747B),
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}