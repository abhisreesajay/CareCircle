import { useState } from "react";
function VoiceCheckInScreen({ onBack }) {
  const [language, setLanguage] = useState("en-US");
  const [listening, setListening] = useState(false);
  const [transcript, setTranscript] = useState("");
  const [message, setMessage] = useState("");
  const startVoiceCheckIn = () => {
    const SpeechRecognition =
      window.SpeechRecognition ||
      window.webkitSpeechRecognition;

    if (!SpeechRecognition) {
      setMessage(
        "Voice recognition is not supported. Please use Google Chrome."
      );
      return;
    }

    const recognition = new SpeechRecognition();

    recognition.lang = language;
    recognition.continuous = false;
    recognition.interimResults = false;

    setListening(true);
    setTranscript("");
    setMessage("");

    try {
      recognition.start();
    } catch (error) {
      setListening(false);
      setMessage("Unable to start microphone. Please try again.");
      return;
    }

    recognition.onresult = (event) => {
      const speech = event.results[0][0].transcript;

      setTranscript(speech);
      setListening(false);
      console.log("Voice response:", speech);

      setMessage(
        "Your voice response has been recorded successfully."
      );
    };

    recognition.onerror = (event) => {
      setListening(false);

      if (event.error === "not-allowed") {
        setMessage(
          "Microphone permission was denied. Please allow microphone access."
        );
      } else if (event.error === "no-speech") {
        setMessage(
          "No speech was detected. Please speak clearly and try again."
        );
      } else {
        setMessage(
          "Voice recognition failed. Please try again."
        );
      }
    };

    recognition.onend = () => {
      setListening(false);
    };
  };

  return (
    <div className="screen">

      <button className="back-btn" onClick={onBack}>
        ← BACK
      </button>

      <div className="screen-content">

        <h2>Voice Check-in</h2>

        <p className="screen-question">
          Speak to complete your daily check-in.
        </p>

        <div className="language-section">

          <h3>Select Language</h3>

          <div className="language-buttons">

            <button
              className={
                language === "en-US"
                  ? "language-btn selected"
                  : "language-btn"
              }
              onClick={() => setLanguage("en-US")}
            >
              English
            </button>

            <button
              className={
                language === "ml-IN"
                  ? "language-btn selected"
                  : "language-btn"
              }
              onClick={() => setLanguage("ml-IN")}
            >
              മലയാളം
            </button>

          </div>

        </div>

        <button
          className="microphone-btn"
          onClick={startVoiceCheckIn}
          disabled={listening}
        >
          {listening ? "LISTENING..." : "TAP TO SPEAK"}
        </button>

        <p className="voice-instruction">
          {listening
            ? "Please speak clearly."
            : "Tap the button and speak"}
        </p>

        {transcript && (
          <div className="transcript-box">
            <strong>You said:</strong>
            <p>{transcript}</p>
          </div>
        )}

        {message && (
          <div className="voice-message">
            {message}
          </div>
        )}

        <button
          className="big-action-btn"
          onClick={startVoiceCheckIn}
          disabled={listening}
        >
          {listening
            ? "LISTENING..."
            : "START VOICE CHECK-IN"}
        </button>

      </div>

    </div>
  );
}

export default VoiceCheckInScreen;
